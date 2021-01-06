import 'package:flutter/material.dart';
import 'package:hospection/src/utils/constants.dart';
import 'package:hospection/src/views/auth/login_view.dart';
import 'package:hospection/src/views/departments/list_view.dart';
import 'package:hospection/src/views/hospitals/list_view.dart';
import 'package:hospection/src/views/survey_submissions/create_view.dart';
import 'package:hospection/src/views/survey_submissions/details_view.dart';
import 'package:hospection/src/views/survey_submissions/list_view.dart';
import 'package:hospection/src/views/tabs/tab_view.dart';
import 'package:hospection/src/views/splash_screen.dart';

class Hosepction extends StatefulWidget {
  @override
  HosepctionState createState() => HosepctionState();
}

class HosepctionState extends State<Hosepction>  {
  bool showSplash = true;

  Widget render(BuildContext context) {
    new Future.delayed(const Duration(milliseconds: 1500),
      () => {
        setState(() {
          showSplash = false;
        })
      });
    return SpashScreen();
  }
  

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hospection',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Century Gothic',
        highlightColor: Colors.lightGreen
      ),
      home: Constants.prefs.getBool("loggedIn") == true
          ? TabView()
          : Login(),
      routes: {
        '/login': (context) => Login(),
        '/home': (context) => TabView(),
        '/submitted-survey-list': (context) => SubmittedSurveyList(),
        '/show-survey-details': (context) => ShowSurveyDetails(),
        '/hospital-list': (context) => HospitalList(),
        '/department-list': (context) => DepartmentList(),
        '/submit-survey': (context) => SubmitSurvey(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
