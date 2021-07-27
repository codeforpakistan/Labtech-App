import 'package:flutter/material.dart';
import 'package:hospection/src/app.dart';
import 'package:hospection/src/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Constants.prefs = await SharedPreferences.getInstance();
  await _initialStorageSettings();
  runApp(Hosepction());
}

_initialStorageSettings() async {
  print('_initialStorageSettings');
  Directory appDocDirectory = await getApplicationDocumentsDirectory();
  Directory directory = await new Directory(
          appDocDirectory.path + '/' + Constants.APP_EXTERNAL_DIR_NAME)
      .create(recursive: true);
  print('directory.path ' + directory.path);
  Hive.init(directory.path);
}
