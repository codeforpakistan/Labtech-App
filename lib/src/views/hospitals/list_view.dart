import 'package:flutter/material.dart';
import 'package:hospection/src/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

class HospitalList extends StatefulWidget {
  @override
  _HospitalListState createState() => _HospitalListState();
}

class _HospitalListState extends State<HospitalList> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future getHospitalData() async {
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();

    if (isLocationServiceEnabled) {
      print(isLocationServiceEnabled);
    } else {
      await Geolocator.requestPermission();
    }

    var url = Constants.BASE_URL + "hospitals/";
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
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    Constants.prefs.setDouble('latitude', position.latitude);
    Constants.prefs.setDouble('longitude', position.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: FutureBuilder(
        future: getHospitalData(),
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
                      padding: const EdgeInsets.all(10.0),
                      child: ListTile(
                        leading: Icon(Icons.medical_services),
                        title: Text(snapshot.data[index]['name']),
                        subtitle:
                            Text("Address: ${snapshot.data[index]["address"]}"),
                        onTap: () {
                          _navigateAndDisplaySurvey(
                              context, snapshot.data[index]["id"], snapshot.data[index]['name']);
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
    );
  }

  _navigateAndDisplaySurvey(BuildContext context, hospitalId, hospitalName) async {
    Navigator.pushNamed(context, "/department-list",
        arguments: {"hospital_id": hospitalId, "hospital_name": hospitalName});
  }
}
