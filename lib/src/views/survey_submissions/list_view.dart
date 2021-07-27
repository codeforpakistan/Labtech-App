import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

class SubmittedSurveyList extends StatefulWidget {
  final int departmentId;
  final int hospitalId;
  final String hospitalName;
  const SubmittedSurveyList(
      {Key key, this.hospitalName, this.departmentId, this.hospitalId})
      : super(key: key);
  @override
  _SubmittedSurveyListState createState() => _SubmittedSurveyListState();
}

class _SubmittedSurveyListState extends State<SubmittedSurveyList> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future getSubmittedSurveysData() async {
    try {
      final Map<dynamic, dynamic> dataFromParams =
          ModalRoute.of(this.context).settings.arguments;
      var indicatorName = dataFromParams['indicator_name'];
      // var hospitalName = dataFromParams['hospitalName'];
      var submissions = dataFromParams['submissions'];
      var data = [];
      data = getSubmissionForCurrentIndicator(submissions, indicatorName);
      // var url = Constants.BASE_URL + "submissions/?skip=0&limit=100";
      // var accessToken = Constants.prefs.getString('access_token');
      // var response = await http.get(
      //   url,
      //   headers: {
      //     'Content-Type': 'application/json',
      //     'Accept': 'application/json',
      //     'Authorization': 'Bearer $accessToken',
      //   },
      // );
      // data = json.decode(utf8.decode(response.bodyBytes));
      // var updatedList = [];
      // var name = '';
      // data.forEach((each) => {name = each?.hospital, print(name)});
      // // data.forEach((each: any) {
      // //   print(each);
      // //   // if (value &&
      // //   //     value.hospital &&
      // //   //     value.hospital.toString() == hospitalName.toString()) {
      // //   //   updatedList.add(value);
      // //   // }
      // // });
      // print(updatedList);
      return data;
    } catch (error) {
      print(error);
      // toaster.show('something went wrong');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    // _getCurrentLocation();
  }

  // void _getCurrentLocation() async {
  //   final position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high);
  //   Constants.prefs.setDouble('latitude', position.latitude);
  //   Constants.prefs.setDouble('longitude', position.longitude);
  // }

  getSubmissionForCurrentIndicator(submissions, currentIndicator) {
    var found = [];
    if (submissions != null && submissions.length > 0) {
      submissions.forEach((each) => {
            if (each['indicator_name'] != null &&
                each['indicator_name'] == currentIndicator)
              {found.add(each)}
          });
    }
    return found;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Submissions List",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder(
        future: getSubmittedSurveysData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Center(child: Text("Getting the submitted survey list"));
              break;
            case ConnectionState.done:
              if (snapshot.hasError || snapshot.data == null) {
                return Center(
                    child: Text(
                        "Some unknown error has occurred, please contact your system administrator"));
              } else if (snapshot.data.length == 0) {
                return Center(child: Text("No Survey Submitted Yet."));
              }
              return ListView.builder(
                itemCount: snapshot.data != null ? snapshot.data.length : 0,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey,
                          width: 0.3,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: ListTile(
                        leading: Icon(Icons.file_copy),
                        title: Text(
                            "${snapshot.data[index]['department'] != null ? snapshot.data[index]['department'] : snapshot.data[index]['indicator_name']} - ${snapshot.data[index]['hospital'] != null ? snapshot.data[index]['hospital'] : snapshot.data[index]['module_name']}"),
                        subtitle: Text(new DateFormat.yMMMMEEEEd().format(
                                DateTime.parse(
                                    snapshot.data[index]['created_date'])) +
                            "\n" +
                            snapshot.data[index]['comment']),
                        onTap: () {
                          _navigateAndDisplaySurvey(
                              context,
                              snapshot.data[index]["id"] != null
                                  ? snapshot.data[index]['id']
                                  : snapshot.data[index]['submission_id']);
                        },
                      ),
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
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.pushNamed(context, '/hospital-list');
      //   },
      //   child: Icon(Icons.edit),
      //   backgroundColor: Colors.lightGreen,
      //   foregroundColor: Colors.white,
      // ),
    );
  }

  _navigateAndDisplaySurvey(BuildContext context, surveyId) async {
    Navigator.pushNamed(context, '/show-survey-details',
        arguments: {"survey_id": surveyId});
  }
}
