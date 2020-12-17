import 'package:flutter/material.dart';

class SubmitSurvey extends StatefulWidget {
  @override
  _SubmitSurveyState createState() => _SubmitSurveyState();
}

class _SubmitSurveyState extends State<SubmitSurvey> {
  bool _checkedQ1 = false;
  bool _checkedQ2 = false;
  bool _checkedQ3 = false;
  bool _checkedQ4 = false;
  bool _checkedQ5 = false;
  bool _checkedQ6 = false;
  bool _checkedQ7 = false;
  bool _checkedQ8 = false;
  bool _checkedQ9 = false;
  bool _checkedQ10 = false;
  bool _checkedQ11 = false;
  bool _checkedQ12 = false;
  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              tooltip: "Cancel and Return to List",
              onPressed: () {
                Navigator.pop(context, "You didn't submit the survey.");
              },
            ),
            automaticallyImplyLeading: false,
            title: Text(
              "Survey Questions",
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: Center(
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                CheckboxListTile(
                  title:
                      Text("Is the prompt and safe healthcare being assured?"),
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _checkedQ1,
                  onChanged: (bool value) {
                    setState(() {
                      _checkedQ1 = value;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text(
                      "Are the patients being facilitated and properly guided at the triage+registration counter?"),
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _checkedQ2,
                  onChanged: (bool value) {
                    setState(() {
                      _checkedQ2 = value;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text(
                      "Does the emergency environment support healthy interaction between patient and hospital staff?"),
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _checkedQ3,
                  onChanged: (bool value) {
                    setState(() {
                      _checkedQ3 = value;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text("Are the resources being properly utilized?"),
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _checkedQ4,
                  onChanged: (bool value) {
                    setState(() {
                      _checkedQ4 = value;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text(
                      "Is the emergency having effective security & transport system?"),
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _checkedQ5,
                  onChanged: (bool value) {
                    setState(() {
                      _checkedQ5 = value;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text(
                      "Does the emergency have adequate necessary resuscitation equipment & drugs?"),
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _checkedQ6,
                  onChanged: (bool value) {
                    setState(() {
                      _checkedQ6 = value;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text(
                      "Does the emergency have adequate necessary human resources (Doctors, Nurses, Paramedical & support staff) available?"),
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _checkedQ7,
                  onChanged: (bool value) {
                    setState(() {
                      _checkedQ7 = value;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text(
                      "Is the staff assigned to the duty in emergency present?"),
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _checkedQ8,
                  onChanged: (bool value) {
                    setState(() {
                      _checkedQ8 = value;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text(
                      "Is the emergency clean with proper hospital waste management system?"),
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _checkedQ9,
                  onChanged: (bool value) {
                    setState(() {
                      _checkedQ9 = value;
                    });
                  },
                ),
                CheckboxListTile(
                  title:
                      Text("Are the heating and cooling systems functional?"),
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _checkedQ10,
                  onChanged: (bool value) {
                    setState(() {
                      _checkedQ10 = value;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text("Is there adequate electrical and water supply?"),
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _checkedQ11,
                  onChanged: (bool value) {
                    setState(() {
                      _checkedQ11 = value;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text(
                      "Are there adequate stretchers & wheelchairs available with adequate storage & maintenance capacity?"),
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _checkedQ12,
                  onChanged: (bool value) {
                    setState(() {
                      _checkedQ12 = value;
                    });
                  },
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                          context, '/submitted-survey-list');
                    },
                    child: Text('Submit survey'),
                  ),
                )
              ],
            ),
          ));
    });
  }
}
