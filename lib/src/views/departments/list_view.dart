import 'package:flutter/material.dart';
import 'package:hospection/src/views/survey_submissions/create_view.dart';

class DepartmentPage extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Department's List"),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.medical_services),
            title: Text('Emergency'),
            onTap: () {
              _navigateAndDisplaySurvey(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.medical_services),
            title: Text('OPD'),
            onTap: () {
              _navigateAndDisplaySurvey(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.medical_services),
            title: Text('In Patient'),
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
      MaterialPageRoute(builder: (context) => SurveyPage()),
    );

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    final snackBar = SnackBar(content: Text('$result'));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }
}
