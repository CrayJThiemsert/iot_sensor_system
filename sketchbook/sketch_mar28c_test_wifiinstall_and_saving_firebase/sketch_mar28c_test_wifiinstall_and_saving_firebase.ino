/**

   Written and Verified by 
   Mr. Jirachai Thiemsert

*/
// To connect Wifi
#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <ESP8266WebServer.h>

// To save local config memory
#include <EEPROM.h>

// To read humid and temperature sensor
#include <DHT.h>

// To update Firebase Realtime Database
#include<FirebaseArduino.h>

// To get the current date time from internet
#include <NTPClient.h>
#include <WiFiUdp.h>

// ======================================================================
// Default "theNode" AP Mode SSID and password, use to transfer data between "the App" and "the Node".
#define THE_NODE_SSID "theNode_DHT"
#define THE_NODE_PASSWORD ""
IPAddress ap_local_ip = {192,168,1,199};   // Set up "the Node"'s AP mode IP
IPAddress gateway={192,168,1,1};      // Set up "the Node"'s AP mode Gateway
IPAddress subnet={255,255,255,0};     // Set up "the Node"'s AP mode Subnet
// ======================================================================
// Working Mode(mode) [20 characters]
#define POLLING_MODE "polling mode" 
#define REQUEST_MODE "request mode" 
#define BURST_MODE "burst mode" // Default, use after installation process finished
#define OFFLINE_MODE "offline mode"
// ======================================================================
// Define NTP Client to get time
WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP, "pool.ntp.org");

//Week Days
String weekDays[7]={"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"};

//Month names
String months[12]={"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"};

// Bangkok timezone GMT+7
#define BANGKOK_TIMEZONE 25200
// ======================================================================
// Config DHT - Humid and Temperature Sensor
#define DHTPIN 4
//#define DHTTYPE DHT11
#define DHTTYPE DHT22

DHT dht(DHTPIN, DHTTYPE);
// ======================================================================
#define FIREBASE_HOST "asset-management-lff.firebaseio.com"
#define FIREBASE_AUTH "tyPYNCdjHQREFNsW46sha4JhOFG4WG4U7pL8iShx"

// Variables
int i = 0;
int statusCode;
const char* ssid = "text";
const char* passphrase = "text";
String st;
String content;

String gFirebaseHost = "";
String gFirebaseAuth = "";
String gWorkingMode = BURST_MODE;
String gCurrentDateTimeString = "-";
float gTemperature = 0;
float gHumidity = 0;

// Function Decalration
bool testWifi(void);
void launchWeb(void);
void setupAP(void);
bool getCurrentDateTime(void);
bool readSensor(void);
bool saveDataToCloudDatabase(void);

//Establishing Local server at port 80 whenever required
ESP8266WebServer server(80);

void setup()
{

  Serial.begin(115200); //Initialising if(DEBUG)Serial Monitor
  Serial.println();
  Serial.println("Disconnecting previously connected WiFi");
  WiFi.disconnect();
  EEPROM.begin(512); //Initialasing EEPROM
  delay(10);
  pinMode(LED_BUILTIN, OUTPUT);
  Serial.println();
  Serial.println();
  Serial.println("Startup");

  //---------------------------------------- Read eeprom for ssid and pass
  Serial.println("Reading EEPROM ssid");

  String esid;
  for (int i = 0; i < 32; ++i)
  {
    esid += char(EEPROM.read(i));
  }
  Serial.println();
  Serial.print("SSID: ");
  Serial.println(esid);
  Serial.println("Reading EEPROM pass");

  String epass = "";
  for (int i = 32; i < 96; ++i)
  {
    epass += char(EEPROM.read(i));
  }
  Serial.print("PASS: ");
  Serial.println(epass);

  String efbhost = "";
  for (int i = 96; i < 160; ++i)
  {
    efbhost += char(EEPROM.read(i));
  }
  Serial.print("FBHOST: ");
  Serial.println(efbhost);
  gFirebaseHost = efbhost;

  String efbauth = "";
  for (int i = 160; i < 224; ++i)
  {
    efbauth += char(EEPROM.read(i));
  }
  Serial.print("FBAUTH: ");
  Serial.println(efbauth);
  gFirebaseAuth = efbauth;

  String emode = "";
  for (int i = 224; i < 244; ++i)
  {
    emode += char(EEPROM.read(i));
  }
  Serial.print("MODE: ");
  Serial.println(emode);
  gWorkingMode = emode;

  // Try to connect wifi by loaded ssid and password values from eeprom
  WiFi.begin(esid.c_str(), epass.c_str());
  if (testWifi())
  {
    Serial.println("Succesfully Connected!!!");

    
    return;
  }
  else
  {
    Serial.println("Turning the HotSpot On");
    setupAP();// Setup HotSpot
    launchWeb();
  }

  Serial.println();
  Serial.println("Waiting.");
  
  while ((WiFi.status() != WL_CONNECTED))
  {
    Serial.println(".");
    delay(1000);
    server.handleClient();
  }

}
void loop() {
  if ((WiFi.status() == WL_CONNECTED))  {
    // Delay test 1 minutes
    for (int i = 0; i < 30; i++) {
      digitalWrite(LED_BUILTIN, HIGH);
      delay(1000);
      digitalWrite(LED_BUILTIN, LOW);
      delay(1000);
    }

    if(readSensor()) {
      Serial.println("Succesfully read sensor data!!!");
      if(saveDataToCloudDatabase()) {
        Serial.println("Succesfully Update data to the Cloud!!!");

        // Delay belong to working mode, default is burst mode, 10 seconds
//        delay(10000);
      } else {
        Serial.println("Update data to the Cloud Failured!!!");
      }  
    } else {
      Serial.println("Read sensor Failured!!!");
    }
    
  }
  else  {
    Serial.println("Connect Internet Wifi Failured!!!");
  }
  
}


//----------------------------------------------- Fuctions used for WiFi credentials saving and connecting to it which you do not need to change 
bool testWifi(void)
{
  int c = 0;
  Serial.println("Waiting for Wifi to connect");
  while ( c < 30 ) {
    if (WiFi.status() == WL_CONNECTED)
    {
      return true;
    }
    delay(1000);
    Serial.print("*");
    c++;
  }
  Serial.println("");
  Serial.println("Connect timed out, opening AP");
  return false;
}

void launchWeb()
{
  Serial.println("");
  if (WiFi.status() == WL_CONNECTED)
    Serial.println("WiFi connected");
  Serial.print("Local IP: ");
  Serial.println(WiFi.localIP());
  Serial.print("SoftAP IP: ");
  Serial.println(WiFi.softAPIP());
  createWebServer();
  // Start the server
  server.begin();
  Serial.println("Server started");
}

void setupAP(void)
{
  WiFi.mode(WIFI_STA);
  WiFi.disconnect();
  delay(100);
  int n = WiFi.scanNetworks();
  Serial.println("scan done");
  if (n == 0)
    Serial.println("no networks found");
  else
  {
    Serial.print(n);
    Serial.println(" networks found");
    for (int i = 0; i < n; ++i)
    {
      // Print SSID and RSSI for each network found
      Serial.print(i + 1);
      Serial.print(": ");
      Serial.print(WiFi.SSID(i));
      Serial.print(" (");
      Serial.print(WiFi.RSSI(i));
      Serial.print(")");
      Serial.println((WiFi.encryptionType(i) == ENC_TYPE_NONE) ? " " : "*");
      delay(10);
    }
  }
  Serial.println("");
  st = "<ol>";
  for (int i = 0; i < n; ++i)
  {
    // Print SSID and RSSI for each network found
    st += "<li>";
    st += WiFi.SSID(i);
    st += " (";
    st += WiFi.RSSI(i);

    st += ")";
    st += (WiFi.encryptionType(i) == ENC_TYPE_NONE) ? " " : "*";
    st += "</li>";
  }
  st += "</ol>";
  delay(100);
//  WiFi.softAP("techiesms", "");
//  Serial.println("softap");

  WiFi.softAP(THE_NODE_SSID, THE_NODE_PASSWORD); // Set Soft SSID
  WiFi.softAPConfig(ap_local_ip,gateway,subnet); // Set up to module  
  Serial.println("set softap");
  Serial.println("AP Web Server IP address: "); 
  Serial.println(WiFi.softAPIP());       // Show ESP8266's IP Addres
  
  launchWeb();
  Serial.println("over");
}

void createWebServer()
{
 {
    server.on("/", []() {

      IPAddress ip = WiFi.softAPIP();
      String ipStr = String(ip[0]) + '.' + String(ip[1]) + '.' + String(ip[2]) + '.' + String(ip[3]);
      content = "<!DOCTYPE HTML>\r\n<html>Hello from ESP8266 at ";
      content += "<form action=\"/scan\" method=\"POST\"><input type=\"submit\" value=\"scan\"></form>";
      content += ipStr;
      content += "<p>";
      content += st;
      content += "</p><form method='get' action='setting'><label>SSID: </label><input name='ssid' length=32><input name='pass' length=64><input type='submit'></form>";
      content += "</html>";
      server.send(200, "text/html", content);
    });
    server.on("/scan", []() {
      //setupAP();
      IPAddress ip = WiFi.softAPIP();
      String ipStr = String(ip[0]) + '.' + String(ip[1]) + '.' + String(ip[2]) + '.' + String(ip[3]);

      content = "<!DOCTYPE HTML>\r\n<html>go back";
      server.send(200, "text/html", content);
    });

    server.on("/setting", []() {
      String qsid = server.arg("ssid");
      String qpass = server.arg("pass");

      String qfbhost = server.arg("fbhost");
      String qfbauth = server.arg("fbauth");

      String qmode = server.arg("mode");
      
      if (qsid.length() > 0 && qpass.length() > 0) {
        Serial.println("clearing eeprom");
//        for (int i = 0; i < 96; ++i) {  // ssid, password
//        for (int i = 0; i < 224; ++i) { // + firebase host, firabase auth
        for (int i = 0; i < 244; ++i) { // + working mode
          EEPROM.write(i, 0);
        }
        Serial.println(qsid);
        Serial.println("");
        Serial.println(qpass);
        Serial.println("");

        // save internet ssid and password into eeprom
        Serial.println("writing eeprom ssid:");
        for (int i = 0; i < qsid.length(); ++i)
        {
          EEPROM.write(i, qsid[i]);
          Serial.print("Wrote: ");
          Serial.println(qsid[i]);
        }
        Serial.println("writing eeprom pass:");
        for (int i = 0; i < qpass.length(); ++i)
        {
          EEPROM.write(32 + i, qpass[i]);
          Serial.print("Wrote: ");
          Serial.println(qpass[i]);
        }

        // save firebase host and auth into eeprom
        if (qfbhost.length() > 0 && qfbauth.length() > 0) {
          // fbhost size 64 characters
          Serial.println("writing eeprom fbhost:");
          for (int i = 0; i < qfbhost.length(); ++i)
          {
            EEPROM.write(96 + i, qfbhost[i]);
            Serial.print("Wrote: ");
            Serial.println(qfbhost[i]);
          }
          // fbauth size 64 characters
          Serial.println("writing eeprom fbauth:");
          for (int i = 0; i < qfbauth.length(); ++i)
          {
            EEPROM.write(160 + i, qfbauth[i]);
            Serial.print("Wrote: ");
            Serial.println(qfbauth[i]);
          }
        }

        // save working mode into eeprom
        if (qmode.length() > 0) {
          // mode size 20 characters
          Serial.println("writing eeprom mode:");
          for (int i = 0; i < qmode.length(); ++i)
          {
            EEPROM.write(224 + i, qmode[i]);
            Serial.print("Wrote: ");
            Serial.println(qmode[i]);
          }
        }
        EEPROM.commit();

        content = "{\"Success\":\"saved to eeprom... reset to boot into new wifi\"}";
        statusCode = 200;
        Serial.println("Sending 200");
        server.sendHeader("Connection", "close");
        server.send(200, "text/html", content);
//        server.sendHeader("Access-Control-Allow-Origin", "*");
//        server.addHeader("Content-Type", "text/plain");
//        server.send(statusCode, "application/json", content);
//        server.on("/header", HTTP_GET, [](AsyncWebServerRequest *request){
//          AsyncWebServerResponse *response = request->beginResponse(200, "text/plain", "Ok");
//          response->addHeader("Test-Header", "My header value");
//          request->send(response);
//        });
        ESP.reset();
      } else {
        content = "{\"Error\":\"404 not found\"}";
        statusCode = 404;
        Serial.println("Sending 404");
        server.sendHeader("Access-Control-Allow-Origin", "*");
        server.send(statusCode, "application/json", content);
      }

    });
  } 
}
//------------------------- Functions about cloud
bool saveDataToCloudDatabase(void) {
  int c = 0;

  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
  gFirebaseHost = FIREBASE_HOST;
  gFirebaseAuth = FIREBASE_AUTH;
  Serial.println("Waiting for update cloud");
  Serial.print("Firebase Host:");
  Serial.println(gFirebaseHost);
  Serial.print("Firebase Auth:");
  Serial.println(gFirebaseAuth);

  // Get current date time uid.
  if(getCurrentDateTime()) {

    Serial.print("gCurrentDateTimeString=");
    Serial.println(gCurrentDateTimeString);

    // Create read sensor json object
    StaticJsonBuffer<256> jsonBuffer;
    JsonObject& root = jsonBuffer.createObject();
  
    JsonObject& sensorValues = root.createNestedObject(gCurrentDateTimeString);
    sensorValues["temperature"] = gTemperature;
    sensorValues["humidity"] = gHumidity;

    // Append a new value to temporary node
    String nodeString = "users/cray/devices/ht-00001/ht-00001_history/" + gCurrentDateTimeString;
    Serial.print("nodeString=");
    Serial.println(nodeString);

    // Create the new sensor values node
    Firebase.set(nodeString, sensorValues); 

    // handle error
    if (Firebase.failed()) {
        Serial.print("setting /node data failed:");
        Serial.println(Firebase.error());  
        return false;
    }
    Serial.print(" humid: ");
    Serial.print(gHumidity);
    Serial.print(" % temperature: ");
    Serial.print(gTemperature);
    Serial.println(" Celsius");

    Serial.println("");
    Serial.println("saveDataToCloudDatabase() Finished");
  } else {
    Serial.println("get the current date time string failured!!");
    return false;
  }
  return true;
}
//------------------------- Functions about sensor

/**
 * Get the current date time for uid of read sensor on the cloud database.
 */
bool getCurrentDateTime(void) {
  // Initialize a NTPClient to get time
  timeClient.begin();
  // Set offset time in seconds to adjust for your timezone, for example:
  // GMT +1 = 3600
  // GMT +7 = 25200
  // GMT +8 = 28800
  // GMT -1 = -3600
  // GMT 0 = 0
  timeClient.setTimeOffset(BANGKOK_TIMEZONE);
  timeClient.update();

  //Get a time structure
  unsigned long epochTime = timeClient.getEpochTime();
  struct tm *ptm = gmtime ((time_t *)&epochTime); 

  int monthDay = ptm->tm_mday;
  Serial.print("Month day: ");
  Serial.println(monthDay);

  int currentMonth = ptm->tm_mon+1;
  Serial.print("Month: ");
  Serial.println(currentMonth);

  String currentMonthName = months[currentMonth-1];
  Serial.print("Month name: ");
  Serial.println(currentMonthName);

  int currentYear = ptm->tm_year+1900;
  Serial.print("Year: ");
  Serial.println(currentYear);

  //Print complete date:
//  String currentDate = String(currentYear) + "-" + String(currentMonth) + "-" + String(monthDay);
  String formattedTime = timeClient.getFormattedTime();
  
  char date_buf[20];
  sprintf(date_buf,"%04u-%02u-%02u %s", currentYear,currentMonth,monthDay, formattedTime.c_str());
  Serial.print("date_buf=");
  Serial.println(date_buf);

  gCurrentDateTimeString = date_buf;

  return true;
}

bool readSensor(void) {
  dht.begin();

  // Read temp & Humidity for DHT22
  float h = dht.readHumidity();
  float t = dht.readTemperature();

  if (isnan(h) || isnan(t)) {
    Serial.println("Failed to read from DHT sensor!");
    delay(500);
    return false;
  }

  // Get sensor values
  gTemperature = t;
  gHumidity = h;
  
  return true;
}
