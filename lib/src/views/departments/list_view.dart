import 'package:flutter/material.dart';
import 'package:hospection/src/utils/constants.dart';
import 'package:hospection/src/views/survey_submissions/create_view.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DepartmentList extends StatefulWidget {
  @override
  _DepartmentListState createState() => _DepartmentListState();
}

class _DepartmentListState extends State<DepartmentList> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future getDepartmentData(hospitalId) async {
    var url =
        "http://18.220.218.41/api/v1/departments/?hospital_id=$hospitalId";
    var accessToken = Constants.prefs.getString('access_token');
    var response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    var data = json.decode(response.body);
    print(response.body);
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, Object> dataFromHospitalScreen =
        ModalRoute.of(context).settings.arguments;
    var hospitalId = dataFromHospitalScreen['hospital_id'];
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Department's List",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder(
        future: getDepartmentData(hospitalId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Center(child: Text("Getting the hospitals list"));
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
                  return ListTile(
                    leading: Icon(Icons.medical_services),
                    title: Text(snapshot.data[index]['name']),
                    onTap: () {
                      _navigateAndDisplaySurvey(
                          context,
                          snapshot.data[index]["hospital_id"],
                          snapshot.data[index]["id"]);
                    },
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
      //
      //   ],
      // ),
    );
  }

  _navigateAndDisplaySurvey(
      BuildContext context, hospitalId, departmentId) async {
    Navigator.pushNamed(context, "/submit-survey",
        arguments: {"hospital_id": hospitalId, "department_id": departmentId});
  }
}
