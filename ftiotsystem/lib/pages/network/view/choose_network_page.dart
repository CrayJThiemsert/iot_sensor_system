import 'dart:io';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:ftiotsystem/pages/device/choose_device.dart';
import 'package:ftiotsystem/pages/network/entity/scenario_entity.dart';
import 'package:ftiotsystem/utils/constants.dart';
import 'package:wifi/wifi.dart';

import 'package:ftiotsystem/globals.dart' as globals;

import 'guide_choose_device_page.dart';

String _ssid = '';  // Wifi name
String _bssid = 'AA:CC:A8:88:5B:AC'; // Dummy WiFi BSSID
String _password = '';  // Wifi password

class ChooseNetworkPage extends StatefulWidget {
  // Socket channel;
  const ChooseNetworkPage({
    Key key,
    @required this.scenario,
  }) : super(key: key);

  final Scenario scenario;

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
        title: Text(getTitle(widget.scenario)),
        backgroundColor: Colors.cyan[400],
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

  String getTitle(Scenario scenario) {
    switch(scenario.index) {
      case 1: {
        return 'Internet Wifi Network 2/5';
      }
      break;
      case 2: {
        return 'Local Wifi Network 2/5';
      }
      break;
      default: {
        return 'Internet Wifi Network 2/5';
      }
      break;
    }
  }

  Widget itemSSID(index) {
    if (index == 0) {
      final TextStyle captionStyle = Theme.of(context).textTheme.headline4;
      final TextStyle subtitleStyle = Theme.of(context).textTheme.bodyText1;
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text('Please choose a SSID and password network',
                textAlign: TextAlign.left,
                style: subtitleStyle,
              ),
            ),
          ),
          TextField(
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              filled: true,
              icon: Icon(Icons.wifi),
              hintText: 'Your wifi ssid',
              labelText: 'ssid',
            ),
            style: captionStyle,
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
            style: captionStyle,
            keyboardType: TextInputType.text,
            onChanged: (value) {
              password = value;
              _password = password;
              globals.g_internet_password = _password;
            },
          ),
          ElevatedButton(
            child: Text('Next'),
            style: ElevatedButton.styleFrom(
              primary: Colors.cyan[400],
              // padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              // textStyle: TextStyle(
              //     fontSize: 30,
              //     fontWeight: FontWeight.bold)
            ),
            onPressed: () {
              // Navigate to add new device page
              Navigator.push(
                context,
                // MaterialPageRoute(builder: (context) => ChooseDevicePage(scenario:  widget.scenario)),
                MaterialPageRoute(builder: (context) => GuideChooseDevicePage(scenario:  widget.scenario)),
              );
            },
            // onPressed: executeEsptouch, // too complicated to use, because we don't know how to verify/handle response.
          ),
          Divider(),
          Container(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text('Available Internet Network List:',
                textAlign: TextAlign.left,
                style: subtitleStyle,
              ),
            ),
          ),
          Divider(),
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
    // widget.channel.destroy();
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