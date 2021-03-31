import 'package:flutter/material.dart';
import 'package:ftiotsystem/pages/device/model/device.dart';

class ShowDevicePage extends StatefulWidget {
  String deviceUid;
  Device device;

  ShowDevicePage({this.deviceUid, this.device});

  @override
  _ShowDevicePageState createState() => _ShowDevicePageState(deviceUid, device);
}

class _ShowDevicePageState extends State<ShowDevicePage> {
  String deviceUid;
  Device device;

  _ShowDevicePageState(String deviceUid, Device device) :
  this.deviceUid = deviceUid,
  this.device = device;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Device ${device.uid} Detail'),
      ),
      body: Column(
        children: [
          Center(
            child: Container(
              child: Text('Device ${device.uid} Detail'),
            ),
          ),
        ],
      ),
    );
  }
}
