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
    var data = [];
    print(hospitalId);
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
    data = json.decode(utf8.decode(response.bodyBytes));
    return data;
  }

  isHaveSubmission(submissions, indicatorName) {
    var found = false;
    if (submissions != null && submissions.length > 0) {
      submissions.forEach((each) => {
            if (each['indicator_name'] != null &&
                each['indicator_name'] == indicatorName)
              {found = true}
          });
    }
    return found;
  }

  @override
  Widget build(BuildContext context) {
    final Map dataFromHospitalScreen =
        ModalRoute.of(context).settings.arguments;
    var hospitalId = dataFromHospitalScreen['hospital_id'];
    var hospitalName = dataFromHospitalScreen['hospital_name'];
    final isFromProgressView = dataFromHospitalScreen['isFromProgressView'];
    final isFromSubmittedView = dataFromHospitalScreen['isFromSubmittedView'];
    final submissions = dataFromHospitalScreen['submissions'];
    int submissionNo = 0;
    if (submissions != null) {
      if (submissions != null && submissions.length > 0) {
        submissions.forEach((each) => {
              if (submissionNo == 0) {submissionNo = each['submission_no']}
            });
      }
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Indicators List",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder(
        future: getDepartmentData(hospitalId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Center(child: Text("Getting the Indicators list"));
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
                            child: Row(children: [
                          Flexible(
                              child: Center(
                                  child: Text("Lab: " + hospitalName,
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold)))),
                        ])));
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
                        leading: isFromProgressView
                            ? Icon(isHaveSubmission(submissions,
                                    snapshot.data[index - 1]["name"])
                                ? Icons.check_box_rounded
                                : Icons.check_box_outline_blank)
                            : null,
                        title: Text(snapshot.data[index - 1]['name'] +
                            ' ' +
                            '(' +
                            snapshot.data[index - 1]['module_name'] +
                            ')'),
                        onTap: () {
                          _navigateToNextView(
                              context,
                              snapshot.data[index - 1]["hospital_id"],
                              snapshot.data[index - 1]["id"],
                              hospitalName,
                              snapshot.data[index - 1]["name"],
                              snapshot.data[index - 1]['module_name'],
                              submissions,
                              isFromProgressView,
                              isFromSubmittedView,
                              submissionNo);
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

  _navigateToNextView(
      BuildContext context,
      hospitalId,
      departmentId,
      hospitalName,
      deptName,
      moduleName,
      submissions,
      isFromProgressView,
      isFromSubmittedView,
      submissionNo) async {
    if (!isFromSubmittedView) {
      Navigator.pushNamed(context, "/submit-survey", arguments: {
        "hospital_id": hospitalId,
        "department_id": departmentId,
        "hospital_name": hospitalName,
        "submission_no": isFromProgressView ? submissionNo : 0,
        "dept_name": deptName,
        "module_name": moduleName,
      });
    } else if (isFromSubmittedView) {
      Navigator.pushNamed(context, "/submitted-survey-list", arguments: {
        'hospitalName': hospitalName,
        'hospitalId': hospitalId,
        'departmentId': departmentId,
        'submissions': submissions,
        "hospital_name": hospitalName,
        "indicator_name": deptName,
        "module_name": moduleName,
      });
    }
  }
}
