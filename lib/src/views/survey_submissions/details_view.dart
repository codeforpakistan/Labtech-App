import 'package:flutter/material.dart';
import 'package:hospection/src/utils/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ShowSurveyDetails extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future getSurveyDetailsData(surveyId) async {
    var url = "http://18.220.218.41/api/v1/submissions/$surveyId";
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
    final Map<String, Object> dataFromHospitalScreen =
        ModalRoute.of(context).settings.arguments;
    var surveyId = dataFromHospitalScreen['survey_id'];
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Survey Details",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder(
        future: getSurveyDetailsData(surveyId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Center(child: Text("Getting the survey details"));
              break;
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Center(
                    child: Text(
                        "Some unknown error has occurred, please contact your system administrator"));
              }
              return ListView.builder(
                itemCount: snapshot.data['answers'].length,
                itemBuilder: (context, index) {
                  if (snapshot.data['answers'][index]
                      .containsKey('sub_questions')) {
                    var subQuestions =
                        snapshot.data['answers'][index]['sub_questions'];
                    return Column(
                      children: [
                        ListTile(
                          leading:
                              Icon(Icons.check_box, color: Colors.grey[200]),
                          title:
                              Text(snapshot.data['answers'][index]['question']),
                        ),
                        ListView.builder(
                            itemCount: subQuestions.length,
                            physics: ClampingScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 50.0),
                                child: ListTile(
                                  leading: subQuestions[index]["answer"]
                                      ? Icon(Icons.check,
                                          color: Colors.lightGreen)
                                      : Icon(Icons.close, color: Colors.red),
                                  title: Text(subQuestions[index]['question']),
                                ),
                              );
                            }),
                      ],
                    );
                  } else {
                    return ListTile(
                      leading: snapshot.data['answers'][index]["answer"]
                          ? Icon(Icons.check, color: Colors.lightGreen)
                          : Icon(Icons.close, color: Colors.red),
                      title: Text(snapshot.data['answers'][index]["question"]),
                    );
                  }
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
      //       leading: Icon(Icons.local_hospital),
      //       title: Text('Polyclinic Hospital'),
      //       subtitle: Text("Emergency Department"),
      //       trailing: Text("9th December, 2020"),
      //     ),
      //     ListTile(
      //       leading: Icon(Icons.check, color: Colors.lightGreen),
      //       title: Text('Is the prompt and safe healthcare being assured?'),
      //     ),
      //   ],
      // ),
    );
  }
}
