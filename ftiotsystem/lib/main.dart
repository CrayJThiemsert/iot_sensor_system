import 'package:flare_splash_screen/flare_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:ftiotsystem/pages/device/choose_device.dart';
import 'package:ftiotsystem/pages/network/choose_network.dart';
import 'package:ftiotsystem/utils/constants.dart';

import 'pages/home/home.dart';

void main() => runApp(
  Constants(
    child: MyApp(),
  ),
);

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen.navigate(
        name: 'intro.flr',
        // next: (context) => MainHomePage(title: 'Flutter Demo Home Page'),
        next: (context) => HomePage(),
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
        // var uri = Uri.parse(settings.name);
        // if(uri.pathSegments.length == 2) {
        //   var uid = uri.pathSegments[1];
        //   Category category = settings.arguments;
        //   switch (uri.pathSegments.first) {
        //     case 'category':
        //       {
        //         return MaterialPageRoute(builder: (context) => CategoryPage(categoryUid: uid, category: category));
        //       }
        //       break;
        //   }
        // }
        //
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
