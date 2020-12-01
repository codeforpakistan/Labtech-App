import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NIH Inspection App',
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
      home: MyHomePage(title: 'NIH Inspection App'),
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
      color: Color(0xff01A0C7),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hospital's List"),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.medical_services),
            title: Text('Polyclinic Hospital'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SurveyPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.medical_services),
            title: Text('PIMS Hospital Islamabad'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SurveyPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.medical_services),
            title: Text('CDA Hospital'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SurveyPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.medical_services),
            title: Text('Federal Government Dispensary - AGPR G-8/4'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SurveyPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

enum SingingCharacter { yes, no }

class SurveyPage extends StatelessWidget {
  SingingCharacter _character = SingingCharacter.yes;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Survey Questions"),
        ),
        body: Container(
          alignment: Alignment.topCenter,
          child: Column(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.check),
                title: Text('Is the prompt and safe healthcare being assured?'),
              ),
              ListTile(
                leading: Icon(Icons.check),
                title: Text(
                    'Are the patients being facilitated and properly guided at the triage+registration counter?'),
              ),
              ListTile(
                leading: Icon(Icons.check),
                title: Text(
                    'Does the emergency environment support healthy interaction between patient and hospital staff?'),
              ),
              ListTile(
                leading: Icon(Icons.check),
                title: Text('Are the resources being properly utilized?'),
              ),
              ListTile(
                leading: Icon(Icons.check),
                title: Text(
                    'Is the emergency having effective security & transport system?'),
              ),
              ListTile(
                leading: Icon(Icons.check),
                title: Text(
                    'Does the emergency have adequate necessary resuscitation equipment & drugs?'),
              ),
              ListTile(
                leading: Icon(Icons.check),
                title: Text(
                    'Does the emergency have adequate necessary human resources (Doctors, Nurses, Paramedical & support staff) available?'),
              ),
              ListTile(
                leading: Icon(Icons.check),
                title: Text(
                    'Is the staff assigned to the duty in emergency present?'),
              ),
              ListTile(
                leading: Icon(Icons.check),
                title: Text(
                    'Is the emergency clean with proper hospital waste management system?'),
              ),
              ListTile(
                leading: Icon(Icons.check),
                title: Text('Are the heating and cooling systems functional?'),
              ),
              ListTile(
                leading: Icon(Icons.check),
                title: Text('Is there adequate electrical and water supply?'),
              ),
              ListTile(
                leading: Icon(Icons.check),
                title: Text(
                    'Are there adequate stretchers & wheelchairs available with adequate storage & maintenance capacity?'),
              ),
            ],
          ),
        ));
  }

  void setState(Function() param0) {}
}
