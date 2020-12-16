import 'package:flutter/material.dart';
import 'package:hospection/src/views/hospitals/list_view.dart';
import 'package:hospection/src/views/survey_submissions/details_view.dart';

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
        title: Text("Survey Submissions"),
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HospitalList()),
          );
        },
        child: Icon(Icons.edit),
        backgroundColor: Colors.lightGreen,
        foregroundColor: Colors.white,
      ),
    );
  }

  _navigateAndDisplaySurvey(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ShowSurveyDetails()));
  }
}
