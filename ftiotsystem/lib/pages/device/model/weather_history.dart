import 'package:equatable/equatable.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:meta/meta.dart';
import 'package:validators/validators.dart';

class WeatherHistory extends Equatable {
  final String key;
  final String id;
  final String deviceId;
  final double humidity;
  final double temperature;
  final WeatherData weatherData;

  // factory WeatherHistory.fromJson(Map<dynamic, dynamic> json) {
  //   double parser(dynamic source) {
  //     try {
  //       print('source=${source.toString()}');
  //       return double.parse(source.toString());
  //     } on FormatException {
  //       return -1;
  //     }
  //   }
  //
  //   return WeatherHistory(
  //       key: json['uid'],
  //       // deviceId: json['deviceId'],
  //       // humidity: parser(json['humidity']),
  //       // temperature: parser(json['temperature'])
  //     weatherData: WeatherData.fromJson(json),
  //   );
  // }

  factory WeatherHistory.fromJson(Map<dynamic, dynamic> json) {
    var key = json.keys.first.toString();
    print('WeatherHistory.fromJson key=${key}');
    print('WeatherHistory.fromJson json[key]=${json[key]}');
    WeatherData data = WeatherData.fromJson(json[key]);
    print('data.humidity=${data.humidity}');
    return WeatherHistory(
      key: key,
      weatherData: WeatherData.fromJson(json[key]),
    );
  }

  factory WeatherHistory.fromSnapshot(DataSnapshot snap) {
    print('fromSnapshot snap.value=${snap.value}');
    return WeatherHistory(
      key: snap.key ?? '',
      // weatherData: WeatherData.fromSnapshot(snap),
      // weatherData: WeatherData.fromJson(snap.value),
      // id: snap.value['id'] ?? '',
      //
      // deviceId: snap.value['uid'] ?? '',
      // humidity: double.parse(snap.value['humidity']) ?? '-1',
      // temperature: double.parse(snap.value['temperature']) ?? '-1',
    );
  }

  const WeatherHistory(
      {this.id, this.key, this.deviceId, this.humidity, this.temperature, this.weatherData});

  @override
  List<Object> get props => [id, key, deviceId, humidity, temperature];

  static const empty = WeatherHistory(
      id: '', key: '', deviceId: '', humidity: double.nan, temperature: double.nan);

  @override
  String toString() {
    return 'User{id: $id, uid: $key, deviceId: $deviceId, humidity: $humidity, temperature: $temperature}';
  }
}

class WeatherData {
  WeatherData({
    this.uid,
    this.temperature,
    this.humidity,
    this.deviceId,
  });

  String uid;
  String deviceId;
  double temperature = double.nan;
  double humidity = double.nan;

  factory WeatherData.fromJson(Map<dynamic, dynamic> json) {
    print('WeatherData.fromJson json= ${json}');
    return WeatherData(
      uid: json['uid'],
      deviceId: json['deviceId'],
      temperature: json['temperature'].toDouble(),
      humidity: json['humidity'].toDouble(),
    );
  }

  // factory WeatherData.fromJson(Map<String, dynamic> json) => WeatherData(
  //   uid: json["uid"],
  //   temperature: json["temperature"].toDouble(),
  //   deviceId: json["deviceId"],
  //   humidity: json["humidity"].toDouble(),
  // );

  factory WeatherData.fromSnapshot(DataSnapshot snap) {
    print('WeatherData.fromSnapshot=>${snap.value.toString()}');
    print('snap deviceId=${snap.value['deviceId']}');
    print('snap humidity=${snap.value['humidity']}');
    return WeatherData(
      uid: snap.value['uid'] ?? '',
      deviceId: snap.value['deviceId'] ?? '',
      humidity: double.parse(snap.value['humidity'].toString()) ?? double.nan,
      temperature: double.parse(snap.value['temperature'].toString()) ?? double.nan,
    );
  }

  Map<String, dynamic> toJson() => {
    "uid": uid,
    "temperature": temperature,
    "humidity": humidity,
    "deviceId": deviceId,
  };

  @override
  String toString() {
    return 'User{uid: $uid, deviceId: $deviceId, humidity: $humidity, temperature: $temperature}';
  }
}