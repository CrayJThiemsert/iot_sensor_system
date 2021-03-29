import 'package:flutter/material.dart';
import 'package:ftiotsystem/pages/network/choose_network.dart';


class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('Goto New Device Page'),
          onPressed: () {
            // Navigate to add new device page
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChooseNetworkPage()),
            );
          },
        ),
      ),
    );
  }
}