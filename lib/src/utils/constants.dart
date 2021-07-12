import 'package:shared_preferences/shared_preferences.dart';

class Constants {
  static SharedPreferences prefs;
  static const APP_EXTERNAL_DIR_NAME = 'labtech_cache';
  static const HIVE_SURVEYS_BOX = 'survey_cache';
  static const HIVE_SURVEYS_KEY = 'surveys';
  static const BASE_URL = 'https://labtech.nih.org.pk:18443/api/v1/'; //prod
  // static const BASE_URL = 'http://18.220.218.41/api/v1/'; //dev
}
