import 'package:flutter/material.dart';
import 'package:hospection/src/utils/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DepartmentList extends StatefulWidget {
  @override
  _DepartmentListState createState() => _DepartmentListState();
}

class _DepartmentListState extends State<DepartmentList> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future getDepartmentData(hospitalId) async {
    var url = Constants.BASE_URL + "departments/?hospital_id=$hospitalId";
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
    var hospitalId = dataFromHospitalScreen['hospital_id'];
    var hospitalName = dataFromHospitalScreen['hospital_name'];
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
              return Center(child: Text("Getting the departments list"));
              break;
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Some unknown error has occurred, please contact your system administrator"));
              }
              return ListView.builder(
                itemCount: snapshot.data.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                        child: Row(
                          children: [
                            Text("Hospital: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Flexible( child: Text(hospitalName, style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal))),
                          ]
                        )
                      )
                    );
                  } else {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey,
                            width: 0.3,
                          ),
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.medical_services),
                        title: Text(snapshot.data[index - 1]['name']),
                        onTap: () {
                          _navigateAndDisplaySurvey(
                            context,
                            snapshot.data[index - 1]["hospital_id"],
                            snapshot.data[index - 1]["id"],
                            hospitalName,
                            snapshot.data[index - 1]["name"]
                          );
                        },
                      ),
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
    );
  }

  _navigateAndDisplaySurvey(
      BuildContext context, hospitalId, departmentId, hospitalName, deptName) async {
    Navigator.pushNamed(context, "/submit-survey",
        arguments: {"hospital_id": hospitalId,
        "department_id": departmentId,
        "hospital_name": hospitalName,
        "dept_name": deptName,
      });
  }
}
