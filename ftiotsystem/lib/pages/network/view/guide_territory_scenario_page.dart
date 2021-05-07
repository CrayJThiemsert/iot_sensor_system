import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gifimage/flutter_gifimage.dart';
import 'package:ftiotsystem/pages/device/choose_device.dart';
import 'package:ftiotsystem/pages/network/entity/scenario_entity.dart';
import 'package:ftiotsystem/pages/network/widget/GuidePage.dart';
import 'package:ftiotsystem/utils/sizes_helpers.dart';
import 'package:wifi/wifi.dart';

import 'package:ftiotsystem/globals.dart' as globals;

String _ssid = '';  // Wifi name

class GuideTerritoryScenarioPage extends StatefulWidget {
  const GuideTerritoryScenarioPage({
    Key key,
    @required this.scenario,
  }) : super(key: key);

  final Scenario scenario;

  @override
  _GuideTerritoryScenarioPageState createState() => new _GuideTerritoryScenarioPageState();
}

class _GuideTerritoryScenarioPageState extends State<GuideTerritoryScenarioPage> with AfterLayoutMixin<GuideTerritoryScenarioPage>, TickerProviderStateMixin {
  String _wifiName = 'click button to get wifi ssid.';
  int level = 0;
  List<WifiResult> ssidList = [];
  String ssid = '', password = '';

  var _ssidController = TextEditingController();

  GifController gifController;

  @override
  void initState() {

    gifController = GifController(vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_){
      gifController.repeat(min: 0,max: 100,period: Duration(milliseconds: 5000));
    });

    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Territory Scenario 1/5'),
        backgroundColor: Colors.cyan[400],
        centerTitle: true,
      ),
      body: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GuidePage(scenario: widget.scenario, gifController: gifController),

          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    gifController.dispose();
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