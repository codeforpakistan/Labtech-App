import 'package:flutter/material.dart';
import 'package:hospection/src/views/auth/login_view.dart';
import 'package:hospection/src/views/departments/list_view.dart';
import 'package:hospection/src/views/hospitals/list_view.dart';
// import 'package:hospection/src/views/survey_submissions/create_view.dart';
import 'package:hospection/src/views/survey_submissions/survey_view.dart';
import 'package:hospection/src/views/survey_submissions/details_view.dart';
import 'package:hospection/src/views/survey_submissions/list_view.dart';
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
            title: Text("Hospection",
                style:
                    TextStyle(fontFamily: "BarlowBold", color: Colors.white)),
          ),
          body: TabBarView(
            children: [
              HospitalList(isFromProgressView: false),
              HospitalList(isFromProgressView: true),
              SubmittedSurveyList(),
            ],
          ),
        ),
      ),
      navigatorObservers: [],
      routes: {
        '/login': (context) => Login(),
        '/home': (context) => TabView(),
        '/submitted-survey-list': (context) => SubmittedSurveyList(),
        '/show-survey-details': (context) => ShowSurveyDetails(),
        '/hospital-list': (context) => HospitalList(isFromProgressView: false),
        '/department-list': (context) => DepartmentList(),
        '/submit-survey': (context) => SurveyView(),
      },
    );
  }
}
