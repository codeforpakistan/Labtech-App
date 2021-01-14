import 'dart:io';
import 'package:path/path.dart';
import 'package:async/async.dart';

import 'package:hospection/src/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:hospection/src/widgets/switch_widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';

class SubmitSurvey extends StatefulWidget {
  @override
  _SubmitSurveyState createState() => _SubmitSurveyState();
}

class _SubmitSurveyState extends State<SubmitSurvey> {
  TextStyle style = TextStyle(fontSize: 20.0);
  double _latitude, _longitude;
  List<dynamic> questions = [];
  dynamic payload;
  String departmentName;
  String hospitalName;
  TextEditingController commentController = new TextEditingController();
  List<File> imageFiles = [];
  bool processing = false;
  bool isLoading = true;
  final ScrollController _scrollController = ScrollController();

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
    payloadFill['lat'] = this._latitude;
    payloadFill['lng'] = this._longitude;
    payloadFill['survey_id'] = data['id'];
    setState(() => {
      questions = list,
      payload = payloadFill,
    });
  }

  @override
  void initState() {
    super.initState();
    _setCurrentLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getSurveyQuestionnaireForState();
    });
  }

  // read location from shared preferences 
  void _setCurrentLocation() async {
    _latitude = Constants.prefs.getDouble('latitude');
    _longitude = Constants.prefs.getDouble('longitude');
    if (_latitude == null) {
      print('location Not provided');
      _latitude =  0;
      _longitude =  0;
    }
  }

  dynamic updateFromChild(bool val, int qid, int sqid) {
    if (sqid == -1) {
      // no subquestions..
      this.questions.forEach((element) {
        if (element['q_id'] == qid) {
          element['answer'] = val;
        }
      });
    } else {
      // update subquestion response..
      this.questions.forEach((element) {
        if (element['q_id'] == qid) {
          element['sub_questions'].forEach((sub) {
            if (sub['s_q_id'] == sqid) {
              sub['answer'] = val;
            }
          });
        }
      });
    }
    this.payload['answers'] = this.questions;
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
    this.processing = true;
    // upload image and save the name in the survey submission payload.
    var accessToken = Constants.prefs.getString('access_token');
    var stream =
        new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    // get file length
    var length = await imageFile.length();
    Map<String, String> headers = {
      "Accept": "application/json",
      "Authorization": "Bearer " + accessToken
    };
    var timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    ;
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
      var jsonData = json.decode(value);
      var fileName = jsonData['filename'];
      setState(() {
        payload['images'].add(fileName);
      });
      print(payload['images']);
    });
    this.processing = false;
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

  @override
  Widget build(BuildContext context) {
    final commentField = TextFormField(
      controller: commentController,
      style: TextStyle(fontSize: 16.0),
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Comment",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12.0))),
    );

    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              color: Colors.white,
              icon: Icon(Icons.arrow_back_ios),
              tooltip: "Cancel and Return to List",
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/home', (Route<dynamic> route) => false);
              },
            ),
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
            automaticallyImplyLeading: false,
            title: Text(
              "Survey Questions",
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: questions != null && questions.length > 0 && !processing
              ? Column(
                  children: [
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            Flexible(
                              child: Center( child: Text(this.hospitalName + " > " + this.departmentName,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal)))
                            ),
                          ]
                        )
                      )
                    ),
                    Container(
                      height: 120,
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(1.0),
                        scrollDirection: Axis.horizontal,
                        itemCount:
                            imageFiles.length == 0 ? 1 : imageFiles.length,
                        itemBuilder: (BuildContext context, int index) =>
                            imageFiles.length == 0
                                ? InkResponse(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 50.0),
                                    child: Text("Attach Images (optional)",
                                      style: TextStyle(fontSize: 16))),
                                  onTap: () {
                                    _showPicker(context);
                                  })
                                : Image.file(
                                    imageFiles[index],
                                    fit: BoxFit.fitWidth,
                                  ),
                      ),
                    ),
                    // this is it
                    Expanded(
                      child: Scrollbar(
                        isAlwaysShown: true,
                        controller: _scrollController,
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: questions.length + 2,
                          itemBuilder: (context, index) {
                            if (index >= questions.length) {
                              if (index == questions.length) {
                              return isLoading ? Padding(
                                  padding: const EdgeInsets.only(
                                    top: 10.0,
                                    left: 20.0,
                                    right: 20.0,
                                    bottom: 0.0),
                                  child: Material(
                                    child: commentField,
                                  ),
                                )
                                : Center();
                              } else {
                              return isLoading
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      top: 20.0,
                                      left: 60.0,
                                      right: 60.0,
                                      bottom: 40.0),
                                  child: Material(
                                    elevation: 5.0,
                                    borderRadius: BorderRadius.circular(30.0),
                                    color: Colors.lightGreen,
                                    child: MaterialButton(
                                      minWidth: MediaQuery.of(context).size.width,
                                      padding:
                                          EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                      onPressed: () {
                                        this.payload['comment'] =
                                            commentController.text;
                                        setState(() {
                                          isLoading = true;
                                        });
                                        showSubmitConfirmationDialog(context);
                                      },
                                      child: Text("Submit Survey",
                                          textAlign: TextAlign.center,
                                          style: style.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                )
                              : Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            } else {
                              if (questions[index].containsKey('sub_questions')) {
                                var subQuestions =
                                    questions[index]['sub_questions'];
                                var mainQid = questions[index]['q_id'];
                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5.0),
                                      child: ListTile(
                                        title: Text(
                                          questions[index]['question'],
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ),
                                    ListView.builder(
                                        itemCount: subQuestions.length,
                                        physics: ClampingScrollPhysics(),
                                        shrinkWrap: true,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return Padding(
                                            padding:
                                                const EdgeInsets.only(left: 20.0),
                                            child: ListTile(
                                              title: Text(
                                                subQuestions[index]['question'],
                                                style: TextStyle(fontSize: 16),
                                              ),
                                              trailing: SwitchWidgetClass(
                                                  updateFromChild,
                                                  mainQid,
                                                  subQuestions[index]['s_q_id'],
                                                  subQuestions[index]['answer']
                                                ),
                                            ),
                                          );
                                        }),
                                  ],
                                );
                              } else {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 5.0),
                                  child: ListTile(
                                    title: Text(
                                      questions[index]['question'],
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    trailing: SwitchWidgetClass(
                                      updateFromChild,
                                      questions[index]['q_id'],
                                      -1,
                                      questions[index]['answer'],
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                        )
                      ),
                    ),
                  ],
                )
              : Center(child: CircularProgressIndicator()));
    });
  }

  void printWrapped(String text) {
    final pattern = new RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  submitSurvey() async {
    var accessToken = Constants.prefs.getString('access_token');
    var url = Constants.BASE_URL + 'submissions/';
    var data = json.encode(this.payload);
    printWrapped(data);
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

  showSubmitConfirmationDialog(BuildContext context) {
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed:  () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Yes"),
      onPressed:  () {
        submitSurvey();
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Submit Survey?"),
      content: Text("Are you sure you want to submit?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

}
