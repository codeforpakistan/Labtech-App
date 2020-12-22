import 'dart:ffi';

import 'package:hospection/src/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:hospection/src/widgets/switch_widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

class SubmitSurvey extends StatefulWidget {
  @override
  _SubmitSurveyState createState() => _SubmitSurveyState();
}

class _SubmitSurveyState extends State<SubmitSurvey> {
  TextStyle style = TextStyle(fontSize: 20.0);
  double _latitude, _longitude;
  List<dynamic> questions;
  dynamic payload;
  TextEditingController commentController = new TextEditingController();

  Future getSurveyQuestionnaire(hospitalId, departmentId, returnRoot) async {
    var url =
        "http://18.220.218.41/api/v1/surveys/?department_id=$departmentId";
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
    return returnRoot ? data : data.first['questions'];
  }

  Future getSurveyQuestionnaireForState() async {
    final Map<String, Object> dataFromDepartmentScreen =
        ModalRoute.of(context).settings.arguments;
    var hospitalId = dataFromDepartmentScreen['hospital_id'];
    var departmentId = dataFromDepartmentScreen['department_id'];
    var data = await getSurveyQuestionnaire(hospitalId, departmentId, true);
    this.setDefaultAnswers(data.first);
  }

  void setDefaultAnswers(dynamic data) {
    var list = data['questions'];
    list.forEach((element) {
      if (element.containsKey('sub_questions')) {
        element['sub_questions'].forEach((sub) {
          sub['answer'] = false;
        });
      } else {
        element['answer'] = false;
      }
    });
    var payloadFill = {};
    payloadFill['comment'] = '';
    payloadFill['answers'] = list;
    payloadFill['images'] = [];
    payloadFill['lat'] = this._latitude;
    payloadFill['lng'] = this._longitude;
    payloadFill['survey_id'] = data['id'];
    setState(() => {
          questions = list,
          payload = payloadFill,
        });
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getSurveyQuestionnaireForState();
    });
  }

  void _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _latitude = position.latitude;
    _longitude = position.longitude;
  }

  dynamic updateFromChild(bool val, int qid, int sqid) {
    if (sqid == -1) {
      // no subquestions..
      this.questions.forEach((element) {
        if (element['q_id'] == qid) {
          element['answer'] = val;
        }
      });
    } else {
      // update subquestion response..
      this.questions.forEach((element) {
        if (element['q_id'] == qid) {
          element['sub_questions'].forEach((sub) {
            if (sub['s_q_id'] == sqid) {
              sub['answer'] = val;
            }
          });
        }
      });
    }
    this.payload['answers'] = this.questions;
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, Object> dataFromDepartmentScreen =
        ModalRoute.of(context).settings.arguments;
    var hospitalId = dataFromDepartmentScreen['hospital_id'];
    var departmentId = dataFromDepartmentScreen['department_id'];

    final commentField = TextFormField(
      controller: commentController,
      style: TextStyle(fontSize: 16.0),
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Comment",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12.0))),
    );

    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            tooltip: "Cancel and Return to List",
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/submitted-survey-list', (Route<dynamic> route) => false);
            },
          ),
          automaticallyImplyLeading: false,
          title: Text(
            "Survey Questions",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: FutureBuilder(
          future: getSurveyQuestionnaire(hospitalId, departmentId, false),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Center(child: Text("Getting the survey questionnaire"));
                break;
              case ConnectionState.done:
                if (snapshot.hasError) {
                  return Center(
                      child: Text(
                          "Some unknown error has occurred, please contact your system administrator"));
                }
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          if (snapshot.data[index]
                              .containsKey('sub_questions')) {
                            var subQuestions =
                                snapshot.data[index]['sub_questions'];
                            var mainQid = snapshot.data[index]['q_id'];
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 5.0),
                                  child: ListTile(
                                    title: Text(
                                      snapshot.data[index]['question'],
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                                ListView.builder(
                                    itemCount: subQuestions.length,
                                    physics: ClampingScrollPhysics(),
                                    shrinkWrap: true,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(left: 20.0),
                                        child: ListTile(
                                          title: Text(
                                            subQuestions[index]['question'],
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          trailing: SwitchWidgetClass(
                                              updateFromChild,
                                              mainQid,
                                              subQuestions[index]['s_q_id']),
                                        ),
                                      );
                                    }),
                              ],
                            );
                          } else {
                            return Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: ListTile(
                                title: Text(
                                  snapshot.data[index]['question'],
                                  style: TextStyle(fontSize: 16),
                                ),
                                trailing: SwitchWidgetClass(updateFromChild,
                                    snapshot.data[index]['q_id'], -1),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 10.0, left: 20.0, right: 20.0, bottom: 0.0),
                      child: Material(
                        child: commentField,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 20.0, left: 60.0, right: 60.0, bottom: 40.0),
                      child: Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(30.0),
                        color: Colors.lightGreen,
                        child: MaterialButton(
                          minWidth: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                          onPressed: () {
                            this.payload['comment'] = commentController.text;
                            submitSurvey();
                          },
                          child: Text("Submit Survey",
                              textAlign: TextAlign.center,
                              style: style.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    )
                  ],
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
        //   shrinkWrap: true,
        //   children: <Widget>[
        //
        //   ],
        // ),
      );
    });
  }

  submitSurvey() async {
    var accessToken = Constants.prefs.getString('access_token');
    var url = 'http://18.220.218.41/api/v1/submissions/';
    var data = json.encode(this.payload);
    var jsonData;
    var response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: data);
    if (response.statusCode == 200) {
      jsonData = json.decode(response.body);
      setState(() {
        Navigator.pushReplacementNamed(context, '/submitted-survey-list');
      });
    } else {
      print('something went wrong');
      print(response.statusCode);
    }
  }
}
