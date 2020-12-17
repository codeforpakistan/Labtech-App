import 'package:flutter/material.dart';
import 'package:hospection/src/utils/constants.dart';
import 'package:hospection/src/views/hospitals/list_view.dart';
import 'package:hospection/src/views/survey_submissions/details_view.dart';
// import 'package:http/http.dart' as http;

class SubmittedSurveyList extends StatefulWidget {
  @override
  _SubmittedSurveyListState createState() => _SubmittedSurveyListState();
}

class _SubmittedSurveyListState extends State<SubmittedSurveyList> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Survey Submissions",
          style: TextStyle(color: Colors.white),
        ),
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
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.file_copy),
            title: Text('Polyclinic Hospital'),
            subtitle: Text("16th December, 2020"),
            onTap: () {
              _navigateAndDisplaySurvey(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.file_copy),
            title: Text('Polyclinic Hospital'),
            subtitle: Text("9th December, 2020"),
            onTap: () {
              _navigateAndDisplaySurvey(context);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/hospital-list');
        },
        child: Icon(Icons.edit),
        backgroundColor: Colors.lightGreen,
        foregroundColor: Colors.white,
      ),
    );
  }

  _navigateAndDisplaySurvey(BuildContext context) async {
    Navigator.pushNamed(context, '/show-survey-details');
  }
}
