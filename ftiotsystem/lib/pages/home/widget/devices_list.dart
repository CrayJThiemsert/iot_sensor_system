// import 'package:adobe_xd/pinned.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:ftiotsystem/globals.dart' as globals;
import 'package:ftiotsystem/pages/device/model/device.dart';
import 'package:ftiotsystem/utils/constants.dart';

import 'package:intl/intl.dart';

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
    return StreamBuilder(
          stream: dbRef.onValue,
          builder: (context, AsyncSnapshot<Event> snapshot) {
            if (snapshot.hasData) {

              lists.clear();
              deviceLists.clear();
              Map<dynamic, dynamic> values = snapshot.data.snapshot.value;
              values.forEach((key, values) {
                print('key=${key}');
                print('temperature=[${values['temperature']}]');
                print('parseDouble temperature=[${globals.parseDouble(values['temperature'])}]');
                // lists.add(key);
                // deviceLists.add(Device.fromEntity(ItemEntity.fromSnapshot(snapshot.data)));
                deviceLists.add(Device(
                  id: values['id'] ?? '',
                  uid: values['uid'] ?? '',
                  // index: int.parse(values['index'].toString() ?? '-1'),
                  index: int.parse('${values['index'] ?? "0"}'),
                  name: values['name'] ?? '',
                  mode: values['mode'] ?? Constants.MODE_BURST,
                  localip: values['localip'] ?? '',
                  updatedWhen: values['updatedWhen'] ?? '2021-05-04 19:03:25',
                  readingInterval: values['readingInterval'] ?? 10000,
                  humidity: globals.parseDouble(values['humidity']) ?? 0,
                  temperature: globals.parseDouble(values['temperature'] ?? 0),
                  readVoltage: globals.parseDouble(values['readVoltage'] ?? 0),
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
          },
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
    final TextStyle numberStyle = Theme.of(context).textTheme.headline3;
    var numberFormat = NumberFormat('###.##', 'en_US');
    var voltageFormat = NumberFormat('###.0#', 'en_US');
    return Bounce(
      duration: Duration(milliseconds: 100),
      onPressed: () {
        print('on press ${widget.device.uid}');

        String uri = '/device/${widget.device.uid}';

        print('${uri} pressed...');
        Navigator.pushNamed(context, uri, arguments: widget.device);

      },
      child: Tooltip(
        message: '${widget.device.uid}\n${widget.device.localip}\n${widget.device.readVoltage}\n${widget.device.humidity}\n${widget.device.temperature}' ,
        child: Container(
          // width: 250,
          height: 280,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(top: 0.0, left: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, right: 6.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${widget.device.name}',
                          style: nameStyle,
                        ),
                        Text('${DateFormat('h:mm a').format(DateTime.parse(widget.device.updatedWhen))}',
                          style: subtitleStyle,
                        ),
                        Text('${DateFormat('EEE dd, MMM yyyy').format(DateTime.parse(widget.device.updatedWhen))}',
                          style: subtitleStyle,
                        ),
                        Text('${widget.device.readVoltage} volt',
                          style: subtitleStyle,
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Container(
                      // color: Colors.black,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10.0),
                          bottomRight: Radius.circular(10.0),
                        ),
                        color: Colors.grey[800],
                        // border: Border.all(
                        //     width: 1.0, color: const Color(0xff707070)),
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text('${numberFormat.format(widget.device.temperature)} \u2103', style: numberStyle, textAlign: TextAlign.center,),
                            Divider(
                              color: Colors.cyanAccent, //.withOpacity(0.2),
                              thickness: 1,
                              // width: 10,
                              height: 1,
                              indent: 2,
                              endIndent: 2,
                            ),
                            Text('${numberFormat.format(widget.device.humidity)} %', style: numberStyle, textAlign: TextAlign.center,),
                          ],
                      ),
                    ),
                  ),
                  // Stack(
                  //
                  // //   fit: StackFit.passthrough,
                  // //   // clipBehavior: Clip.hardEdge,
                  //   children: [
                  //     // SizedBox.expand(
                  //     //   child: Container(
                  //     //     // padding: EdgeInsets.all(0.0),
                  //     //     // color: Colors.red,
                  //     //     width: double.infinity,
                  //     //     constraints: BoxConstraints(maxHeight: 250),
                  //     //     decoration: BoxDecoration(
                  //     //
                  //     //       borderRadius: BorderRadius.only(
                  //     //         topRight: Radius.circular(10.0),
                  //     //         bottomRight: Radius.circular(10.0),
                  //     //       ),
                  //     //       color: const Color(0xff070707),
                  //     //       // border: Border.all(
                  //     //       //     width: 1.0, color: const Color(0xff707070)),
                  //     //     ),
                  //     //
                  //     //     // child: Text('xxx'),
                  //     //   ),
                  //     // ),
                  //     // Positioned(
                  //     //   // left: 10,
                  //     //   child: Container(
                  //     //     // padding: EdgeInsets.all(0.0),
                  //     //     // color: Colors.red,
                  //     //     width: double.infinity,
                  //     //     constraints: BoxConstraints(maxHeight: 250),
                  //     //     decoration: BoxDecoration(
                  //     //
                  //     //       borderRadius: BorderRadius.only(
                  //     //         topRight: Radius.circular(10.0),
                  //     //         bottomRight: Radius.circular(10.0),
                  //     //       ),
                  //     //       color: const Color(0xff070707),
                  //     //       // border: Border.all(
                  //     //       //     width: 1.0, color: const Color(0xff707070)),
                  //     //     ),
                  //     //
                  //     //     // child: Text('xxx'),
                  //     //   ),
                  //     // ),
                  // //     // Column(
                  // //     //     crossAxisAlignment: CrossAxisAlignment.start,
                  // //     //     mainAxisAlignment: MainAxisAlignment.start,
                  // //     //     mainAxisSize: MainAxisSize.min,
                  // //     //     children: [
                  // //     //       Text('${numberFormat.format(widget.device.humidity)} \u2103', style: numberStyle, textAlign: TextAlign.center,),
                  // //     //       Text('${numberFormat.format(widget.device.temperature)} %', style: numberStyle, textAlign: TextAlign.center,),
                  // //     //     ],
                  // //     // ),
                  // //     Container(
                  // //       color: Colors.red,
                  // //
                  // //       child: Text('xxx'),
                  // //     ),
                  // //     // Container(
                  // //     //   color: Colors.black,
                  // //     //   // decoration: BoxDecoration(
                  // //     //   //   borderRadius: BorderRadius.only(
                  // //     //   //     topRight: Radius.circular(15.0),
                  // //     //   //     bottomRight: Radius.circular(15.0),
                  // //     //   //   ),
                  // //     //   //   color: const Color(0xff070707),
                  // //     //   //   // border: Border.all(
                  // //     //   //   //     width: 1.0, color: const Color(0xff707070)),
                  // //     //   // ),
                  // //     // ),
                  //   ]
                  // ),
                ],
              ),


              // ========================
              // child: Pinned.fromPins(
              //   Pin(size: 123.0, end: 35.0),
              //   Pin(size: 70.0, middle: 0.4536),
              //   child: Stack(
              //     children: <Widget>[
              //       Pinned.fromPins(
              //         Pin(start: 0.0, end: 0.0),
              //         Pin(start: 0.0, end: 0.0),
              //         child: Container(
              //           decoration: BoxDecoration(
              //             borderRadius: BorderRadius.circular(15.0),
              //             color: const Color(0xffffffff),
              //             border: Border.all(
              //                 width: 1.0, color: const Color(0xff707070)),
              //           ),
              //         ),
              //       ),
              //       Pinned.fromPins(
              //         Pin(size: 59.0, end: 0.0),
              //         Pin(start: 0.0, end: 0.0),
              //         child: Container(
              //           decoration: BoxDecoration(
              //             borderRadius: BorderRadius.only(
              //               topRight: Radius.circular(15.0),
              //               bottomRight: Radius.circular(15.0),
              //             ),
              //             color: const Color(0xff070707),
              //             border: Border.all(
              //                 width: 1.0, color: const Color(0xff707070)),
              //           ),
              //         ),
              //       ),
              //       Pinned.fromPins(
              //         Pin(size: 52.0, start: 10.0),
              //         Pin(size: 19.0, start: 5.0),
              //         child: Text(
              //           'node 02',
              //           style: TextStyle(
              //             fontFamily: 'Segoe UI',
              //             fontSize: 14,
              //             color: const Color(0xff070707),
              //             fontWeight: FontWeight.w600,
              //           ),
              //           textAlign: TextAlign.left,
              //         ),
              //       ),
              //       Pinned.fromPins(
              //         Pin(size: 28.0, start: 8.0),
              //         Pin(size: 19.0, middle: 0.6275),
              //         child: Text(
              //           '15:12',
              //           style: TextStyle(
              //             fontFamily: 'Segoe UI',
              //             fontSize: 14,
              //             color: const Color(0xff070707),
              //             fontWeight: FontWeight.w300,
              //           ),
              //           textAlign: TextAlign.left,
              //         ),
              //       ),
              //       Pinned.fromPins(
              //         Pin(size: 40.0, start: 10.0),
              //         Pin(size: 16.0, end: 4.0),
              //         child: Text(
              //           'Mon 03',
              //           style: TextStyle(
              //             fontFamily: 'Segoe UI',
              //             fontSize: 12,
              //             color: const Color(0xff070707),
              //             fontWeight: FontWeight.w300,
              //           ),
              //           textAlign: TextAlign.left,
              //         ),
              //       ),
              //       Pinned.fromPins(
              //         Pin(size: 7.0, end: 5.0),
              //         Pin(size: 16.0, middle: 0.2222),
              //         child: Text(
              //           'C',
              //           style: TextStyle(
              //             fontFamily: 'Segoe UI',
              //             fontSize: 12,
              //             color: const Color(0xffc4b3b3),
              //             fontWeight: FontWeight.w700,
              //           ),
              //           textAlign: TextAlign.left,
              //         ),
              //       ),
              //       Pinned.fromPins(
              //         Pin(size: 10.0, end: 2.0),
              //         Pin(size: 16.0, middle: 0.7963),
              //         child: Text(
              //           '%',
              //           style: TextStyle(
              //             fontFamily: 'Segoe UI',
              //             fontSize: 12,
              //             color: const Color(0xffc4b3b3),
              //             fontWeight: FontWeight.w700,
              //           ),
              //           textAlign: TextAlign.left,
              //         ),
              //       ),
              //       Pinned.fromPins(
              //         Pin(size: 36.0, end: 14.0),
              //         Pin(size: 24.0, start: 8.0),
              //         child: Text(
              //           '28.5',
              //           style: TextStyle(
              //             fontFamily: 'Segoe UI',
              //             fontSize: 18,
              //             color: const Color(0xffffffff),
              //             fontWeight: FontWeight.w700,
              //           ),
              //           textAlign: TextAlign.left,
              //         ),
              //       ),
              //       Pinned.fromPins(
              //         Pin(size: 36.0, end: 14.0),
              //         Pin(size: 24.0, end: 8.0),
              //         child: Text(
              //           '63.2',
              //           style: TextStyle(
              //             fontFamily: 'Segoe UI',
              //             fontSize: 18,
              //             color: const Color(0xffffffff),
              //             fontWeight: FontWeight.w700,
              //           ),
              //           textAlign: TextAlign.left,
              //         ),
              //       ),
              //       // Pinned.fromPins(
              //       //   Pin(size: 52.0, end: 0.0),
              //       //   Pin(size: 1.0, middle: 0.5072),
              //       //   child: SvgPicture.string(
              //       //     _svg_gxva00,
              //       //     allowDrawingOutsideViewBox: true,
              //       //     fit: BoxFit.fill,
              //       //   ),
              //       // ),
              //     ],
              //   ),
              // ),
              // ======================
            ),
          ),
        ),
      ),
    );
  }
}
