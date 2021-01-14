import 'package:flutter/material.dart';
import 'package:hospection/src/app.dart';
import 'package:hospection/src/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Constants.prefs = await SharedPreferences.getInstance();
  runApp(Hosepction());
}
