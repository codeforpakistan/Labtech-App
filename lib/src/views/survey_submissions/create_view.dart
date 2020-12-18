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

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _latitude = position.latitude;
    _longitude = position.longitude;
  }

  Future getSurveyQuestionnaire(hospitalId, departmentId) async {
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
    return data.first['questions'];
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, Object> dataFromDepartmentScreen =
        ModalRoute.of(context).settings.arguments;
    var hospitalId = dataFromDepartmentScreen['hospital_id'];
    var departmentId = dataFromDepartmentScreen['department_id'];
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
          future: getSurveyQuestionnaire(hospitalId, departmentId),
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
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: ListTile(
                        title: Text(
                          snapshot.data[index]['question'],
                          style: TextStyle(fontSize: 16),
                        ),
                        trailing: SwitchWidgetClass(),
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
        //   shrinkWrap: true,
        //   children: <Widget>[
        //     Padding(
        //       padding: const EdgeInsets.only(left: 60.0, right: 60.0),
        //       child: Material(
        //         elevation: 5.0,
        //         borderRadius: BorderRadius.circular(30.0),
        //         color: Colors.lightGreen,
        //         child: MaterialButton(
        //           minWidth: MediaQuery.of(context).size.width,
        //           padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        //           onPressed: () {},
        //           child: Text("Submit Survey",
        //               textAlign: TextAlign.center,
        //               style: style.copyWith(
        //                   color: Colors.white, fontWeight: FontWeight.bold)),
        //         ),
        //       ),
        //     )
        //   ],
        // ),
      );
    });
  }
}
