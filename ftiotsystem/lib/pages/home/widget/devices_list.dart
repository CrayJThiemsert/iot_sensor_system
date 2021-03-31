import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
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
                  crossAxisCount: 2,
                  crossAxisSpacing: 2.0,
                  mainAxisSpacing: 10.0,
                  padding: const EdgeInsets.all(20),
                  shrinkWrap: true,
                  children: List.generate(deviceLists.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: DeviceCard(device: deviceLists[index]),
                      ),
                    );
                  },),
              );
            }
            return CircularProgressIndicator();
          }),
    );

  }
}

class DeviceCard extends StatefulWidget {
  const DeviceCard({
    Key key,
    @required this.device,
  }) : super(key: key);

  final Device device;

  @override
  _DeviceCardState createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  @override
  Widget build(BuildContext context) {
    final TextStyle nameStyle = Theme.of(context).textTheme.caption;
    final TextStyle textStyle = Theme.of(context).textTheme.button;
    return Bounce(
      duration: Duration(milliseconds: 100),
      onPressed: () {
        print('on press ${widget.device.uid}');

        String uri = '/device/${widget.device.uid}';

        print('${uri} pressed...');
        Navigator.pushNamed(context, uri, arguments: widget.device);

      },
      child: Card(
        color: Colors.amberAccent,
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('${widget.device.uid}',
                  style: textStyle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text('${widget.device.name}', style: nameStyle, textAlign: TextAlign.center,),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
