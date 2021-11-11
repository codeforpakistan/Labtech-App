import 'package:flutter/material.dart';
import 'package:hospection/src/views/auth/login_view.dart';
import 'package:hospection/src/views/indicators/indicator_view.dart';
import 'package:hospection/src/views/lab/lab_view.dart';
import 'package:hospection/src/views/modules/module_view.dart';
import 'package:hospection/src/views/survey_submissions/survey_view.dart';
import 'package:hospection/src/views/survey_submissions/details_view.dart';
import 'package:hospection/src/utils/constants.dart';

class TabView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lab Tech',
      theme: ThemeData(
          primarySwatch: Colors.lightGreen,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: 'Century Gothic',
          highlightColor: Colors.lightGreen),
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.logout,
                  color: Colors.white,
                ),
                onPressed: () {
                  Constants.prefs.setBool("loggedIn", false);
                  Navigator.pushReplacementNamed(context, '/login');
                },
              )
            ],
            bottom: TabBar(
              tabs: [
                Tab(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        WidgetSpan(
                          child: Icon(Icons.post_add,
                              size: 16, color: Colors.white),
                        ),
                        TextSpan(
                          text: " Conduct Survey",
                          style: TextStyle(
                              fontFamily: "BarlowBold", color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                Tab(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        WidgetSpan(
                          child: Icon(Icons.file_copy,
                              size: 16, color: Colors.white),
                        ),
                        TextSpan(
                          text: " In-Progress",
                          style: TextStyle(
                              fontFamily: "BarlowBold", color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                Tab(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        WidgetSpan(
                          child: Icon(Icons.file_copy,
                              size: 16, color: Colors.white),
                        ),
                        TextSpan(
                          text: "Submitted",
                          style: TextStyle(
                              fontFamily: "BarlowBold", color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            title: Text("Lab Tech",
                style:
                    TextStyle(fontFamily: "BarlowBold", color: Colors.white)),
          ),
          body: TabBarView(
            children: [
              HospitalList(
                  isFromProgressView: false, isFromSubmittedView: false),
              HospitalList(
                  isFromProgressView: true, isFromSubmittedView: false),
              HospitalList(
                  isFromProgressView: false, isFromSubmittedView: true),
            ],
          ),
        ),
      ),
      navigatorObservers: [],
      routes: {
        '/login': (context) => Login(),
        '/home': (context) => TabView(),
        // '/submitted-survey-list': (context) => SubmittedSurveyList(),
        '/show-survey-details': (context) => ShowSurveyDetails(),
        '/hospital-list': (context) =>
            HospitalList(isFromProgressView: false, isFromSubmittedView: false),
        '/indicator-list': (context) => DepartmentList(),
        '/module-list': (context) => ModuleList(),
        '/submit-survey': (context) => SurveyView(),
      },
    );
  }
}
