import 'package:flutter/material.dart';

class Constants extends InheritedWidget {
  static Constants of(BuildContext context) => context. dependOnInheritedWidgetOfExactType<Constants>();

  const Constants({Widget child, Key key}): super(key: key, child: child);

  final String successMessage = 'Some message';
  final String DEFAULT_THE_NODE_IP = "192.168.1.199";
  final String DEFAULT_THE_NODE_DNS = "thenode"; // thenode[macaddress] example is thenode84:CC:A8:88:6E:07

  static const MODE_BURST = "burst";
  static const MODE_POLLING = "polling";
  static const MODE_SETUP = "setup";
  static const MODE_REQUEST = "request";
  static const MODE_OFFLINE = "offline";

  static const INTERVAL_SECOND_10 = 10000;
  static const INTERVAL_SECOND_30 = 30000;
  static const INTERVAL_MINUTE_1 = 60000;
  static const INTERVAL_MINUTE_5 = 300000;
  static const INTERVAL_MINUTE_30 = 1800000;
  static const INTERVAL_HOUR_1 = 3600000;
  static const INTERVAL_HOUR_2 = 7200000;
  static const INTERVAL_HOUR_3 = 10800000;
  static const INTERVAL_HOUR_4 = 14400000;

  // static const xx = TextStyle(
  //   color: Colors.white,
  //   fontFamily: 'Kanit',
  //   fontWeight: FontWeight.w300,
  //   fontSize: 12.0,
  // );
  @override
  bool updateShouldNotify(Constants oldWidget) => false;
}