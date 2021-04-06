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

  bool burstePressed = false;
  bool requestPressed = false;
  bool pollingPressed = false;
  bool offlinePressed = false;

  _ShowDevicePageState(String deviceUid, Device device)
      : this.deviceUid = deviceUid,
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

    var deviceRef = FirebaseDatabase.instance
        .reference()
        .child('users/${user.uid}/devices/${device.uid}/${device.uid}_history')
        .orderByKey()
        .limitToLast(1);
    // var deviceRef = FirebaseDatabase.instance.reference().child('users/${user.uid}/devices/${device.uid}/${device.uid}_history/2021-03-31 01:32:01');

    return StreamBuilder(
        // stream: deviceDatabase.getLatestHistory().onValue,
        stream: deviceRef.onValue,
        builder: (context, AsyncSnapshot<Event> snap) {
          if (snap.hasData && !snap.hasError) {
            print('=>${snap.data.snapshot.value.toString()}');
            var weatherHistory =
                WeatherHistory.fromJson(snap.data.snapshot.value);
            // var weatherHistory = WeatherHistory.fromSnapshot(snap.data.snapshot);
            return Scaffold(
              appBar: AppBar(
                title: Text('${device.name ?? device.uid} Detail'),
              ),
              body: Column(
                children: [
                  SizedBox(height: 50,),
                  Center(
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: new BoxDecoration(
                        color: Colors.lightGreen.shade800,
                        border: Border.all(color: Colors.green.shade400, width: 8.0),
                        borderRadius: new BorderRadius.all(Radius.circular(150.0)),
                      ),
                      child: IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                SizedBox(height: 50,),
                                Container(
                                  child: Text(
                                    '${weatherHistory.weatherData.temperature}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Kanit',
                                      fontWeight: FontWeight.w300,
                                      fontSize: 36.0,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    'Temperature (\u2103)',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Kanit',
                                      fontWeight: FontWeight.w300,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            VerticalDivider(
                              color: Colors.grey.withOpacity(0.2),
                              thickness: 2,
                              // width: 10,
                              indent: 10,
                              endIndent: 10,
                            ),

                            Column(
                              children: [
                                SizedBox(height: 50,),
                                Container(
                                  child: Text(
                                    '${weatherHistory.weatherData.humidity}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Kanit',
                                      fontWeight: FontWeight.w300,
                                      fontSize: 36.0,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    'Humidity (%)',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Kanit',
                                      fontWeight: FontWeight.w300,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 50,),
                  Center(
                    child: Container(
                      child: Text('Device ${device.name ?? device.uid} Detail'),
                    ),
                  ),
                  Card(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            child: Column(
                              children: [
                                IconButton(
                                  color: burstePressed ? Colors.lightGreen : Colors.grey,
                                  icon: const Icon(Icons.autorenew),
                                  tooltip: 'Continue read sensor value every short time period',
                                  onPressed: () {
                                    setState(() {
                                      burstePressed = !burstePressed;
                                      requestPressed = false;
                                      pollingPressed = false;
                                      offlinePressed = false;
                                    });
                                  },
                                ),
                                Text('Burst', style: burstePressed ? Theme.of(context).textTheme.subtitle2 : Theme.of(context).textTheme.subtitle1,),
                              ],
                            ),

                          ),
                        ),
                        Expanded(
                          child: Container(
                            child: Column(
                              children: [
                                IconButton(
                                  color: requestPressed ? Colors.lightGreen : Colors.grey,
                                  icon: const Icon(Icons.wifi_calling),
                                  tooltip: 'Read sensor by request',
                                  onPressed: () {
                                    setState(() {
                                      burstePressed = false;
                                      requestPressed = !requestPressed;
                                      pollingPressed = false;
                                      offlinePressed = false;
                                    });
                                  },
                                ),
                                Text('Request', style: requestPressed ? Theme.of(context).textTheme.subtitle2 : Theme.of(context).textTheme.subtitle1,),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            child: Column(
                              children: [
                                IconButton(
                                  color: pollingPressed ? Colors.lightGreen : Colors.grey,
                                  icon: const Icon(Icons.battery_alert),
                                  tooltip: 'Read sensor value every long time period to safe battery life time',
                                  onPressed: () {
                                    setState(() {
                                      burstePressed = false;
                                      requestPressed = false;
                                      pollingPressed = !pollingPressed;
                                      offlinePressed = false;
                                    });
                                  },
                                ),
                                Text('Polling', style: pollingPressed ? Theme.of(context).textTheme.subtitle2 : Theme.of(context).textTheme.subtitle1,),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            child: Column(
                              children: [
                                IconButton(
                                  color: offlinePressed ? Colors.lightGreen : Colors.grey,
                                  icon: const Icon(Icons.wifi_off),
                                  tooltip: 'Save read sensor value in "the Node" local memory',
                                  onPressed: () {
                                    setState(() {
                                      burstePressed = false;
                                      requestPressed = false;
                                      pollingPressed = false;
                                      offlinePressed = !offlinePressed;
                                    });
                                  },
                                ),
                                Text('Offline', style: offlinePressed ? Theme.of(context).textTheme.subtitle2 : Theme.of(context).textTheme.subtitle1,),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Scaffold(
              appBar: AppBar(
                title: Text('${device.name ?? device.uid} Detail'),
              ),
              body: Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.amberAccent,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.brown),
                  strokeWidth: 3,
                ),
              )
            );
          }
        });
  }
}
