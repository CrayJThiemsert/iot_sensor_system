import 'package:firebase_core/firebase_core.dart';
import 'package:flare_splash_screen/flare_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:ftiotsystem/pages/device/choose_device.dart';
import 'package:ftiotsystem/pages/device/model/device.dart';
import 'package:ftiotsystem/pages/device/view/show_device_page.dart';
import 'package:ftiotsystem/pages/network/IotServerService.dart';
import 'package:ftiotsystem/pages/network/choose_network.dart';
import 'package:ftiotsystem/utils/constants.dart';
import 'package:package_info/package_info.dart';
import 'package:ftiotsystem/globals.dart' as globals;

import 'pages/home/home.dart';
// import 'dart:io' show Platform;

import 'package:shelf/shelf_io.dart' as shelf_io;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // final FirebaseApp app = await Firebase.initializeApp(
  //   name: 'db2',
  //   options: Platform.isIOS || Platform.isMacOS
  //       ? const FirebaseOptions(
  //     appId: '1:297855924061:ios:c6de2b69b03a5be8',
  //     apiKey: 'AIzaSyCbK11_NkEfVdkc6u4QwdTMY1D0cqNteKA',
  //     projectId: 'asset-management-lff',
  //     messagingSenderId: '1046253125651',
  //     databaseURL: 'https://asset-management-lff.firebaseio.com',
  //   )
  //       : const FirebaseOptions(
  //     appId: '1:1046253125651:android:7f197e41fe80cea000ffe6',
  //     apiKey: 'AIzaSyCbK11_NkEfVdkc6u4QwdTMY1D0cqNteKA',
  //     messagingSenderId: '1046253125651',
  //     projectId: 'asset-management-lff',
  //     databaseURL: 'https://asset-management-lff.firebaseio.com',
  //   ),
  // );

  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String appName = packageInfo.appName;
  String packageName = packageInfo.packageName;
  String version = packageInfo.version;
  String buildNumber = packageInfo.buildNumber;
  globals.g_appName = appName;
  globals.g_packageName = packageName;
  globals.g_version = version;
  globals.g_buildNumber = buildNumber;

  print('g_appName=${globals.g_appName}');
  print('g_packageName=${globals.g_packageName}');
  print('g_version=${globals.g_version}');
  print('g_buildNumber=${globals.g_buildNumber}');

  final service = IotServerService();
  // final server = await shelf_io.serve(service.handler, 'localhost', 8080);
  // final server = await shelf_io.serve(service.handler, '192.168.1.106', 8080); // Still fixed ip address, have to change to dynamic ip depend on mobile app device.
  final server = await shelf_io.serve(service.handler, '192.168.1.106', 9090); // Still fixed ip address, have to change to dynamic ip depend on mobile app device.
  print('Serving at http://${server.address.host}:${server.port}');
  print('Server running on localhost:${server.port}');

  runApp(
    Constants(
      // child: MyApp(app: app),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key key, this.app}) : super(key: key);

  final FirebaseApp app;

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {


    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Kanit',
        textTheme: TextTheme(

          
          caption: TextStyle(fontFamily: 'Kanit', fontSize: 14.0, fontWeight: FontWeight.w600, color: Colors.black.withOpacity(0.6),),


          subtitle1: TextStyle(fontFamily: 'Kanit', fontSize: 12.0, fontWeight: FontWeight.w300, color: Colors.grey.withOpacity(0.6),),
          subtitle2: TextStyle(fontFamily: 'Kanit', fontSize: 12.0, fontWeight: FontWeight.w600, color: Colors.lightGreen,),
          bodyText1: TextStyle(fontFamily: 'Kanit', fontSize: 14.0, fontWeight: FontWeight.w300, color: Colors.grey.withOpacity(0.9),),

          headline1: TextStyle(fontFamily: 'Kanit', fontSize: 36.0, fontWeight: FontWeight.w300, color: Colors.white,),
          headline2: TextStyle(fontFamily: 'Kanit', fontSize: 12.0, fontWeight: FontWeight.w300, color: Colors.white,),
          headline4: TextStyle(fontFamily: 'Kanit', fontSize: 16.0, fontWeight: FontWeight.w400, color: Colors.black.withOpacity(0.4),),
          headline3: TextStyle(fontFamily: 'Kanit', fontSize: 20.0, fontWeight: FontWeight.w400, color: Colors.white,),
          headline5: TextStyle(fontFamily: 'Kanit', fontSize: 28.0, fontWeight: FontWeight.w300, color: Colors.grey.withOpacity(0.6),),
          headline6: TextStyle(fontFamily: 'Kanit', fontSize: 28.0, fontWeight: FontWeight.w600, color: Colors.lightGreen,),
        ),
      ),
      home: SplashScreen.navigate(
        name: 'intro.flr',
        // next: (context) => MainHomePage(title: 'Flutter Demo Home Page'),
        next: (context) => HomePage(app: widget.app),
        until: () => Future.delayed(Duration(seconds: 5)),
        startAnimation: '1',
      ),
      onGenerateRoute: (settings) {
        // Handle '/'
        if(settings.name == '/') {
          return MaterialPageRoute(builder: (context) => HomePage());
        } else if(settings.name == '/choosenetwork') {
          return MaterialPageRoute(builder: (context) => ChooseNetworkPage());
        } else if(settings.name == '/choosedevice') {
          return MaterialPageRoute(builder: (context) => ChooseDevicePage());
        }
        // Prepare for case specify device id
        var uri = Uri.parse(settings.name);
        if(uri.pathSegments.length == 2) {
          var uid = uri.pathSegments[1];
          Device device = settings.arguments;
          switch (uri.pathSegments.first) {
            case 'device':
              {
                return MaterialPageRoute(builder: (context) => ShowDevicePage(deviceUid: uid, device: device));
              }
              break;
          }
        }

        // if(uri.pathSegments.length == 4) {
        //   var path = uri.pathSegments[2];
        //   var categoryUid = uri.pathSegments[1];
        //   var partUid = uri.pathSegments[3];
        //   Part part = settings.arguments;
        //   switch (path) {
        //     case 'part':
        //       {
        //         return MaterialPageRoute(builder: (context) => PartPage(categoryUid: categoryUid, partUid: partUid, part: part));
        //       }
        //       break;
        //   }
        // }
        //
        // if(uri.pathSegments.length == 6) {
        //   var path = uri.pathSegments[4];
        //   var categoryUid = uri.pathSegments[1];
        //   var partUid = uri.pathSegments[3];
        //   var topicUid = uri.pathSegments[5];
        //   Topic topic = settings.arguments;
        //   switch (path) {
        //     case 'topic':
        //       {
        //         return MaterialPageRoute(builder: (context) => TopicPage(categoryUid: categoryUid, partUid: partUid, topicUid: topicUid, topic: topic));
        //       }
        //       break;
        //   }
        // }
        return MaterialPageRoute(builder: (context) => UnknownScreen());
      },
    );
  }
}

class UnknownScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text('404 - Page not found'),
      ),
    );
  }
}

class MainHomePage extends StatefulWidget {
  MainHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MainHomePageState createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
