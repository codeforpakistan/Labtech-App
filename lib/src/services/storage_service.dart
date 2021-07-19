import 'package:hive/hive.dart';
import 'package:labtech/src/models/survey_model.dart';
import 'package:labtech/src/utils/constants.dart';
import 'package:labtech/src/services/data_service.dart';

class StorageService {
  DataService ds = new DataService();

  StorageService();

  checkSurveyPendingSubmission() async {
    try {
      print('looking for pending Submissions');
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(SurveyModelAdapter());
      }
      var box = await Hive.openBox<SurveyModel>(Constants.HIVE_SURVEYS_BOX);
      print('box.keys');
      print(box.keys);
      box.keys.forEach((k) async {
        SurveyModel survey = box.get(k);
        var success = await ds.submitSurvey(survey.payload);
        if (success) {
          box.delete(k);
        }
      });
    }  catch (error)  {
      print( { 'msg': 'Something went wrong', 'error': error } );
      return false;
    }
  }

  Future<bool> addSurvey(dynamic data, String key) async {
    try {
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(SurveyModelAdapter());
      };
      var box = await Hive.openBox<SurveyModel>(Constants.HIVE_SURVEYS_BOX);
      // construct Survey instance
      var surveyItem = SurveyModel(int.parse(key), data, new DateTime.now());
      box.put(key, surveyItem);
      print('Survey stored in hive');
      return true;
    } catch (error)  {
      print({ 'hive error', error });
      return false;
    }
  }

}