import 'package:flutter/material.dart';
import 'package:hospection/src/views/departments/list_view.dart';

class MainPage extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Hospital's List"),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.medical_services),
            title: Text('Polyclinic Hospital'),
            onTap: () {
              _navigateAndDisplaySurvey(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.medical_services),
            title: Text('PIMS Hospital Islamabad'),
            onTap: () {
              _navigateAndDisplaySurvey(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.medical_services),
            title: Text('CDA Hospital'),
            onTap: () {
              _navigateAndDisplaySurvey(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.medical_services),
            title: Text('Federal Government Dispensary - AGPR G-8/4'),
            onTap: () {
              _navigateAndDisplaySurvey(context);
            },
          ),
        ],
      ),
    );
  }

  _navigateAndDisplaySurvey(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DepartmentPage()),
    );

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    final snackBar = SnackBar(content: Text('$result'));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }
}
