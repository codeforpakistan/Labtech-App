import 'package:flutter/material.dart';

class SpashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          backgroundColor: Colors.white,
          body: Material(
              child: Center(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                Image.asset("assets/launcher.png",
                    height: MediaQuery.of(context).size.height,
                    fit: BoxFit.cover),
              ])))),
    );
  }
}
