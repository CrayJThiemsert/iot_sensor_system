import 'package:flutter/material.dart';

class Constants extends InheritedWidget {
  static Constants of(BuildContext context) => context. dependOnInheritedWidgetOfExactType<Constants>();

  const Constants({Widget child, Key key}): super(key: key, child: child);

  final String successMessage = 'Some message';
  final String DEFAULT_THE_NODE_IP = "192.168.1.199";

  @override
  bool updateShouldNotify(Constants oldWidget) => false;
}