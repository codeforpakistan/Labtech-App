import 'package:flutter/material.dart';
import 'package:hospection/src/utils/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ModuleList extends StatefulWidget {
  @override
  _ModuleListState createState() => _ModuleListState();
}

class _ModuleListState extends State<ModuleList> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var orignalData = [];
  var sequence = [
    'Facility',
    'Laboratory Information System',
    'Data Management',
    'Quality Assurance',
    'Media Quality Control',
    'Identification Quality Control',
    'Antibiotic Susceptibility Testing Quality Control',
    'Specimen',
    'Processing',
    'Identification',
    'Basic Antibiotic Susceptibility Testing',
    'Antibiotic Susceptibility Testing Expert rules',
    'Antibiotic Susceptibility Testing Policy',
    'Safety'
  ];
  Future getDepartmentData(hospitalId) async {
    var data = [];
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
    orignalData = data;
    var uniqueModulesWithoutSequence = [];
    data.forEach((newItem) {
      if (uniqueModulesWithoutSequence.indexWhere(
              (element) => element['module_name'] == newItem['module_name']) ==
          -1) {
        uniqueModulesWithoutSequence.add(newItem);
      }
    });
    var allUniqueModules = uniqueModulesWithoutSequence;
    data.forEach((element) {
      var idx = sequence.indexWhere(
          (each) => element != null && each == element['module_name']);
      if (idx > -1 &&
          allUniqueModules
                  .indexWhere((element) => element['module_name'] == element) ==
              -1) {
        allUniqueModules[idx] = element;
      }
    });
    return allUniqueModules;
  }

  // find submissions against allModules with specific submission no.
  getDepartmentSubmission(
      submissions, indicatorName, moduleName, submissionNo, returnData) {
    var found = [];
    if (submissions != null && submissions.length > 0) {
      // filter out submission by submissionNO first
      var recordsOfRequestedSubmitions = submissions
          .where((element) => element['submission_no'] == submissionNo)
          .toList();
      // filter out submission by moduleName
      recordsOfRequestedSubmitions.forEach((each) => {
            if (each['module_name'] != null &&
                each['module_name'] == moduleName)
              {found.add(each)}
          });
    }
    // filter out labs and modules from api by moduleName
    var allIndictorsOfSelectedModule = orignalData
        .where((element) =>
            element['module_name'] != null &&
            element['module_name'] == moduleName)
        .toList();
    // ensure allIndictorsOfSelectedModule has atleast one submission against submissionNO
    bool isAllSubmissionsExists = allIndictorsOfSelectedModule.every((element) {
      return (found
              .indexWhere((each) => each['indicator_name'] == element['name']) >
          -1);
    });
    return returnData ? found : isAllSubmissionsExists;
  }

  getModuleIndicators(moduleName) {
    var toReturn = orignalData
        .where((element) => element['module_name'] == moduleName)
        .toList();
    return toReturn;
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
          "Modules List",
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
                            ? Icon((getDepartmentSubmission(
                                    submissions,
                                    snapshot.data[index - 1]["name"],
                                    snapshot.data[index - 1]['module_name'],
                                    submissionNo,
                                    false))
                                ? Icons.check_box_rounded
                                : Icons.check_box_outline_blank)
                            : null,
                        title: Text(snapshot.data[index - 1]['module_name']),
                        onTap: () {
                          _navigateToNextView(
                              context,
                              snapshot.data[index - 1]["hospital_id"],
                              snapshot.data[index - 1]["id"],
                              hospitalName,
                              snapshot.data[index - 1]["name"],
                              snapshot.data[index - 1]['module_name'],
                              getDepartmentSubmission(
                                  submissions,
                                  snapshot.data[index - 1]["name"],
                                  snapshot.data[index - 1]['module_name'],
                                  submissionNo,
                                  true),
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
    Navigator.pushNamed(context, "/indicator-list", arguments: {
      "hospital_id": hospitalId,
      "department_id": departmentId,
      "hospital_name": hospitalName,
      "submission_no": isFromProgressView ? submissionNo : 0,
      "dept_name": deptName,
      "module_name": moduleName,
      "isFromProgressView": isFromProgressView,
      "isFromSubmittedView": isFromSubmittedView,
      "indicators": getModuleIndicators(moduleName),
      'submissions': submissions
    });
  }
}
