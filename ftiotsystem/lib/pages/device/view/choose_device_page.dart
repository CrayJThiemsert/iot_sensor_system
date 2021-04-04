import 'dart:async';
import 'dart:io';

import 'package:after_layout/after_layout.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ftiotsystem/utils/constants.dart';
import 'package:wifi/wifi.dart';

import 'package:ftiotsystem/globals.dart' as globals;

import 'package:http/http.dart' as http;

String _ssid = '';  // Wifi name
String _bssid = 'AA:CC:A8:88:5B:AC'; // Dummy WiFi BSSID
String _password = '';  // Wifi password
String _deviceName = '';  // Device name

class ChooseDevicePage extends StatefulWidget {
  Socket channel;

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
        title: Text('Connect Device'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: itemSSID(0),
        // child: ListView.builder(
        //   padding: EdgeInsets.all(8.0),
        //   itemCount: theNodeSSIDList.length + 1,
        //   itemBuilder: (BuildContext context, int index) {
        //     return itemSSID(index);
        //   },
        // ),
      ),
    );
  }

  Widget itemSSID(index) {
    if (index == 0) {
      return Column(
        children: [
          // Row(
          //   children: <Widget>[
          //     ElevatedButton(
          //       child: Text('ssid'),
          //       onPressed: _getWifiName,
          //     ),
          //     Offstage(
          //       offstage: level == 0,
          //       child: Image.asset(level == 0 ? 'images/wifi1.png' : 'images/wifi$level.png', width: 28, height: 21),
          //     ),
          //     Text(_wifiName,
          //       textAlign: TextAlign.left,
          //     ),
          //   ],
          // ),
          // Row(
          //   children: <Widget>[
          //     ElevatedButton(
          //       child: Text('ip'),
          //       onPressed: _getIP,
          //     ),
          //     Text(_ip,
          //       textAlign: TextAlign.left,
          //     ),
          //   ],
          // ),
          TextField(
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              filled: true,
              icon: Icon(Icons.wifi),
              hintText: 'Your wifi ssid',
              labelText: 'ssid',
            ),
            keyboardType: TextInputType.text,
            controller: _ssidController,
            onChanged: (value) {
              ssid = value;
            },
          ),
          TextField(
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              filled: true,
              icon: Icon(Icons.lock_outline),
              hintText: 'Your device name',
              labelText: 'device name',
            ),
            keyboardType: TextInputType.text,
            controller: _deviceNameController,
            onChanged: (value) {
              deviceName = value;
              _deviceName = deviceName;
              globals.g_device_name = _deviceName;
            },
          ),
          TextField(
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              filled: true,
              icon: Icon(Icons.lock_outline),
              hintText: 'Your wifi password',
              labelText: 'password',
            ),
            keyboardType: TextInputType.text,
            controller: _passwordController,
            onChanged: (value) {
              password = value;
              _password = password;
              globals.g_internet_password = _password;
            },
          ),
          ElevatedButton(
            child: Text('Choose a device...'),
            onPressed: () {
              AppSettings.openWIFISettings(asAnotherTask: true).then((value) => scanMatchedTheNode() );
            },
            // onPressed: executeEsptouch, // too complicated to use, because we don't know how to verify/handle response.
          ),
          ElevatedButton(
            child: Text('connect'),
            onPressed: gotoHomePage,
            // onPressed: executeEsptouch, // too complicated to use, because we don't know how to verify/handle response.
          ),
          // ElevatedButton(
          //   child: Text('connection'),
          //   onPressed: connection,
          //   // onPressed: executeEsptouch, // too complicated to use, because we don't know how to verify/handle response.
          // ),

          // ElevatedButton(
          //   child: Text("AC On/Off",
          //       style: TextStyle(
          //           color: Colors.white,
          //           fontStyle: FontStyle.italic,
          //           fontSize: 20.0
          //       )
          //   ),
          //   onPressed: _togglePower,
          // ),
          // ElevatedButton(
          //   child: Text("Fan",
          //       style: TextStyle(
          //           color: Colors.white,
          //           fontStyle: FontStyle.italic,
          //           fontSize: 20.0
          //       )
          //   ),
          //   onPressed: _fan,
          // ),
          // ElevatedButton(
          //   child: Text("Mode",
          //       style: TextStyle(
          //           color: Colors.white,
          //           fontStyle: FontStyle.italic,
          //           fontSize: 20.0
          //       )
          //   ),
          //   onPressed: _mode,
          // ),
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

  void _togglePower() {
    print("call _togglePower...");
    // widget.channel.write("POWER\n");
  }

  void _fan() {
    widget.channel.write("FAN\n");
  }

  void _mode() {
    widget.channel.write("MODE\n");
  }

  @override
  void dispose() {
    // widget.channel.close();
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
      } else {
        _passwordController.text = "Device Not Matched";
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
    widget.channel.destroy();
  }

  void gotoNextPage() {
    // Navigate to add new device page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChooseDevicePage()),
    );
  }

  void gotoDeviceDetailPage() {
    Navigator.pushNamedAndRemoveUntil(context, "/DetailDevicePage", (route) => false);
  }

  void gotoHomePage() {
    connection();
    Navigator.pushNamedAndRemoveUntil(context, '/', (Route<dynamic> route) => false);
  }

  Future<http.Response> connection() async {
    String mode = "setup";
    var url =
    // Uri.https('www.googleapis.com', '/books/v1/volumes', {'q': '{http}'});
    Uri.http(Constants.of(context).DEFAULT_THE_NODE_IP, '/setting', {'ssid': globals.g_internet_ssid, 'pass': globals.g_internet_password, 'mode': mode, 'name': globals.g_device_name});

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
          timer.cancel();
        } else {
          _passwordController.text = "Device[${_ssid}] Not Matched";
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