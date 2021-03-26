/**

   Written and Verified by the owner of techiesms
   Mr. Sachin Soni

   This code is open for fair use.
   If you are using it for commercial purpose, then it's mandatory to give credits

   Tutorial Video Link :- 

*/

#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <ESP8266WebServer.h>
#include <EEPROM.h>
#include <DHT.h>
#include<FirebaseArduino.h>

#define THE_NODE_SSID "theNode_DHT"
#define THE_NODE_PASSWORD ""

// Working Mode(mode) [20 characters]
#define POLLING_MODE "polling mode" 
#define REQUEST_MODE "request mode" 
#define BURST_MODE "burst mode" // Default, use after installation process finished
#define OFFLINE_MODE "offline mode"

IPAddress ap_local_ip = {192,168,1,199};   // Set up "the Node"'s AP mode IP
IPAddress gateway={192,168,1,1};      // Set up "the Node"'s AP mode Gateway
IPAddress subnet={255,255,255,0};     // Set up "the Node"'s AP mode Subnet

//Variables
int i = 0;
int statusCode;
const char* ssid = "text";
const char* passphrase = "text";
String st;
String content;

String gFirebaseHost = "";
String gFirebaseAuth = "";
String gWorkingMode = BURST_MODE;

//Function Decalration
bool testWifi(void);
void launchWeb(void);
void setupAP(void);
bool readSensor(void);
bool updateCloud(void);

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
  if ((WiFi.status() == WL_CONNECTED))
  {

    for (int i = 0; i < 10; i++)
    {
      digitalWrite(LED_BUILTIN, HIGH);
      delay(1000);
      digitalWrite(LED_BUILTIN, LOW);
      delay(1000);
    }

    if(updateCloud()) {
      Serial.println("Succesfully Update data to the Cloud!!!");
    } else {
      Serial.println("Update data to the Cloud Failured!!!");
    }
    
  }
  else
  {
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
        server.sendHeader("Access-Control-Allow-Origin", "*");
        server.send(statusCode, "application/json", content);
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
bool updateCloud(void)
{
  int c = 0;
  Serial.println("Waiting for update cloud");
  Serial.print("Firebase Host:");
  Serial.println(gFirebaseHost);
  Serial.print("Firebase Auth:");
  Serial.println(gFirebaseAuth);
  
  Serial.println("");
  Serial.println("updateCloud() Finished");
  return true;
}
//------------------------- Functions about sensor
