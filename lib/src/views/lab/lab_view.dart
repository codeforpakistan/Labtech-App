import 'package:flutter/material.dart';
import 'package:hospection/src/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class HospitalList extends StatefulWidget {
  final bool isFromProgressView;
  final bool isFromSubmittedView;
  const HospitalList(
      {Key key, this.isFromProgressView, bool, this.isFromSubmittedView})
      : super(key: key);
  @override
  _HospitalListState createState() => _HospitalListState();
}

class _HospitalListState extends State<HospitalList> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Future getHospitalData(shouldFetchLabSubmission) async {
    var url = shouldFetchLabSubmission == true
        ? Constants.BASE_URL + "submissions/by-labs"
        : Constants.BASE_URL + "hospitals/";
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
  void initState() {
    super.initState();
    // _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: FutureBuilder(
        future: getHospitalData(
            widget.isFromSubmittedView || widget.isFromProgressView),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Center(child: Text("Getting the Labs list"));
              break;
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Center(
                    child: Text(
                        "Some unknown error has occurred, please contact your system administrator"));
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
                    child: ((widget.isFromSubmittedView &&
                                snapshot.data[index]['completed'] == true) ||
                            (widget.isFromProgressView &&
                                snapshot.data[index]['completed'] == false) ||
                            !widget.isFromSubmittedView &&
                                !widget.isFromProgressView)
                        ? Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ListTile(
                              leading: Icon(Icons.health_and_safety_outlined),
                              title: Text(snapshot.data[index]['name']),
                              subtitle: Text("Address: ${snapshot.data[index]["address"] != null ? snapshot.data[index]["address"] : 'N/A'}" +
                                  "\n" +
                                  "User: ${snapshot.data[0]['user'] != null ? snapshot.data[0]['user'] : 'N/A'}"
                                      "${snapshot.data[0]['start_date'] != null ? '\nStart Date: ' + (new DateFormat.yMMMMEEEEd().format(DateTime.parse(snapshot.data[index]['start_date']))) : ''}" +
                                  "${widget.isFromSubmittedView && snapshot.data[0]['end_date'] != null ? '\nEnd Date: ' + (new DateFormat.yMMMMEEEEd().format(DateTime.parse(snapshot.data[index]['end_date']))) : ''}"),
                              onTap: () {
                                _navigateAndDisplaySurvey(
                                    context,
                                    snapshot.data[index]["id"] != null
                                        ? snapshot.data[index]["id"]
                                        : snapshot.data[index]["_id"],
                                    snapshot.data[index]['name'],
                                    snapshot.data[index]['submissions'] != null
                                        ? snapshot.data[index]['submissions']
                                        : [],
                                    widget.isFromProgressView,
                                    widget.isFromSubmittedView);
                              },
                            ),
                          )
                        : null,
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
    );
  }

  _navigateAndDisplaySurvey(BuildContext context, hospitalId, hospitalName,
      submissions, isFromProgressView, isFromSubmittedView) async {
    Navigator.pushNamed(context, "/module-list", arguments: {
      "submissions": submissions,
      "hospital_id": hospitalId,
      "hospital_name": hospitalName,
      "isFromProgressView": isFromProgressView,
      "isFromSubmittedView": isFromSubmittedView
    });
  }
}
