import 'package:flutter/material.dart';
import 'package:hospection/src/app.dart';
import 'package:hospection/src/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Constants.prefs = await SharedPreferences.getInstance();
  runApp(Hosepction());
}
