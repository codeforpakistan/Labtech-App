import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hospection/src/utils/constants.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  Login({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextStyle style = TextStyle(fontSize: 20.0);
  var url = "http://localhost/api/v1/login/access-token";
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  bool _loginFailed = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final emailField = TextFormField(
      autofocus: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your username';
        }
        return null;
      },
      obscureText: false,
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Username",
          errorText: _loginFailed ? "Incorrect username or password" : null,
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    final passwordField = TextFormField(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        return null;
      },
      obscureText: true,
      controller: passwordController,
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
      color: Colors.lightGreen,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          if (_formKey.currentState.validate()) {
            signIn(emailController.text, passwordController.text);
          }
        },
        child: Text("Login",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
    return Scaffold(
        body: Center(
      child: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
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
                          "assets/hospection-logo.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: 15.0),
                      Text(
                        'HOSPECTION',
                        style: TextStyle(
                            fontSize: 30, fontFamily: 'Century Gothic'),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 45.0),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            emailField,
                            SizedBox(height: 25.0),
                            passwordField,
                            SizedBox(
                              height: 35.0,
                            ),
                            loginButton,
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                    ],
                  ),
                ),
              )
            ]),
      ),
    ));
  }

  signIn(String username, String password) async {
    Map data = {
      'username': username,
      'password': password,
    };
    var jsonData;

    var response = await http
        .post("http://18.220.218.41/api/v1/login/access-token", body: data);

    if (response.statusCode == 200) {
      jsonData = json.decode(response.body);
      setState(() {
        print(
            ">=========================ACCESS TOKEN=========================<");
        print(jsonData['access_token']);
        print(
            ">=========================ACCESS TOKEN=========================<");
        Constants.prefs.setString('access_token', jsonData['access_token']);
        Constants.prefs.setBool("loggedIn", true);
        Navigator.pushReplacementNamed(context, '/submitted-survey-list');
      });
    } else {
      // var errorData = json.decode(response.body);
      setState(() {
        _loginFailed = true;
      });
    }
  }
}
