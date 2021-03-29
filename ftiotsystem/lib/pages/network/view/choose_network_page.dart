import 'dart:io';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:ftiotsystem/pages/device/choose_device.dart';
import 'package:ftiotsystem/utils/constants.dart';
import 'package:wifi/wifi.dart';

import 'package:ftiotsystem/globals.dart' as globals;

String _ssid = '';  // Wifi name
String _bssid = 'AA:CC:A8:88:5B:AC'; // Dummy WiFi BSSID
String _password = '';  // Wifi password

class ChooseNetworkPage extends StatefulWidget {
  Socket channel;

  @override
  _ChooseNetworkPageState createState() => new _ChooseNetworkPageState();
}

class _ChooseNetworkPageState extends State<ChooseNetworkPage> with AfterLayoutMixin<ChooseNetworkPage> {
  String _wifiName = 'click button to get wifi ssid.';
  int level = 0;
  String _ip = 'click button to get ip.';
  List<WifiResult> ssidList = [];
  String ssid = '', password = '';

  var _ssidController = TextEditingController();

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
        title: Text('Internet Wifi Network'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: EdgeInsets.all(8.0),
          itemCount: ssidList.length + 1,
          itemBuilder: (BuildContext context, int index) {
            return itemSSID(index);
          },
        ),
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
              hintText: 'Your wifi password',
              labelText: 'password',
            ),
            keyboardType: TextInputType.text,
            onChanged: (value) {
              password = value;
              _password = password;
              globals.g_internet_password = _password;
            },
          ),
          ElevatedButton(
            child: Text('next'),
            onPressed: () {
              // Navigate to add new device page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChooseDevicePage()),
              );
            },
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
          leading: Image.asset('images/wifi${ssidList[index - 1].level}.png', width: 28, height: 21),
          title: Text(
            "${ssidList[index - 1].ssid} " ,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16.0,
            ),
          ),
          onTap: () {
            setState(() {
              _tapSSID("${ssidList[index - 1].ssid}");
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
        ssidList = filterTheNodeOut(list);
      });
    });
  }

  List<WifiResult> filterTheNodeOut(List<WifiResult> rawList)  {
    List<WifiResult> resultList = [];
    for (int i = 0; i < rawList.length; i++) {
      if(!rawList[i].ssid.contains("theNode_")) {
        resultList.add(WifiResult(rawList[i].ssid, rawList[i].level));
      }
    }
    return resultList;
  }

  Future<Null> _getWifiName() async {
    int l = await Wifi.level;
    String wifiName = await Wifi.ssid;
    String wifiIp = await Wifi.ip;
    setState(() {
      level = l;
      _wifiName = "${wifiName}";
      _ssid = _wifiName;
      globals.g_internet_ssid = _ssid;
      _ssidController.text = _ssid;
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
      MaterialPageRoute(builder: (context) => ChooseNetworkPage()),
    );
  }

  Future<Null> connection() async {
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

    print("ssid=${ssid} password=${password}");
    Wifi.connection(ssid, password).then((v) async {
      print(v);

    });
  }

  @override
  void afterFirstLayout(BuildContext context) {
    // Get the current ssid
    _getWifiName();
  }

  void _tapSSID([String ssid]) {
    _ssid = ssid;
    _ssidController.text = _ssid;
    globals.g_internet_ssid = _ssid;
  }
}