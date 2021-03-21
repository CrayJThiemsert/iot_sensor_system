import 'dart:async';
import 'dart:io';

import 'package:esptouch_flutter/esptouch_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wifi/wifi.dart';

void main() => runApp(new MyApp());

String _ssid = '';  // Wifi name
String _bssid = 'AA:CC:A8:88:5B:AC'; // Dummy WiFi BSSID
String _password = '';  // Wifi password

void executeEsptouch() {
  print("_ssid=${_ssid} _password=${_password}");
  final task = ESPTouchTask(ssid: _ssid, bssid: _bssid, password: _password);
  final Stream<ESPTouchResult> stream = task.execute();
  final sub = stream.listen((r) {
    print('Received IP: ${r.ip} MAC: ${r.bssid}');
  });
  Future.delayed(Duration(minutes: 1), () => sub.cancel());

}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Wifi',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  Socket channel;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _wifiName = 'click button to get wifi ssid.';
  int level = 0;
  String _ip = 'click button to get ip.';
  List<WifiResult> ssidList = [];
  String ssid = '', password = '';

  var _ssidController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wifi'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: EdgeInsets.all(8.0),
          itemCount: ssidList.length + 1,
          itemBuilder: (BuildContext context, int index) {
            return itemSSID(index);
          },
        ),
      ),
    );
  }

  Widget itemSSID(index) {
    if (index == 0) {
      return Column(
        children: [
          Row(
            children: <Widget>[
              ElevatedButton(
                child: Text('ssid'),
                onPressed: _getWifiName,
              ),
              Offstage(
                offstage: level == 0,
                child: Image.asset(level == 0 ? 'images/wifi1.png' : 'images/wifi$level.png', width: 28, height: 21),
              ),
              Text(_wifiName,
                textAlign: TextAlign.left,
              ),
            ],
          ),
          Row(
            children: <Widget>[
              ElevatedButton(
                child: Text('ip'),
                onPressed: _getIP,
              ),
              Text(_ip,
                textAlign: TextAlign.left,
              ),
            ],
          ),
          TextField(
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              filled: true,
              icon: Icon(Icons.wifi),
              hintText: 'Your wifi ssid',
              labelText: 'ssid',
            ),
            keyboardType: TextInputType.text,
            controller: _ssidController,
            onChanged: (value) {
              ssid = value;
            },
          ),
          TextField(
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              filled: true,
              icon: Icon(Icons.lock_outline),
              hintText: 'Your wifi password',
              labelText: 'password',
            ),
            keyboardType: TextInputType.text,
            onChanged: (value) {
              password = value;
              _password = password;
            },
          ),
          ElevatedButton(
            child: Text('connection'),
            // onPressed: connection,
            onPressed: executeEsptouch,
          ),

          ElevatedButton(
            child: Text("AC On/Off",
                style: TextStyle(
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    fontSize: 20.0
                )
            ),
            onPressed: _togglePower,
          ),
          ElevatedButton(
            child: Text("Fan",
                style: TextStyle(
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    fontSize: 20.0
                )
            ),
            onPressed: _fan,
          ),
          ElevatedButton(
            child: Text("Mode",
                style: TextStyle(
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    fontSize: 20.0
                )
            ),
            onPressed: _mode,
          ),
        ],
      );
    } else {
      return Column(children: <Widget>[
        ListTile(
          leading: Image.asset('images/wifi${ssidList[index - 1].level}.png', width: 28, height: 21),
          title: Text(
            "${ssidList[index - 1].level} ${ssidList[index - 1].ssid} " ,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16.0,
            ),
          ),
          dense: true,
        ),
        Divider(),
      ]);
    }
  }

  void _togglePower() {
    print("call _togglePower...");
    // widget.channel.write("POWER\n");
  }

  void _fan() {
    widget.channel.write("FAN\n");
  }

  void _mode() {
    widget.channel.write("MODE\n");
  }

  @override
  void dispose() {
    widget.channel.close();
    super.dispose();
  }

  void loadData() async {
    Wifi.list('').then((list) {
      setState(() {
        ssidList = list;
      });
    });
  }

  Future<Null> _getWifiName() async {
    int l = await Wifi.level;
    String wifiName = await Wifi.ssid;
    String wifiIp = await Wifi.ip;
    setState(() {
      level = l;
      _wifiName = "${wifiName}";
      _ssid = _wifiName;
      _ssidController.text = _ssid;
    });
  }

  Future<Null> _getIP() async {
    String ip = await Wifi.ip;
    setState(() {
      _ip = ip;
    });
  }

  void dataHandler(data){
    print(new String.fromCharCodes(data).trim());
  }

  void errorHandler(error, StackTrace trace){
    print(error);
  }

  void doneHandler(){
    widget.channel.destroy();
  }

  Future<Null> connection() async {
    // print("_ip=${_ip}");
    // widget.channel = await Socket.connect('192.168.1.144', 80).then((Socket sock) {
    //   widget.channel = sock;
    //   widget.channel.listen(dataHandler,
    //       onError: errorHandler,
    //       onDone: doneHandler,
    //       cancelOnError: false);
    // }).catchError((Object e) {
    //   print("Unable to connect: $e");
    // });

    print("ssid=${ssid} password=${password}");


    // Wifi.connection(ssid, password).then((v) async {
    //   print(v);
    //
    // });
  }
}
//===========================================
// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'dart:io';
//
//
// Socket socket;
//
// void main() async {
// // void main() {
//   // modify with your true address/port
//   // Socket sock = await Socket.connect('192.168.1.122', 80);
//   // This part use for communicate to "the Node".
//   Socket sock = await Socket.connect('192.168.1.144', 80);
//   runApp(MyApp(sock));
//
//   // -------------------- may be use this part
//   // Socket.connect("192.168.1.144", 80).then((Socket sock) {
//   //   socket = sock;
//   //   runApp(MyApp(s: sock));
//   //   socket.listen(dataHandler,
//   //       onError: errorHandler,
//   //       onDone: doneHandler,
//   //       cancelOnError: false);
//   // }).catchError((AsyncError e) {
//   //   print("Unable to connect: $e");
//   //   runApp(MyApp());
//   // });
//   // --------------------
//
// }
//
// void dataHandler(data){
//   print(new String.fromCharCodes(data).trim());
// }
//
// void errorHandler(error, StackTrace trace){
//   print(error);
// }
//
// void doneHandler(){
//   socket.destroy();
// }
//
// class MyApp extends StatelessWidget {
//   // This widget is the root of your application.
//   Socket socket;
//
//   // MyApp({Socket s = null}) {
//   //   if(s.isEmpty != null) {
//   //     this.socket = s;
//   //   }
//   // }
//
//   MyApp(Socket s) {
//     this.socket = s;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final title = 'TcpSocket Demo';
//     return MaterialApp(
//       title: title,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MyHomePage(
//         title: title,
//         channel: socket,
//       ),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   MyHomePage({
//     Key key,
//     @required this.title,
//     @required this.channel,
//   }) : super(key: key);
//
//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.
//
//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".
//
//   final String title;
//   final Socket channel;
//   Socket _socket;
//
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: Text(widget.title),
//         ),
//         body: Container(
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   ElevatedButton(
//                     child: Text('connection'),
//                     onPressed: _connection,
//                   ),
//                   ElevatedButton(
//                     child: Text("AC On/Off",
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontStyle: FontStyle.italic,
//                             fontSize: 20.0
//                         )
//                     ),
//                     // color: Colors.red,
//                     onPressed: _togglePower,
//                   ),
//                   ElevatedButton(
//                     child: Text("Fan",
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontStyle: FontStyle.italic,
//                             fontSize: 20.0
//                         )
//                     ),
//                     // color: Colors.red,
//                     onPressed: _fan,
//                   ),
//                   ElevatedButton(
//                     child: Text("Mode",
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontStyle: FontStyle.italic,
//                             fontSize: 20.0
//                         )
//                     ),
//                     // color: Colors.red,
//                     onPressed: _mode,
//                   ),
//                   ElevatedButton(
//                     child: Text("Temp Up",
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontStyle: FontStyle.italic,
//                             fontSize: 20.0
//                         )
//                     ),
//                     // color: Colors.red,
//                     onPressed: _tempUp,
//                   ),
//                   ElevatedButton(
//                     child: Text("Temp Down",
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontStyle: FontStyle.italic,
//                             fontSize: 20.0
//                         )
//                     ),
//                     // color: Colors.red,
//                     onPressed: _tempDown,
//                   ),
//                 ],
//               ),
//             )
//         ) // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
//
//   Future<void> _connection() async {
//     widget._socket = await Socket.connect('192.168.1.144', 80).then((value)  {
//         print("socket value port=${value.port} address=${value.address}");
//         print("widget.channel value port=${widget.channel.port} address=${widget.channel.address}");
//     });
//
//   }
//
//   void _togglePower() {
//     // widget.channel.write("POWER\n");
//     print("POWER!!");
//     widget._socket.write("POWER\n");
//   }
//
//   void _fan() {
//     widget.channel.write("FAN\n");
//   }
//
//   void _mode() {
//     widget.channel.write("MODE\n");
//   }
//
//   void _tempUp() {
//     widget.channel.write("TEMPUP\n");
//   }
//
//   void _tempDown() {
//     widget.channel.write("TEMPDOWN\n");
//   }
//
//   @override
//   void dispose() {
//     widget.channel.close();
//     super.dispose();
//   }
// }
