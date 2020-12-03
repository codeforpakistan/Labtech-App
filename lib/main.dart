import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hospection',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Hospection'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  @override
  Widget build(BuildContext context) {
    final emailField = TextField(
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Username",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    final passwordField = TextField(
      obscureText: true,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Password",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    final loginButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Colors.blue,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MainPage()),
          );
        },
        child: Text("Login",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );

    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(36.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 155.0,
                  child: Image.asset(
                    "assets/logo.png",
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 15.0),
                Text(
                  'Hospection',
                  style: TextStyle(fontSize: 30, fontFamily: 'Montserrat'),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 45.0),
                emailField,
                SizedBox(height: 25.0),
                passwordField,
                SizedBox(
                  height: 35.0,
                ),
                loginButton,
                SizedBox(
                  height: 15.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
      MaterialPageRoute(builder: (context) => SurveyPage()),
    );

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    final snackBar = SnackBar(content: Text('$result'));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }
}

class SurveyPage extends StatefulWidget {
  @override
  _SurveyPageState createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
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
            title: Text("Survey Questions"),
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
                      Navigator.pop(context, "Survey submitted successfully.");
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
