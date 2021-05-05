import 'package:after_layout/after_layout.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:ftiotsystem/pages/device/database/device_database.dart';
import 'package:ftiotsystem/pages/device/model/device.dart';
import 'package:ftiotsystem/pages/device/model/weather_history.dart';
import 'package:ftiotsystem/pages/user/model/user.dart';
import 'package:ftiotsystem/utils/constants.dart';

import 'package:http/http.dart' as http;
import 'package:ftiotsystem/globals.dart' as globals;

class ShowDevicePage extends StatefulWidget {
  String deviceUid;
  Device device;

  ShowDevicePage({this.deviceUid, this.device});

  @override
  _ShowDevicePageState createState() => _ShowDevicePageState(deviceUid, device);
}

class _ShowDevicePageState extends State<ShowDevicePage> with AfterLayoutMixin<ShowDevicePage> {
  String deviceUid;
  Device device;
  User user = User(uid: 'cray');
  DeviceDatabase deviceDatabase;

  bool sec10Pressed = false;
  bool sec30Pressed = false;
  bool min1Pressed = false;
  bool min5Pressed = false;
  bool min30Pressed = false;
  bool hour1Pressed = false;
  bool hour2Pressed = false;
  bool hour3Pressed = false;
  bool hour4Pressed = false;

  bool burstePressed = false;
  bool requestPressed = false;
  bool pollingPressed = false;
  bool offlinePressed = false;

  int selectedInterval = 5000; // milliseconds

  _ShowDevicePageState(String deviceUid, Device device)
      : this.deviceUid = deviceUid,
        this.device = device;

  @override
  void initState() {
    super.initState();
    // Load necessary cloud database
    // may be not use
    deviceDatabase = DeviceDatabase(device: device, user: user);
    // deviceDatabase.initState();
  }

  @override
  void dispose() {
    // Dispose database.
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
    final TextStyle unitStyle = Theme.of(context).textTheme.headline2;
    final TextStyle headlineStyle = Theme.of(context).textTheme.headline1;

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
                                    '${globals.formatNumber(weatherHistory?.weatherData?.temperature) ?? ''}',
                                    style: headlineStyle,
                                    // style: TextStyle(
                                    //   color: Colors.white,
                                    //   fontFamily: 'Kanit',
                                    //   fontWeight: FontWeight.w300,
                                    //   fontSize: 36.0,
                                    // ),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    'Temperature (\u2103)',
                                    style: unitStyle,
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
                                    '${globals.formatNumber(weatherHistory?.weatherData?.humidity) ?? ''}',
                                    style: headlineStyle,
                                    // style: TextStyle(
                                    //   color: Colors.white,
                                    //   fontFamily: 'Kanit',
                                    //   fontWeight: FontWeight.w300,
                                    //   fontSize: 36.0,
                                    // ),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    'Humidity (%)',
                                    style: unitStyle,
                                    // style: TextStyle(
                                    //   color: Colors.white,
                                    //   fontFamily: 'Kanit',
                                    //   fontWeight: FontWeight.w300,
                                    //   fontSize: 12.0,
                                    // ),
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
                  Center(
                    child: Container(
                      child: Text('latest when ${weatherHistory?.weatherData?.uid ?? 'no data'}'),
                    ),
                  ),
                  Center(
                    child: Container(
                      // child: Text('battery voltage ${weatherHistory?.weatherData?.readVoltage.toStringAsFixed(weatherHistory?.weatherData?.readVoltage.truncateToDouble() == weatherHistory?.weatherData?.readVoltage ? 0 : 2) ?? 'no data'} volts'),
                      // child: Text('battery voltage ${globals.formatNumber(weatherHistory?.weatherData?.readVoltage) ?? 'no data'} volts'),
                      child: Text('battery voltage ${weatherHistory?.weatherData?.readVoltage ?? 'no data'} volts'),
                    ),
                  ),
                  buildReadingIntervalCard(context),
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

  Card buildWorkingModeCard(BuildContext context) {
    return Card(
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
                );
  }

  Card buildReadingIntervalCard(BuildContext context) {
    // draw card
    final TextStyle inactiveStyle = Theme.of(context).textTheme.headline5;
    final TextStyle activeStyle = Theme.of(context).textTheme.headline6;
    return Card(
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                    setState(() {
                      sec10Pressed = !sec10Pressed;
                      sec30Pressed = false;
                      min1Pressed = false;
                      min5Pressed = false;
                      min30Pressed = false;
                      hour1Pressed = false;
                      hour2Pressed = false;
                      hour3Pressed = false;
                      hour4Pressed = false;

                      selectedInterval = 10000;
                      updateReadingInterval();
                    });
              },
              child: Container(
                child: Column(
                  children: [
                    Text('10', style: sec10Pressed ? activeStyle : inactiveStyle,),
                    Text('sec', style: sec10Pressed ? Theme.of(context).textTheme.subtitle2 : Theme.of(context).textTheme.subtitle1,),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  sec10Pressed = false;
                  sec30Pressed = !sec30Pressed;
                  min1Pressed = false;
                  min5Pressed = false;
                  min30Pressed = false;
                  hour1Pressed = false;
                  hour2Pressed = false;
                  hour3Pressed = false;
                  hour4Pressed = false;

                  selectedInterval = 30000;
                  updateReadingInterval();
                });
              },
              child: Container(
                child: Column(
                  children: [
                    Text('30', style: sec30Pressed ? activeStyle : inactiveStyle,),
                    Text('sec', style: sec30Pressed ? Theme.of(context).textTheme.subtitle2 : Theme.of(context).textTheme.subtitle1,),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  sec10Pressed = false;
                  sec30Pressed = false;
                  min1Pressed = !min1Pressed;
                  min5Pressed = false;
                  min30Pressed = false;
                  hour1Pressed = false;
                  hour2Pressed = false;
                  hour3Pressed = false;
                  hour4Pressed = false;

                  selectedInterval = 60000;
                  updateReadingInterval();
                });
              },
              child: Container(
                child: Column(
                  children: [
                    Text('1', style: min1Pressed ? activeStyle : inactiveStyle,),
                    Text('min', style: min1Pressed ? Theme.of(context).textTheme.subtitle2 : Theme.of(context).textTheme.subtitle1,),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  sec10Pressed = false;
                  sec30Pressed = false;
                  min1Pressed = false;
                  min5Pressed = !min5Pressed;
                  min30Pressed = false;
                  hour1Pressed = false;
                  hour2Pressed = false;
                  hour3Pressed = false;
                  hour4Pressed = false;

                  selectedInterval = 300000;
                  updateReadingInterval();
                });
              },
              child: Container(
                child: Column(
                  children: [
                    Text('5', style: min5Pressed ? activeStyle : inactiveStyle,),
                    Text('min', style: min5Pressed ? Theme.of(context).textTheme.subtitle2 : Theme.of(context).textTheme.subtitle1,),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  sec10Pressed = false;
                  sec30Pressed = false;
                  min1Pressed = false;
                  min5Pressed = false;
                  min30Pressed = !min30Pressed;
                  hour1Pressed = false;
                  hour2Pressed = false;
                  hour3Pressed = false;
                  hour4Pressed = false;

                  selectedInterval = 1800000;
                  updateReadingInterval();
                });
              },
              child: Container(
                child: Column(
                  children: [
                    Text('30', style: min30Pressed ? activeStyle : inactiveStyle,),
                    Text('min', style: min30Pressed ? Theme.of(context).textTheme.subtitle2 : Theme.of(context).textTheme.subtitle1,),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  sec10Pressed = false;
                  sec30Pressed = false;
                  min1Pressed = false;
                  min5Pressed = false;
                  min30Pressed = false;
                  hour1Pressed = !hour1Pressed;
                  hour2Pressed = false;
                  hour3Pressed = false;
                  hour4Pressed = false;

                  selectedInterval = 3600000;
                  updateReadingInterval();
                });
              },
              child: Container(
                child: Column(
                  children: [
                    Text('1', style: hour1Pressed ? activeStyle : inactiveStyle,),
                    Text('hour', style: hour1Pressed ? Theme.of(context).textTheme.subtitle2 : Theme.of(context).textTheme.subtitle1,),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  sec10Pressed = false;
                  sec30Pressed = false;
                  min1Pressed = false;
                  min5Pressed = false;
                  min30Pressed = false;
                  hour1Pressed = false;
                  hour2Pressed = !hour2Pressed;
                  hour3Pressed = false;
                  hour4Pressed = false;

                  selectedInterval = 7200000;
                  updateReadingInterval();
                });
              },
              child: Container(
                child: Column(
                  children: [
                    Text('2', style: hour2Pressed ? activeStyle : inactiveStyle,),
                    Text('hour', style: hour2Pressed ? Theme.of(context).textTheme.subtitle2 : Theme.of(context).textTheme.subtitle1,),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  sec10Pressed = false;
                  sec30Pressed = false;
                  min1Pressed = false;
                  min5Pressed = false;
                  min30Pressed = false;
                  hour1Pressed = false;
                  hour2Pressed = false;
                  hour3Pressed = !hour3Pressed;
                  hour4Pressed = false;

                  selectedInterval = 10800000;
                  updateReadingInterval();
                });
              },
              child: Container(
                child: Column(
                  children: [
                    Text('3', style: hour3Pressed ? activeStyle : inactiveStyle,),
                    Text('hour', style: hour3Pressed ? Theme.of(context).textTheme.subtitle2 : Theme.of(context).textTheme.subtitle1,),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  sec10Pressed = false;
                  sec30Pressed = false;
                  min1Pressed = false;
                  min5Pressed = false;
                  min30Pressed = false;
                  hour1Pressed = false;
                  hour2Pressed = false;
                  hour3Pressed = false;
                  hour4Pressed = !hour4Pressed;

                  selectedInterval = 14400000;
                  updateReadingInterval();
                });
              },
              child: Container(
                child: Column(
                  children: [
                    Text('4', style: hour4Pressed ? activeStyle : inactiveStyle,),
                    Text('hour', style: hour4Pressed ? Theme.of(context).textTheme.subtitle2 : Theme.of(context).textTheme.subtitle1,),
                  ],
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

  /**
   * First contact to "the Node" to pass reading interval value
   */
  Future<http.Response> updateReadingInterval() async {
    // update reading interval in cloud database
    // deviceDatabase.updateDevice(device);
    print('update reading interval in cloud database - users/${user.uid}/devices/${device.uid}');
    var deviceRef = FirebaseDatabase.instance
        .reference()
        .child('users/${user.uid}/devices/${device.uid}')
        .update({
      // 'name':  device.name,
      'readingInterval': selectedInterval,
    });

    // Hostname on device detail page
    String hostName = '';
    String hostIp = '';
    String macAddressWithoutColon = hostName = device.uid.replaceAll(':', '');
    hostName = '${Constants.of(context).DEFAULT_THE_NODE_DNS}${macAddressWithoutColon.toLowerCase()}.local';
    hostIp = '${device.localip}:80';
    print('hostName=${hostName}');
    print('host local ip address=${hostIp}');
    print('Device reading interval[${selectedInterval}] - setting...');
    var url =
    // Uri.https('www.googleapis.com', '/books/v1/volumes', {'q': '{http}'});
    //   Uri.http(hostName, '/setting', {'interval': selectedInterval.toString()});
    // Change to use local ip address of each device to be send request to update device setting from "theApp".
      Uri.http(hostIp, '/setting', {'interval': selectedInterval.toString()});

    // Await the http get response, then decode the json-formatted response.
    final response = await http.get(url);
    print("status code =${response.statusCode}");
    if (response.statusCode == 200) {
      print('Device reading interval[${selectedInterval}] - setting is ok!!');
    } else {
      print('Device reading interval[${selectedInterval}] - setting is not ok!!');
      throw Exception('Failed to do wifi settings');
    }




    return response;
  }

  @override
  void afterFirstLayout(BuildContext context) {
    switch(device.readingInterval) {
      case Constants.INTERVAL_SECOND_10: {
        setState(() {
          sec10Pressed = true;
          sec30Pressed = false;
          min1Pressed = false;
          min5Pressed = false;
          min30Pressed = false;
          hour1Pressed = false;
          hour2Pressed = false;
          hour3Pressed = false;
          hour4Pressed = false;
        });
      }
      break;

      case Constants.INTERVAL_SECOND_30: {
        setState(() {
          sec10Pressed = false;
          sec30Pressed = true;
          min1Pressed = false;
          min5Pressed = false;
          min30Pressed = false;
          hour1Pressed = false;
          hour2Pressed = false;
          hour3Pressed = false;
          hour4Pressed = false;
        });
      }
      break;

      case Constants.INTERVAL_MINUTE_1: {
        setState(() {
          sec10Pressed = false;
          sec30Pressed = false;
          min1Pressed = true;
          min5Pressed = false;
          min30Pressed = false;
          hour1Pressed = false;
          hour2Pressed = false;
          hour3Pressed = false;
          hour4Pressed = false;
        });
      }
      break;

      case Constants.INTERVAL_MINUTE_5: {
        setState(() {
          sec10Pressed = false;
          sec30Pressed = false;
          min1Pressed = false;
          min5Pressed = true;
          min30Pressed = false;
          hour1Pressed = false;
          hour2Pressed = false;
          hour3Pressed = false;
          hour4Pressed = false;
        });
      }
      break;

      case Constants.INTERVAL_MINUTE_30: {
        setState(() {
          sec10Pressed = false;
          sec30Pressed = false;
          min1Pressed = false;
          min5Pressed = false;
          min30Pressed = true;
          hour1Pressed = false;
          hour2Pressed = false;
          hour3Pressed = false;
          hour4Pressed = false;
        });
      }
      break;

      case Constants.INTERVAL_HOUR_1: {
        setState(() {
          sec10Pressed = false;
          sec30Pressed = false;
          min1Pressed = false;
          min5Pressed = false;
          min30Pressed = false;
          hour1Pressed = true;
          hour2Pressed = false;
          hour3Pressed = false;
          hour4Pressed = false;
        });
      }
      break;

      case Constants.INTERVAL_HOUR_2: {
        setState(() {
          sec10Pressed = false;
          sec30Pressed = false;
          min1Pressed = false;
          min5Pressed = false;
          min30Pressed = false;
          hour1Pressed = false;
          hour2Pressed = true;
          hour3Pressed = false;
          hour4Pressed = false;
        });
      }
      break;

      case Constants.INTERVAL_HOUR_3: {
        setState(() {
          sec10Pressed = false;
          sec30Pressed = false;
          min1Pressed = false;
          min5Pressed = false;
          min30Pressed = false;
          hour1Pressed = false;
          hour2Pressed = false;
          hour3Pressed = true;
          hour4Pressed = false;
        });
      }
      break;

      case Constants.INTERVAL_HOUR_4: {
        setState(() {
          sec10Pressed = false;
          sec30Pressed = false;
          min1Pressed = false;
          min5Pressed = false;
          min30Pressed = false;
          hour1Pressed = false;
          hour2Pressed = false;
          hour3Pressed = false;
          hour4Pressed = true;
        });
      }
      break;

      default: {
        setState(() {
          sec10Pressed = false;
          sec30Pressed = true;
          min1Pressed = false;
          min5Pressed = false;
          min30Pressed = false;
          hour1Pressed = false;
          hour2Pressed = false;
          hour3Pressed = false;
          hour4Pressed = false;
        });
      }
      break;

    }
    // switch(device.mode) {
    //   case Constants.MODE_BURST: {
    //     burstePressed = true;
    //     requestPressed = false;
    //     pollingPressed = false;
    //     offlinePressed = false;
    //   }
    //   break;
    //
    //   case Constants.MODE_REQUEST: {
    //     burstePressed = false;
    //     requestPressed = true;
    //     pollingPressed = false;
    //     offlinePressed = false;
    //   }
    //   break;
    //
    //   case Constants.MODE_POLLING: {
    //     burstePressed = false;
    //     requestPressed = false;
    //     pollingPressed = true;
    //     offlinePressed = false;
    //   }
    //   break;
    //
    //   case Constants.MODE_OFFLINE: {
    //     burstePressed = false;
    //     requestPressed = false;
    //     pollingPressed = false;
    //     offlinePressed = true;
    //   }
    //   break;
    //
    //   default: {
    //     burstePressed = false;
    //     requestPressed = false;
    //     pollingPressed = false;
    //     offlinePressed = false;
    //   }
    //   break;
    //
    // }
  }
}
