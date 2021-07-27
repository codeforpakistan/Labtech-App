import 'package:flutter/material.dart';
import 'package:hospection/src/utils/constants.dart';
import 'package:hospection/src/views/auth/login_view.dart';
import 'package:hospection/src/views/departments/list_view.dart';
import 'package:hospection/src/views/hospitals/list_view.dart';
import 'package:hospection/src/views/survey_submissions/survey_view.dart';
import 'package:hospection/src/views/survey_submissions/details_view.dart';
import 'package:hospection/src/views/survey_submissions/list_view.dart';
import 'package:hospection/src/views/tabs/tab_view.dart';
import 'package:hospection/src/views/splash_screen.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:hospection/src/models/survey_model.dart';
import 'dart:convert';

class Hosepction extends StatefulWidget {
  @override
  HosepctionState createState() => HosepctionState();
}

class HosepctionState extends State<Hosepction> {
  bool showSplash = true;

  Widget render(BuildContext context) {
    new Future.delayed(
        const Duration(milliseconds: 1500),
        () => {
              setState(() {
                showSplash = false;
              })
            });
    return SpashScreen();
  }

  @override
  void initState() {
    super.initState();
    _checkSurveyPendingSubmission();
  }

  _checkSurveyPendingSubmission() async {
    try {
      print('_checkSurveyPendingSubmission');
      var accessToken = Constants.prefs.getString('access_token');
      if (accessToken != null && accessToken != '') {
        if (!Hive.isAdapterRegistered(1)) {
          Hive.registerAdapter(SurveyModelAdapter());
        }
        var box = await Hive.openBox<SurveyModel>(Constants.HIVE_SURVEYS_BOX);
        print('box.keys');
        print(box.keys);
        box.keys.forEach((k) async {
          print(k);
          SurveyModel survey = box.get(k);
          await _submitSurvey(survey.payload, accessToken);
          box.delete(k);
        });
      }
    }  catch (error)  {
      print('hive error');
      print(error);
      return false;
    }
  }

  _submitSurvey(dynamic data, String accessToken) async {
    var url = Constants.BASE_URL + 'submissions/';
    var payload = json.encode(data);
    var response = await http.post(url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: payload);
    if (response.statusCode == 200) {
      print('submitted success');
    } else {
      print('something went wrong');
      print(response.statusCode);
    }
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
          highlightColor: Colors.lightGreen),
      home: Constants.prefs.getBool("loggedIn") == true ? TabView() : Login(),
      navigatorObservers: [],
      routes: {
        '/login': (context) => Login(),
        '/home': (context) => TabView(),
        '/submitted-survey-list': (context) => SubmittedSurveyList(),
        '/show-survey-details': (context) => ShowSurveyDetails(),
        '/hospital-list': (context) => HospitalList(),
        '/department-list': (context) => DepartmentList(),
        '/submit-survey': (context) => SurveyView(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
