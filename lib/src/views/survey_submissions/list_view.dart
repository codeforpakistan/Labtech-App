import 'package:flutter/material.dart';
import 'package:hospection/src/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';

class SubmittedSurveyList extends StatefulWidget {
  @override
  _SubmittedSurveyListState createState() => _SubmittedSurveyListState();
}

class _SubmittedSurveyListState extends State<SubmittedSurveyList> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future getSubmittedSurveysData() async {
    var url = "http://18.220.218.41/api/v1/submissions/";
    var accessToken = Constants.prefs.getString('access_token');
    var response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    var data = json.decode(utf8.decode(response.bodyBytes));
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Submitted Surveys",
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
      body: FutureBuilder(
        future: getSubmittedSurveysData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Center(child: Text("Getting the submitted survey list"));
              break;
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Center(
                    child: Text(
                        "Some unknown error has occurred, please contact your system administrator"));
              }
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: ListTile(
                      leading: Icon(Icons.file_copy),
                      title: Text(
                          "${snapshot.data[index]['department']} - ${snapshot.data[index]['hospital']}"),
                      subtitle: Text(new DateFormat.yMMMMEEEEd().format(
                              DateTime.parse(
                                  snapshot.data[index]['created_date'])) +
                          "\n" +
                          snapshot.data[index]['comment']),
                      onTap: () {
                        _navigateAndDisplaySurvey(
                            context, snapshot.data[index]["id"]);
                      },
                    ),
                  );
                },
              );
              break;
            case ConnectionState.active:
            case ConnectionState.waiting:
            default:
              return Center(child: CircularProgressIndicator());
              break;
          }
        },
      ),
      // body: ListView(
      //   children: <Widget>[
      //     ListTile(
      //       leading: Icon(Icons.file_copy),
      //       title: Text('Polyclinic Hospital'),
      //       subtitle: Text("16th December, 2020"),
      //       onTap: () {
      //         _navigateAndDisplaySurvey(context);
      //       },
      //     ),
      //     ListTile(
      //       leading: Icon(Icons.file_copy),
      //       title: Text('Polyclinic Hospital'),
      //       subtitle: Text("9th December, 2020"),
      //       onTap: () {
      //         _navigateAndDisplaySurvey(context);
      //       },
      //     ),
      //   ],
      // ),
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

  _navigateAndDisplaySurvey(BuildContext context, surveyId) async {
    Navigator.pushNamed(context, '/show-survey-details',
        arguments: {"survey_id": surveyId});
  }
}
