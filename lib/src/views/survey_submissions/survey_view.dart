import 'dart:convert';
import 'package:flutter/material.dart' hide Step;
import 'package:survey_kit/survey_kit.dart';
import 'package:hospection/src/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';

class SurveyView extends StatefulWidget {
  @override
  _MySurveyState createState() => _MySurveyState();
}

class _MySurveyState extends State<SurveyView> {
  String departmentName;
  String hospitalName;
  dynamic payload;
  List<dynamic> questions = [];
  bool processing = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: questions != null && questions.length > 0 && !processing
            ? Container(
                color: Colors.white,
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: double.infinity,
                    width: 600,
                    child: SurveyKit(
                      onResult: (SurveyResult result) {
                        var isCancelled = (result.finishReason.toString() ==
                            'FinishReason.DISCARDED');
                        if (isCancelled) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              '/home', (Route<dynamic> route) => false);
                          return;
                        }
                        // check
                        submitSurvey(result);
                      },
                      // surveyController: (SurveyController controller) async =>{
                      //   controller.
                      // },
                      task: getSampleTask(),
                      themeData: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.fromSwatch(
                          primarySwatch: Colors.cyan,
                        ).copyWith(
                          onPrimary: Colors.white,
                        ),
                        primaryColor: Colors.cyan,
                        backgroundColor: Colors.white,
                        appBarTheme: const AppBarTheme(
                          backwardsCompatibility: true,
                          color: Colors.white,
                          iconTheme: IconThemeData(
                            color: Colors.cyan,
                          ),
                          textTheme: TextTheme(
                            button: TextStyle(
                              color: Colors.cyan,
                            ),
                          ),
                        ),
                        iconTheme: const IconThemeData(
                          color: Colors.cyan,
                        ),
                        outlinedButtonTheme: OutlinedButtonThemeData(
                          style: ButtonStyle(
                            minimumSize: MaterialStateProperty.all(
                              Size(150.0, 60.0),
                            ),
                            side: MaterialStateProperty.resolveWith(
                              (Set<MaterialState> state) {
                                if (state.contains(MaterialState.disabled)) {
                                  return BorderSide(
                                    color: Colors.grey,
                                  );
                                }
                                return BorderSide(
                                  color: Colors.cyan,
                                );
                              },
                            ),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            textStyle: MaterialStateProperty.resolveWith(
                              (Set<MaterialState> state) {
                                if (state.contains(MaterialState.disabled)) {
                                  return Theme.of(context)
                                      .textTheme
                                      .button
                                      ?.copyWith(
                                        color: Colors.grey,
                                      );
                                }
                                return Theme.of(context)
                                    .textTheme
                                    .button
                                    ?.copyWith(
                                      color: Colors.cyan,
                                    );
                              },
                            ),
                          ),
                        ),
                        textButtonTheme: TextButtonThemeData(
                          style: ButtonStyle(
                            textStyle: MaterialStateProperty.all(
                              Theme.of(context).textTheme.button?.copyWith(
                                    color: Colors.cyan,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getSurveyQuestionnaireForState();
    });
  }

  Future getSurveyQuestionnaire(hospitalId, departmentId, returnRoot) async {
    var url = Constants.BASE_URL + "surveys/?department_id=$departmentId";
    var accessToken = Constants.prefs.getString('access_token');
    var response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    var data = json.decode(utf8.decode(response.bodyBytes));
    return returnRoot ? data : data.first['questions'];
  }

  Future getSurveyQuestionnaireForState() async {
    final Map<String, Object> dataFromDepartmentScreen =
        ModalRoute.of(this.context).settings.arguments;
    var hospitalId = dataFromDepartmentScreen['hospital_id'];
    var departmentId = dataFromDepartmentScreen['department_id'];
    setState(() {
      departmentName = dataFromDepartmentScreen['dept_name'];
      hospitalName = dataFromDepartmentScreen['hospital_name'];
    });
    var data = await getSurveyQuestionnaire(hospitalId, departmentId, true);
    this.setDefaultAnswers(data.first);
  }

  submitSurvey(SurveyResult result) async {
    result.results.asMap().forEach((key, value) {
      var id = value?.results[0]?.id?.id;
      if (id != 'null') {
        print(id);
        this.payload['answers'][int.parse(id)]['answer'] =
            value?.results[0]?.valueIdentifier;
        print(this.payload['answers'][int.parse(id)]['answer']);
      }
    });
    var accessToken = Constants.prefs.getString('access_token');
    var url = Constants.BASE_URL + 'submissions/';
    var data = json.encode(this.payload);
    this.processing = true;
    var response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: data);
    if (response.statusCode == 200) {
      this.processing = false;
      Toast.show("Survey submitted!", this.context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      // var jsonData = json.decode(response.body);
      setState(() {
        Navigator.pushReplacementNamed(this.context, '/home');
      });
    } else {
      this.processing = false;
      print('something went wrong');
      Toast.show("Server Error", this.context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      print(response.statusCode);
    }
  }

  void setDefaultAnswers(dynamic data) {
    var list = data['questions'];
    list.forEach((element) {
      if (element.containsKey('sub_questions')) {
        element['sub_questions'].forEach((sub) {
          sub['answer'] = false;
        });
      } else {
        element['answer'] = false;
      }
    });
    var payloadFill = {};
    payloadFill['comment'] = '';
    payloadFill['answers'] = list;
    payloadFill['images'] = [];
    payloadFill['survey_id'] = data['id'];
    payloadFill['lat'] = "0.0";
    payloadFill['lng'] = "0.0";
    setState(() => {
          questions = list,
          payload = payloadFill,
        });
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  getSampleTask() {
    List<Step> steps = [];
    List<TextChoice> choices = [];
    steps.add(InstructionStep(
      id: StepIdentifier(id: 'null'),
      title: 'Welcome to Lab Survey',
      text: 'Get ready!',
      buttonText: 'Let\'s go!',
    ));
    var total = this.questions.length;
    this.questions.asMap().forEach((index, each) => {
          choices = [],
          each['options'].forEach((eachOption) {
            choices.add(TextChoice(
                text: capitalize(eachOption['text']),
                value: eachOption['text']));
          }),
          steps.add(QuestionStep(
              id: StepIdentifier(id: index.toString()),
              title: 'Question ' + index.toString() + '/' + total.toString(),
              text: each['question'],
              answerFormat: SingleChoiceAnswerFormat(
                  defaultSelection: null, textChoices: choices)))
        });
    steps.add(CompletionStep(
      id: StepIdentifier(id: 'null'),
      text: 'Thanks for taking the survey, we will contact you soon!',
      title: 'Done!',
      buttonText: 'Submit survey',
    ));
    var task = OrderedTask(id: TaskIdentifier(), steps: steps);
    // task.addNavigationRule(
    //     forTriggerStepIdentifier: steps[0].id, navigationRule: null);
    return task;
  }
}
