import 'package:labtech/src/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DataService {
  String accessToken = '';
  Object defaultHeaders = {};

  DataService() {
    this.accessToken = Constants.prefs.getString('access_token');
    this.defaultHeaders = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ' + this.accessToken,
    };
    print('accessToken ${this.accessToken}');
    print('defaultHeaders');
    print(this.defaultHeaders);
  }


  resetConfig() {
    this.accessToken = Constants.prefs.getString('access_token');
    this.defaultHeaders = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ' + this.accessToken,
    };
  }

  Future<bool> submitSurvey(dynamic data) async {
    if (this.accessToken != null && this.accessToken != '') {
      var url = Constants.BASE_URL + 'submissions/';
      var payload = json.encode(data);
      print( this.defaultHeaders);
      var response = await http.post(url, headers: this.defaultHeaders,  body: payload);
      if (response.statusCode == 200) {
        return true;
      } else {
        print('something went wrong ${response.statusCode}');
        return false;
      }
    } else {
      print('No Session');
      return false;
    }
  }

}