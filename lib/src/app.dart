import 'package:flutter/material.dart';
import 'package:hospection/src/views/auth/login_view.dart';
import 'package:hospection/src/views/survey_submissions/list_view.dart';

class Hosepction extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hospection',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginPage(title: 'Hospection'),
      routes: {
        '/login': (context) => LoginPage(),
        '/mainlistpage': (context) => SubmittedSurveysListPage()
      },
    );
  }
}
