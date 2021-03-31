import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:ftiotsystem/pages/device/entity/item_entity.dart';
import 'package:ftiotsystem/pages/device/model/device.dart';

class DevicesList extends StatefulWidget {
  @override
  _DevicesListState createState() => _DevicesListState();
}

class _DevicesListState extends State<DevicesList> {
  final dbRef = FirebaseDatabase.instance.reference().child("users/cray/devices");
  // List<Map<dynamic, String>> lists = [];
  List<String> lists = [];
  List<Device> deviceLists = [];
  List<String> images = [
    "assets/Apples.png",
    "assets/Bananas.png",
    "assets/Cherries.png",
    "assets/Grapes.png",
    "assets/Oranges.png",
    "assets/Peaches.png",
    "assets/Plumbs.png",
    "assets/Rasberries.png",
    "assets/Strawberries.png",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
          future: dbRef.once(),
          builder: (context, AsyncSnapshot<DataSnapshot> snapshot) {
            if (snapshot.hasData) {

              lists.clear();
              deviceLists.clear();
              Map<dynamic, dynamic> values = snapshot.data.value;
              values.forEach((key, values) {
                print('key=${key}');
                // lists.add(key);
                // deviceLists.add(Device.fromEntity(ItemEntity.fromSnapshot(snapshot.data)));
                deviceLists.add(Device(
                  id: values['id'],
                  uid: values['uid'],
                  // index: int.parse(values['index'].toString() ?? '-1'),
                  index: int.parse('${values['index'] ?? "0"}'),
                  name: values['name'],
                ));
              });


              print('${deviceLists.toString()}');
              return GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                  shrinkWrap: true,
                  children: List.generate(deviceLists.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Center(
                        child: DeviceCard(device: deviceLists[index]),
                      ),
                    );
                  },),
              );
              // return Center(
              //   child: Container(
              //     child: GridView.builder(
              //       itemCount: images.length,
              //       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              //         crossAxisCount: 2,
              //         crossAxisSpacing: 5.0,
              //         mainAxisSpacing: 5.0,
              //       ),
              //       itemBuilder: (BuildContext context, int index) {
              //         return Text(
              //           images[index].toString(),
              //         );
              //       },
              //     ),
              //   ),
              // );
              // return new ListView.builder(
              //     shrinkWrap: true,
              //     itemCount: values.length,// lists.length,
              //     itemBuilder: (BuildContext context, int index) {
              //       return Card(
              //         child: Column(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: <Widget>[
              //             Text(lists[index].toString()),
              //             // Text("Humidity: " + lists[index]["humidity"]),
              //             // Text("Temperature: "+ lists[index]["temperature"]),
              //           ],
              //         ),
              //       );
              //     });
            }
            return CircularProgressIndicator();
          }),
    );

    // return Container(
    //   child: FutureBuilder(
    //       future: dbRef.once(),
    //       builder: (context, AsyncSnapshot<DataSnapshot> snapshot) {
    //         if (snapshot.hasData) {
    //           lists.clear();
    //           Map<dynamic, dynamic> values = snapshot.data.value;
    //           values.forEach((key, values) {
    //             lists.add(values);
    //           });
    //           return new ListView.builder(
    //               shrinkWrap: true,
    //               itemCount: lists.length,
    //               itemBuilder: (BuildContext context, int index) {
    //                 return Card(
    //                   child: Column(
    //                     crossAxisAlignment: CrossAxisAlignment.start,
    //                     children: <Widget>[
    //                       Text("Humidity: " + lists[index].keys[index].toString()),
    //                       // Text("Humidity: " + lists[index]["humidity"]),
    //                       // Text("Temperature: "+ lists[index]["temperature"]),
    //                     ],
    //                   ),
    //                 );
    //               });
    //         }
    //         return CircularProgressIndicator();
    //       }),
    // );
  }
}

class DeviceCard extends StatelessWidget {
  const DeviceCard({
    Key key,
    @required this.device,
  }) : super(key: key);

  final Device device;

  @override
  Widget build(BuildContext context) {
    final TextStyle nameStyle = Theme.of(context).textTheme.caption;
    final TextStyle textStyle = Theme.of(context).textTheme.button;
    return Card(
      color: Colors.amberAccent,
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('${device.uid}', style: textStyle,),
            Text('${device.name}', style: nameStyle, textAlign: TextAlign.center,),
          ],
        ),
      ),
    );
  }
}
