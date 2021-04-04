import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:ftiotsystem/pages/device/database/device_database.dart';
import 'package:ftiotsystem/pages/device/model/device.dart';
import 'package:ftiotsystem/pages/device/model/weather_history.dart';
import 'package:ftiotsystem/pages/user/model/user.dart';

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
  User user = User(uid: 'cray');

  DeviceDatabase deviceDatabase;

  _ShowDevicePageState(String deviceUid, Device device) :
  this.deviceUid = deviceUid,
  this.device = device;

  @override
  void initState() {
    super.initState();
    // Load necessary cloud database

    deviceDatabase = DeviceDatabase(device: device, user: user);
    deviceDatabase.initState();
  }

  @override
  void dispose() {
    // Dispose database
    super.dispose();
    deviceDatabase.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var deviceRef = FirebaseDatabase.instance.reference().child('users/${user.uid}/devices/${device.uid}/${device.uid}_history').orderByKey().limitToLast(1);
    // var deviceRef = FirebaseDatabase.instance.reference().child('users/${user.uid}/devices/${device.uid}/${device.uid}_history/2021-03-31 01:32:01');

    return StreamBuilder(
      // stream: deviceDatabase.getLatestHistory().onValue,
        stream: deviceRef.onValue,

      builder: (context, AsyncSnapshot<Event> snap) {
        if (snap.hasData && !snap.hasError) {
          print('=>${snap.data.snapshot.value.toString()}');
          var weatherHistory = WeatherHistory.fromJson(snap.data.snapshot.value);
          // var weatherHistory = WeatherHistory.fromSnapshot(snap.data.snapshot);
          return Scaffold(
            appBar: AppBar(
              title: Text('Device ${device.uid} Detail'),
            ),
            body: Column(
              children: [
                Container(
                  child: Text('22 C ${weatherHistory.weatherData.temperature}'),
                ),
                Container(
                  child: Text('55 % ${weatherHistory.weatherData.humidity}'),
                ),
                Center(
                  child: Container(
                    child: Text('Device ${device.uid} Detail'),
                  ),
                ),
              ],
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: Text('Device ${device.uid} Detail'),
            ),
            body: Column(
              children: [
                Container(
                  child: Text('22 C ${device}'),
                ),
                Container(
                  child: Text('55 %'),
                ),
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
    );
  }
}

