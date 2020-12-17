import 'package:flutter/material.dart';

class ShowSurveyDetails extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Survey Details",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.local_hospital),
            title: Text('Polyclinic Hospital'),
            subtitle: Text("Emergency Department"),
            trailing: Text("9th December, 2020"),
          ),
          ListTile(
            leading: Icon(Icons.check, color: Colors.lightGreen),
            title: Text('Is the prompt and safe healthcare being assured?'),
          ),
          ListTile(
            leading: Icon(Icons.close, color: Colors.red),
            title: Text(
                'Are the patients being facilitated and properly guided at the triage+registration counter?'),
          ),
          ListTile(
            leading: Icon(Icons.check, color: Colors.lightGreen),
            title: Text(
                'Does the emergency environment support healthy interaction between patient and hospital staff?'),
          ),
          ListTile(
            leading: Icon(Icons.check, color: Colors.lightGreen),
            title: Text('Are the resources being properly utilized?'),
          ),
          ListTile(
            leading: Icon(Icons.check, color: Colors.lightGreen),
            title: Text(
                'Is the emergency having effective security & transport system?'),
          ),
          ListTile(
            leading: Icon(Icons.close, color: Colors.red),
            title: Text(
                'Does the emergency have adequate necessary resuscitation equipment & drugs?'),
          ),
          ListTile(
            leading: Icon(Icons.close, color: Colors.red),
            title: Text(
                'Does the emergency have adequate necessary human resources (Doctors, Nurses, Paramedical & support staff) available?'),
          ),
          ListTile(
            leading: Icon(Icons.check, color: Colors.lightGreen),
            title:
                Text('Is the staff assigned to the duty in emergency present?'),
          ),
          ListTile(
            leading: Icon(Icons.close, color: Colors.red),
            title: Text(
                'Is the emergency clean with proper hospital waste management system?'),
          ),
          ListTile(
            leading: Icon(Icons.check, color: Colors.lightGreen),
            title: Text('Are the heating and cooling systems functional?'),
          ),
          ListTile(
            leading: Icon(Icons.check, color: Colors.lightGreen),
            title: Text('Is there adequate electrical and water supply?'),
          ),
          ListTile(
            leading: Icon(Icons.close, color: Colors.red),
            title: Text(
                'Are there adequate stretchers & wheelchairs available with adequate storage & maintenance capacity?'),
          ),
        ],
      ),
    );
  }
}
