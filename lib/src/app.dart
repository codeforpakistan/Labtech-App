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
import 'package:hospection/src/models/survey_model.dart';

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
    _submitPendingSurveyFromHive();
  }

  _submitPendingSurveyFromHive() async {
    print('_submitPendingSurveyFromHive');
    try {
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(SurveyModelAdapter());
      };
      var box = await Hive.openBox<SurveyModel>(Constants.HIVE_SURVEYS_BOX);
      print('box.keys');
      print(box.keys);
      box.keys.forEach((k) {
        print(k);
        SurveyModel survey = box.get(k);
        print(survey);
      });
    }  catch (error)  {
      print('hive error');
      print(error);
      return false;
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
