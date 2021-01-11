import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:hospection/src/utils/constants.dart';
import 'package:hospection/src/views/survey_submissions/image_view.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ShowSurveyDetails extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future getSurveyDetailsData(surveyId) async {
    var url = Constants.BASE_URL + "submissions/$surveyId";
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
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, Object> dataFromHospitalScreen =
        ModalRoute.of(context).settings.arguments;
    var surveyId = dataFromHospitalScreen['survey_id'];
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Survey Details",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder(
        future: getSurveyDetailsData(surveyId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Center(child: Text("Getting the survey details"));
              break;
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Some unknown error has occurred, please contact your system administrator"));
              }
              final List<Widget> imageSliders = snapshot.data['images']
                .map<Widget>((item) => Container(
                  margin: EdgeInsets.all(5.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    child: Stack(
                      children: <Widget>[
                        InkResponse(
                          child: Image.network(
                            Constants.BASE_URL + "utils/image/" + item,
                            fit: BoxFit.cover,
                            width: 1000.0),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) {
                              return ImageView(tag: item, images: snapshot.data['images']);
                            }, settings: RouteSettings(name: 'ImageView')));
                          }),
                          Positioned(
                            bottom: 0.0,
                            left: 0.0,
                            right: 0.0,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color.fromARGB(200, 0, 0, 0),
                                    Color.fromARGB(0, 0, 0, 0)
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 20.0),
                              child: Text(
                                '${snapshot.data['images'].indexOf(item) + 1}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    )),
                  ))
                .toList();
              return Column(
                children: [
                  snapshot.data['images'].length > 0
                      ? CarouselSlider(
                          options: CarouselOptions(
                            aspectRatio: 3.0,
                            enlargeCenterPage: true,
                            enableInfiniteScroll: false,
                            pageViewKey: PageStorageKey<String>('carousel_slider'),
                          ),
                          items: imageSliders,
                        )
                      : Center(),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data['answers'].length + 1,
                      itemBuilder: (context, index) {
                        if (index >= snapshot.data['answers'].length) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              top: 20.0,
                              left: 30.0,
                              right: 20.0,
                              bottom: 20.0),
                            child: Material(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 5.0),
                                    child: Text(
                                      "Comment:", 
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      )
                                    ),
                                  ),
                                  Text(snapshot.data['comment']), 
                                ]
                              ),
                            ),
                          );
                        } else {
                          if (snapshot.data['answers'][index]
                              .containsKey('sub_questions')) {
                            var subQuestions =
                                snapshot.data['answers'][index]['sub_questions'];
                            return Column(
                              children: [
                                ListTile(
                                  leading: Icon(Icons.check_box,
                                      color: Colors.grey[200]),
                                  title: Text(snapshot.data['answers'][index]
                                      ['question']),
                                ),
                                ListView.builder(
                                    itemCount: subQuestions.length,
                                    physics: ClampingScrollPhysics(),
                                    shrinkWrap: true,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(left: 50.0),
                                        child: ListTile(
                                          leading: subQuestions[index]["answer"]
                                              ? Icon(Icons.check,
                                                  color: Colors.lightGreen)
                                              : Icon(Icons.close,
                                                  color: Colors.red),
                                          title: Text(
                                              subQuestions[index]['question']),
                                        ),
                                      );
                                    }),
                              ],
                            );
                          } else {
                            return ListTile(
                              leading: snapshot.data['answers'][index]["answer"]
                                  ? Icon(Icons.check, color: Colors.lightGreen)
                                  : Icon(Icons.close, color: Colors.red),
                              title: Text(
                                  snapshot.data['answers'][index]["question"]),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              );
              break;
            case ConnectionState.active:
            case ConnectionState.waiting:
            default:
              return Center(child: CircularProgressIndicator());
              break;
          }
        },
      ),
    );
  }
}
