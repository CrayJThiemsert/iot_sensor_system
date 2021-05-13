import 'dart:async';
import 'dart:io';

import 'package:after_layout/after_layout.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ftiotsystem/pages/network/entity/scenario_entity.dart';
import 'package:ftiotsystem/utils/constants.dart';
import 'package:wifi/wifi.dart';

import 'package:ftiotsystem/globals.dart' as globals;

import 'package:http/http.dart' as http;

String _ssid = '';  // Wifi name
String _bssid = 'AA:CC:A8:88:5B:AC'; // Dummy WiFi BSSID
String _password = '';  // Wifi password
String _deviceName = '';  // Device name

class ChooseDevicePage extends StatefulWidget {
  const ChooseDevicePage({
    Key key,
    @required this.scenario,
  }) : super(key: key);

  final Scenario scenario;

  // Socket channel;

  @override
  _ChooseDevicePageState createState() => new _ChooseDevicePageState();
}

class _ChooseDevicePageState extends State<ChooseDevicePage> with AfterLayoutMixin<ChooseDevicePage> {
  String _wifiName = 'click button to get wifi ssid.';
  int level = 0;
  String _ip = 'click button to get ip.';
  List<WifiResult> theNodeSSIDList = [];
  String ssid = '', password = '';
  String deviceName = '';

  var _ssidController = TextEditingController();
  var _deviceNameController = TextEditingController();
  var _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text('${Constants.of(context).DEFAULT_THE_NODE_IP} Internet Wifi Network'),
        title: Text(getTitle(widget.scenario)),
        backgroundColor: Colors.cyan[400],
        centerTitle: true,
      ),
      body: SafeArea(
        child: itemSSID(0),
      ),
    );
  }

  String getTitle(Scenario scenario) {
    print('scenario.index=${scenario.index}');
    switch(scenario.index) {
      case 11:
      case 22: {
        return 'Connect Device 5/5';
      }
      break;
      case 33: {
        return 'Connect Device 4/4';
      }
      break;
      default: {
        return 'Connect Device 5/5';
      }
      break;
    }
  }

  int getScenarioIndex(Scenario scenario) {
    switch(scenario.index) {
      case 11: {
        return 1;
      }
      break;
      case 22: {
        return 2;
      }
      break;
      case 33: {
        return 3;
      }
      break;
      default: {
        return 1;
      }
    }
  }

  Widget itemSSID(index) {
    final TextStyle captionStyle = Theme.of(context).textTheme.headline4;
    if (index == 0) {
      return Column(
        children: [
          TextField(
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              filled: true,
              icon: Icon(Icons.network_check),
              hintText: 'Your selected device network',
              labelText: 'selected device network',
            ),
            style: captionStyle,
            enabled: false,
            controller: _ssidController,
            onChanged: (value) {
              ssid = value;
            },
          ),
          TextField(
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              filled: true,
              icon: Icon(Icons.title),
              hintText: 'Your device name',
              labelText: 'device name',
            ),
            style: captionStyle,
            keyboardType: TextInputType.text,
            controller: _deviceNameController,
            onTap: () {
              if(globals.g_device_name.isEmpty) {
                _deviceNameController.text = 'Humidity and Temperature Sensor';
                globals.g_device_name = _deviceNameController.text;
              }
            },
            onChanged: (value) {
              deviceName = value;
              _deviceName = deviceName;
              globals.g_device_name = _deviceName;
            },
          ),
          ElevatedButton(
            child: Text('Choose a device...'),
            style: ElevatedButton.styleFrom(
              primary: Colors.cyan[400],
              // padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              // textStyle: TextStyle(
              //     fontSize: 30,
              //     fontWeight: FontWeight.bold)
            ),
            onPressed: () {
              AppSettings.openWIFISettings(asAnotherTask: true).then((value) => scanMatchedTheNode() );
            },
            // onPressed: executeEsptouch, // too complicated to use, because we don't know how to verify/handle response.
          ),
          ElevatedButton(
            child: Text('Connect'),
            style: ElevatedButton.styleFrom(
              primary: Colors.cyan[400],
              // padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              // textStyle: TextStyle(
              //     fontSize: 30,
              //     fontWeight: FontWeight.bold)
            ),
            onPressed: gotoHomePage,
            // onPressed: executeEsptouch, // too complicated to use, because we don't know how to verify/handle response.
          ),
        ],
      );
    } else {
      return Column(children: <Widget>[
        ListTile(
          leading: Image.asset('images/wifi${theNodeSSIDList[index - 1].level}.png', width: 28, height: 21),
          title: Text(
            "${theNodeSSIDList[index - 1].ssid} " ,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16.0,
            ),
          ),
          onTap: () {
            setState(() {
              _tapTheNodeSSID("${theNodeSSIDList[index - 1].ssid}");
            });
          },

          dense: true,
        ),
        Divider(),
      ]);
    }
  }

  @override
  void dispose() {
    _ssidController.dispose();
    _deviceNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void loadData() async {
    Wifi.list('').then((list) {
      setState(() {
        theNodeSSIDList = filterTheNode(list);
      });
    });
  }

  List<WifiResult> filterTheNode(List<WifiResult> rawList)  {
    List<WifiResult> resultList = [];
    for (int i = 0; i < rawList.length; i++) {
      if(rawList[i].ssid.contains("theNode_")) {
        resultList.add(WifiResult(rawList[i].ssid, rawList[i].level));
      }
    }
    return resultList;
  }

  Future<Null> _getCurrentWifiSSID() async {
    int l = await Wifi.level;
    String wifiName = await Wifi.ssid;
    setState(() {
      level = l;
      _wifiName = "${wifiName}";
      _ssid = _wifiName;
      _ssidController.text = _ssid;
      if(_ssid.contains("theNode_")) {
        _passwordController.text = "Device Matched";
        _ssidController.text = "Device Matched";
      } else {
        _passwordController.text = "Device Not Matched";
        _ssidController.text = "Device Not Matched";
      }
    });
  }

  Future<Null> _getIP() async {
    String ip = await Wifi.ip;
    setState(() {
      _ip = ip;
    });
  }

  void dataHandler(data){
    print(new String.fromCharCodes(data).trim());
  }

  void errorHandler(error, StackTrace trace){
    print(error);
  }

  void doneHandler(){
    // widget.channel.destroy();
  }

  void gotoDeviceDetailPage() {
    Navigator.pushNamedAndRemoveUntil(context, "/DetailDevicePage", (route) => false);
  }

  void gotoHomePage() {
    connection();
    Navigator.pushNamedAndRemoveUntil(context, '/', (Route<dynamic> route) => false);
  }

  /**
   * First contact to "the Node" to pass internet wifi ssid and password
   */
  Future<http.Response> connection() async {

    String mode = "setup";
    var url =
    // Uri.https('www.googleapis.com', '/books/v1/volumes', {'q': '{http}'});
    Uri.http(Constants.of(context).DEFAULT_THE_NODE_IP, '/setting', {
      'ssid': globals.g_internet_ssid,
      'pass': globals.g_internet_password,
      'mode': mode,
      'name': globals.g_device_name,
      'scenario': getScenarioIndex(widget.scenario),
      'mobileserver': globals.g_mobileServer // '192.168.1.106' S7 Edge
    });

    // Await the http get response, then decode the json-formatted response.
    final response = await http.get(url);
    print("status code =${response.statusCode}");
    if (response.statusCode == 200) {
      print('Device[${_ssid}] - setting is ok!!');
      _passwordController.text = "Device[${_ssid}] - setting is ok!!";
      // var jsonResponse = convert.jsonDecode(response.body);
      // var itemCount = jsonResponse['totalItems'];
      // print('Number of books about http: $itemCount.');
    } else {
      print('Device[${_ssid}] - setting is not ok!!');
      _passwordController.text = "Device[${_ssid}] - setting is not ok!!";
      // print('Request failed with status: ${response.statusCode}.');
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to do wifi settings');
    }

    return response;
    // print("_ip=${_ip}");
    // widget.channel = await Socket.connect('192.168.1.144', 80).then((Socket sock) {
    //   widget.channel = sock;
    //   widget.channel.listen(dataHandler,
    //       onError: errorHandler,
    //       onDone: doneHandler,
    //       cancelOnError: false);
    // }).catchError((Object e) {
    //   print("Unable to connect: $e");
    // });

    // print("ssid=${ssid} password=${password}");
    // Wifi.connection(ssid, password).then((v) async {
    //   print(v);
    //
    // });


  }

  @override
  void afterFirstLayout(BuildContext context) {
    // Get the global ssid and password
    // _ssidController.text = globals.g_internet_ssid;
    // _passwordController.text = globals.g_internet_password;

    AppSettings.openWIFISettings(asAnotherTask: true).then((value) => scanMatchedTheNode() );
  }

  void scanMatchedTheNode() {
    print("hello scanMatchedTheNode!!");

    Timer.periodic(Duration(seconds: 5), (timer) async {
      print("Time: ${DateTime.now()}");

      String wifiName = await Wifi.ssid;
      setState(() {
        _wifiName = "${wifiName}";
        _ssid = _wifiName;
        _ssidController.text = _ssid;
        if(_ssid.contains("theNode_")) {
          _passwordController.text = "Device[${_ssid}] Matched";
          _ssidController.text = "Device[${_ssid}] Matched";
          timer.cancel();
        } else {
          _passwordController.text = "Device[${_ssid}] Not Matched";
          _ssidController.text = "Device[${_ssid}] Not Matched";
        }
        print("${_passwordController.text}");
      });
    });
  }

  void _tapTheNodeSSID([String ssid]) {
    _password = ssid;
    _passwordController.text = _password;
  }
}