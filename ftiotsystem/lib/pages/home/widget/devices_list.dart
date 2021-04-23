import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:ftiotsystem/pages/device/entity/item_entity.dart';
import 'package:ftiotsystem/pages/device/model/device.dart';
import 'package:ftiotsystem/utils/constants.dart';

class DevicesList extends StatefulWidget {
  @override
  _DevicesListState createState() => _DevicesListState();
}

class _DevicesListState extends State<DevicesList> {
  final dbRef = FirebaseDatabase.instance.reference().child("users/cray/devices");
  // List<Map<dynamic, String>> lists = [];
  List<String> lists = [];
  List<Device> deviceLists = [];

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
                  mode: values['mode'] ?? Constants.MODE_BURST,
                  localip: values['localip'],
                ));
              });


              print('${deviceLists.toString()}');
              return GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 5.0,
                  mainAxisSpacing: 5.0,
                  scrollDirection: Axis.vertical,
                  // padding: const EdgeInsets.all(10),
                  childAspectRatio: 16/9,
                  shrinkWrap: true,
                  children: List.generate(deviceLists.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: DeviceCard(device: deviceLists[index]),
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
    final TextStyle subtitleStyle = Theme.of(context).textTheme.subtitle1;
    return Bounce(
      duration: Duration(milliseconds: 100),
      onPressed: () {
        print('on press ${widget.device.uid}');

        String uri = '/device/${widget.device.uid}';

        print('${uri} pressed...');
        Navigator.pushNamed(context, uri, arguments: widget.device);

      },
      child: Container(
        // width: 250,
        height: 280,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${widget.device.name}',
                  style: nameStyle,
                ),
                Text('${widget.device.uid}', style: subtitleStyle, textAlign: TextAlign.center,),
                // Text('${widget.device.mode}', style: subtitleStyle, textAlign: TextAlign.center,),
                Text('[${widget.device.localip}]', style: subtitleStyle, textAlign: TextAlign.center,),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
