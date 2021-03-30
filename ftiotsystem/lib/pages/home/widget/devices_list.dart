import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class DevicesList extends StatefulWidget {
  @override
  _DevicesListState createState() => _DevicesListState();
}

class _DevicesListState extends State<DevicesList> {
  final dbRef = FirebaseDatabase.instance.reference().child("users/cray/devices");
  // List<Map<dynamic, String>> lists = [];
  List<String> lists = [];
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
              Map<dynamic, dynamic> values = snapshot.data.value;
              values.forEach((key, values) {
                print('key=${key}');
                lists.add(key);
              });
              print('${lists.length}');
              return GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  shrinkWrap: true,
                  children: List.generate(lists.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Center(
                        child: Container(
                          color: Colors.amberAccent,
                          child: Text('${lists[index]}',),
                          // decoration: BoxDecoration(
                          //
                          //   // image: DecorationImage(
                          //   //   // image: NetworkImage('img.png'),
                          //   //   fit: BoxFit.cover,
                          //   // ),
                          //   borderRadius:
                          //   BorderRadius.all(Radius.circular(20.0),),
                          // ),
                        ),
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
