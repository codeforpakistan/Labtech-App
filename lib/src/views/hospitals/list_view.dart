import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hospection/src/utils/constants.dart';
import 'package:hospection/src/views/departments/list_view.dart';
import 'package:http/http.dart' as http;

class HospitalList extends StatefulWidget {
  @override
  _HospitalListState createState() => _HospitalListState();
}

class _HospitalListState extends State<HospitalList> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var url = "http://18.220.218.41/api/v1/hospitals/";
  var data;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future getData() async {
    var accessToken = Constants.prefs.getString('access_token');
    var response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    data = json.decode(response.body);
    print(response.body);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Hospital's List",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: data == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListTile(
                    leading: Icon(Icons.medical_services),
                    title: Text(data[index]['name']),
                    subtitle: Text("Address: ${data[index]["address"]}"),
                    onTap: () {
                      _navigateAndDisplaySurvey(context);
                    },
                  ),
                );
              },
            ),
    );
  }

  _navigateAndDisplaySurvey(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DepartmentList()),
    );

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    final snackBar = SnackBar(content: Text('$result'));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }
}
