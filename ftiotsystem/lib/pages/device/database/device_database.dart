import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebaseauth;
import 'package:firebase_database/firebase_database.dart';
import 'package:ftiotsystem/pages/device/model/device.dart';
import 'package:ftiotsystem/pages/device/model/weather_history.dart';
import 'package:ftiotsystem/pages/user/model/user.dart';


class DeviceDatabase {
  DatabaseReference _deviceRef;
  DatabaseReference _historyRef;
  StreamSubscription<Event> _historyrSubscription;
  StreamSubscription<Event> _messagesSubscription;
  FirebaseDatabase database = new FirebaseDatabase();
  WeatherHistory _weatherHistoryValue;
  DatabaseError error;

  User user = User();
  Device device = Device();

  static final Map<String, DeviceDatabase> _instance =
  <String, DeviceDatabase>{};

  DeviceDatabase.internal(this.user, this.device);



  factory DeviceDatabase({User user, Device device}) {

    return _instance.putIfAbsent(device.uid, () => DeviceDatabase.internal(user, device));
  }

  void initState() {
    // Demonstrates configuring to the database using a file
    print('user.uid=${user.uid}');
    // _historyRef = FirebaseDatabase.instance.reference().child('users/${user.uid}/devices/${device.uid}/${device.uid}_history').orderByKey().limitToFirst(1);
    _historyRef = FirebaseDatabase.instance.reference().child('users/${user.uid}/devices/${device.uid}/${device.uid}_history');
    // _historyRef = FirebaseDatabase.instance.reference().child('users/cray/devices/${device.uid}/${device.uid}_history').orderByKey().limitToFirst(1);
    // Demonstrates configuring the database directly
    // _deviceRef = database.reference().child('users/${user.uid}/devices/${device.uid}');
    // database.reference().child('counter').once().then((DataSnapshot snapshot) {
    //   print('Connected to second database and read ${snapshot.value}');
    // });
    database.setPersistenceEnabled(true);
    database.setPersistenceCacheSizeBytes(10000000);
    _historyRef.keepSynced(true);

    _historyrSubscription = _historyRef.onValue.listen((Event event) {
      error = null;
      _weatherHistoryValue = event.snapshot.value ?? 0;
    }, onError: (Object o) {
      error = o;
    });
  }

  DatabaseError getError() {
    return error;
  }

  WeatherHistory getWeatherHistoryValue() {
    return _weatherHistoryValue;
  }

  DatabaseReference getLatestHistory() {
    return _historyRef;
  }

  DatabaseReference getUser() {
    return _deviceRef;
  }

  // addUser(User user) async {
  //   final TransactionResult transactionResult =
  //   await _historyRef.runTransaction((MutableData mutableData) async {
  //     mutableData.value = (mutableData.value ?? 0) + 1;
  //
  //     return mutableData;
  //   });
  //
  //   if (transactionResult.committed) {
  //     _deviceRef.push().set(<String, String>{
  //       "name": "" + user.name,
  //       "age": "" + user.age,
  //       "email": "" + user.email,
  //       "mobile": "" + user.mobile,
  //     }).then((_) {
  //       print('Transaction  committed.');
  //     });
  //   } else {
  //     print('Transaction not committed.');
  //     if (transactionResult.error != null) {
  //       print(transactionResult.error.message);
  //     }
  //   }
  // }
  //
  // void deleteUser(User user) async {
  //   await _deviceRef.child(user.id).remove().then((_) {
  //     print('Transaction  committed.');
  //   });
  // }
  //
  void updateDevice(Device device) async {
    await _deviceRef.child(device.uid).update({
      'name':  device.name,
      'readingInterval': device.readingInterval,
    }).then((_) {
      print('Transaction  committed.');
    });
  }

  void dispose() {
    _messagesSubscription.cancel();
    _historyrSubscription.cancel();
  }


}