import 'dart:async';
import 'dart:io';

import 'package:after_layout/after_layout.dart';
// import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gifimage/flutter_gifimage.dart';
// import 'package:ftiotsystem/pages/device/choose_device.dart';
import 'package:ftiotsystem/pages/network/entity/scenario_entity.dart';
import 'package:ftiotsystem/pages/network/widget/GuidePage.dart';
// import 'package:ftiotsystem/utils/sizes_helpers.dart';
import 'package:wifi/wifi.dart';

import 'package:ftiotsystem/globals.dart' as globals;
import 'package:wifi_info_flutter/wifi_info_flutter.dart';

import 'package:connectivity/connectivity.dart' show Connectivity, ConnectivityResult;
import 'package:wifi_info_flutter/wifi_info_flutter.dart';

String _ssid = '';  // Wifi name

class GuideChooseDevicePage extends StatefulWidget {
  const GuideChooseDevicePage({
    Key key,
    @required this.scenario,
  }) : super(key: key);

  final Scenario scenario;

  @override
  _GuideChooseDevicePageState createState() => new _GuideChooseDevicePageState();
}

class _GuideChooseDevicePageState extends State<GuideChooseDevicePage> with AfterLayoutMixin<GuideChooseDevicePage>, TickerProviderStateMixin {
  String _wifiName = 'click button to get wifi ssid.';
  int level = 0;
  List<WifiResult> ssidList = [];
  String ssid = '', password = '';

  var _ssidController = TextEditingController();

  GifController gifController;

  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  final WifiInfo _wifiInfo = WifiInfo();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {

    gifController = GifController(vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_){
      gifController.repeat(min: 0,max: 100,period: Duration(milliseconds: 5000));
    });

    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GuidePage(scenario: Scenario(
                caption: 'Choose A Device',
                description: 'select a device that you want to connect.',
                guide: 'Please turn on the device. You suppose to see \"theNode_DHT\" in the current network list.\n\nThe tap it and go back to the next page.',
                iconImage: 'images/choose_device.jpg',
                index: getIndex(widget.scenario)),
                gifController: gifController),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    gifController.dispose();

    _connectivitySubscription.cancel();

    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        String wifiName, wifiBSSID, wifiIP;

        try {
          if (!kIsWeb && Platform.isIOS) {
            LocationAuthorizationStatus status =
            await _wifiInfo.getLocationServiceAuthorization();
            if (status == LocationAuthorizationStatus.notDetermined) {
              status = await _wifiInfo.requestLocationServiceAuthorization();
            }
            if (status == LocationAuthorizationStatus.authorizedAlways ||
                status == LocationAuthorizationStatus.authorizedWhenInUse) {
              wifiName = await _wifiInfo.getWifiName();
            } else {
              wifiName = await _wifiInfo.getWifiName();
            }
          } else {
            wifiName = await _wifiInfo.getWifiName();
          }
        } on PlatformException catch (e) {
          print(e.toString());
          wifiName = "Failed to get Wifi Name";
        }

        try {
          if (!kIsWeb && Platform.isIOS) {
            LocationAuthorizationStatus status =
            await _wifiInfo.getLocationServiceAuthorization();
            if (status == LocationAuthorizationStatus.notDetermined) {
              status = await _wifiInfo.requestLocationServiceAuthorization();
            }
            if (status == LocationAuthorizationStatus.authorizedAlways ||
                status == LocationAuthorizationStatus.authorizedWhenInUse) {
              wifiBSSID = await _wifiInfo.getWifiBSSID();
            } else {
              wifiBSSID = await _wifiInfo.getWifiBSSID();
            }
          } else {
            wifiBSSID = await _wifiInfo.getWifiBSSID();
          }
        } on PlatformException catch (e) {
          print(e.toString());
          wifiBSSID = "Failed to get Wifi BSSID";
        }

        try {
          wifiIP = await _wifiInfo.getWifiIP();
        } on PlatformException catch (e) {
          print(e.toString());
          wifiIP = "Failed to get Wifi IP";
        }

        setState(() {
          _connectionStatus = '$result\n'
              'Wifi Name: $wifiName\n'
              'Wifi BSSID: $wifiBSSID\n'
              'Wifi IP: $wifiIP\n';
        });
        break;
      case ConnectivityResult.mobile:
      case ConnectivityResult.none:
        setState(() => _connectionStatus = result.toString());
        break;
      default:
        setState(() => _connectionStatus = 'Failed to get connectivity.');
        break;
    }
  }

  String getTitle(Scenario scenario) {
    switch(scenario.index) {
      case 1:
      case 2: {
        return 'Connect Device 3/5';
      }
      break;
      case 3: {
        return 'Connect Device 2/4';
      }
      break;
      default: {
        return 'Connect Device 3/5';
      }
      break;
    }
  }

  int getIndex(Scenario scenario) {
    switch(scenario.index) {
      case 1: {
        return 11;
      }
      break;
      case 2: {
        return 22;
      }
      break;
      case 3: {
        return 33;
      }
      break;
      default: {
        return scenario.index;
      }
      break;
    }
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
      globals.g_mobileServer = wifiIp;
      _ssidController.text = _ssid;
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

  @override
  void afterFirstLayout(BuildContext context) {
    // Get the current ssid
    _getWifiName();
  }

}