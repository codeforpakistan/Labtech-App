import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart' hide Step;
import 'package:survey_kit/survey_kit.dart';
import 'package:hospection/src/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hospection/src/models/survey_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';

class SurveyView extends StatefulWidget {
  @override
  _MySurveyState createState() => _MySurveyState();
}

class _MySurveyState extends State<SurveyView> {
  String departmentName;
  String hospitalName;
  String moduleName;
  int hospitalId;
  int departmentId;
  dynamic payload;
  List<dynamic> questions = [];
  bool processing = false;
  String surveyKey;
  List<File> imageFiles = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          primarySwatch: Colors.lightGreen,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: 'Century Gothic',
          highlightColor: Colors.lightGreen),
      home: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add_a_photo),
              color: Colors.white,
              tooltip: "Upload image",
              onPressed: () {
                _showPicker(context);
              },
            ),
          ],
        ),
        body: questions != null && questions.length > 0
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
                          backwardsCompatibility: false,
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
    _initialStorageSettings();
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
    setState(() {
      hospitalId = dataFromDepartmentScreen['hospital_id'];
      departmentId = dataFromDepartmentScreen['department_id'];
      departmentName = dataFromDepartmentScreen['dept_name'];
      hospitalName = dataFromDepartmentScreen['hospital_name'];
      moduleName = dataFromDepartmentScreen['module_name'];
      surveyKey = hospitalId.toString() + departmentId.toString();
    });
    var data =
        await getSurveyQuestionnaire(this.hospitalId, this.departmentId, true);
    this.setDefaultAnswers(data.first);
  }

  _initialStorageSettings() async {
    print('_initialStorageSettings');
    _listKeysInHive();
  }

  Future<bool> _addSurveyInHive(dynamic data, String key) async {
    try {
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(SurveyModelAdapter());
      }
      ;
      var box = await Hive.openBox<SurveyModel>(Constants.HIVE_SURVEYS_BOX);
      // construct Survey instance
      var surveyItem = SurveyModel(int.parse(key), data, new DateTime.now());
      box.put(this.surveyKey, surveyItem);
      print('Survey stored in hive');
      return true;
    } catch (error) {
      print('hive error');
      print(error);
      return false;
    }
  }

  _listKeysInHive() async {
    try {
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(SurveyModelAdapter());
      }
      ;
      var box = await Hive.openBox<SurveyModel>(Constants.HIVE_SURVEYS_BOX);
      print('box.keys');
      print(box.keys);
      box.keys.forEach((k) {
        print(k);
        SurveyModel survey = box.get(k);
        printWrapped(json.encode(survey.payload));
      });
    } catch (error) {
      print('hive error');
      print(error);
      return false;
    }
  }

  void printWrapped(String text) {
    final pattern = new RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } on SocketException catch (_) {
      return false;
    }
  }

  submitSurvey(SurveyResult result) async {
    try {
      result.results.asMap().forEach((key, value) {
        var id = value?.results[0]?.id?.id;
        if (id != 'null') {
          if (int.parse(id) > this.payload['answers'].length) {
            this.payload['answers'].add({
              'answer': value?.results[0]?.valueIdentifier,
              'comment': value?.results[0]?.valueIdentifier,
              'question': null
            });
          } else {
            this.payload['answers'][int.parse(id)]['answer'] =
                value?.results[0]?.valueIdentifier;
            print(this.payload['answers'][int.parse(id)]['answer']);
          }
        }
      });
      var hasInternet = await _checkInternetConnection();
      if (hasInternet) {
        var accessToken = Constants.prefs.getString('access_token');
        var url = Constants.BASE_URL + 'submissions/';
        var data = json.encode(this.payload);
        var response = await http.post(url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
            body: data);
        if (response.statusCode == 200) {
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
      } else {
        Toast.show(
            "No internet! Saving survey response to upload later", this.context,
            duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
        print('_addSurveyInHive');
        // save in hive
        print('saving in hive');
        printWrapped(json.encode(this.payload));
        var hiveResp = await _addSurveyInHive(this.payload, this.surveyKey);
        if (hiveResp) {
          setState(() {
            Navigator.pushReplacementNamed(this.context, '/home');
          });
        } else {
          Toast.show("Server Error. Please contact support", this.context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        }
      }
    } catch (error) {
      Toast.show("Submission Error", this.context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      print(error);
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
    payloadFill['meta'] = {
      'hospitalName': this.hospitalName,
      'indicatorName': this.departmentName,
      'moduleName': this.moduleName,
      'id': this.hospitalId,
      'indicatorId': this.departmentId,
      // 'userName': this.userId,
    };
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
              isOptional: false,
              id: StepIdentifier(id: index.toString()),
              title: 'Question ' + index.toString() + '/' + total.toString(),
              text: each['question'],
              answerFormat: SingleChoiceAnswerFormat(
                  defaultSelection: null, textChoices: choices)))
        });
    steps.add(QuestionStep(
      id: StepIdentifier(id: (this.questions.length + 1).toString()),
      title: 'Comments',
      text: 'Please Enter you remarks',
      answerFormat: TextAnswerFormat(
        maxLines: 10,
      ),
    ));
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

  void _showPicker(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.photo_library),
                    title: new Text('Photo Library'),
                    onTap: () {
                      _getFromGallery();
                      Navigator.of(context).pop();
                    }),
                new ListTile(
                  leading: new Icon(Icons.photo_camera),
                  title: new Text('Camera'),
                  onTap: () {
                    _getFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _getFromCamera() async {
    PickedFile pickedFile = await ImagePicker().getImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        imageFiles.add(File(pickedFile.path));
      });
      await _uploadImage(File(pickedFile.path));
    }
  }

  _getFromGallery() async {
    PickedFile pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        imageFiles.add(File(pickedFile.path));
      });
      await _uploadImage(File(pickedFile.path));
    }
  }

  _uploadImage(File imageFile) async {
    // upload image and save the name in the survey submission payload.
    var accessToken = Constants.prefs.getString('access_token');
    var stream =
        // ignore: deprecated_member_use
        new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    // get file length
    var length = await imageFile.length();
    Map<String, String> headers = {
      "Accept": "application/json",
      "Authorization": "Bearer " + accessToken
    };
    var timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    // string to uri
    var uri = Uri.parse(Constants.BASE_URL + 'utils/uploadimage/');
    var request = new http.MultipartRequest("POST", uri);
    var multipartFileSign = new http.MultipartFile('file', stream, length,
        filename: timeStamp + basename(imageFile.path));
    request.files.add(multipartFileSign);
    request.headers.addAll(headers);
    var response = await request.send();
    // listen for response
    response.stream.transform(utf8.decoder).listen((value) {
      if ('Internal Server Error' == value) {
        Toast.show("Image Upload Failed Internal Server Error.", this.context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      } else {
        var jsonData = json.decode(value);
        var fileName = jsonData['filename'];
        setState(() {
          payload['images'].add(fileName);
        });
        Toast.show("Image Uploaded Successfully!", this.context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      }
    });
  }
}
