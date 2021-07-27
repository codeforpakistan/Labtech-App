import 'package:hive/hive.dart';

part 'survey_model.g.dart';

@HiveType(typeId: 1)
class SurveyModel {
  @HiveField(0)
  int id;
  @HiveField(1)
  dynamic payload;
  @HiveField(2)
  DateTime createdAt;
  SurveyModel(this.id, this.payload, this.createdAt);
}
