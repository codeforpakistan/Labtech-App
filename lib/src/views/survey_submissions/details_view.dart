import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:hospection/src/utils/constants.dart';
import 'package:hospection/src/views/survey_submissions/image_view.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ShowSurveyDetails extends StatefulWidget {
  @override
  _ShowSurveyDetailsState createState() => _ShowSurveyDetailsState();
}

class _ShowSurveyDetailsState extends State<ShowSurveyDetails> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool showFullValue = false;

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
    List<dynamic> submissions = dataFromHospitalScreen['submissions'];
    var surveyId =
        submissions.length > 0 ? submissions[0]['submission_id'] : null;
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
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Center(
                    child: Text(
                        "Some unknown error has occurred, please contact your system administrator"));
              }
              if (!snapshot.hasData ||
                  snapshot.data == null ||
                  (snapshot.data != null && snapshot.data.length == 0)) {
                return Center(child: Text("No Submission Found"));
              }
              print('here');
              print(snapshot.data);
              final List<Widget> imageSliders = snapshot.data.length > 0 &&
                      snapshot.data['images'] != null
                  ? snapshot.data['images']
                      .map<Widget>((item) => Container(
                            margin: EdgeInsets.all(5.0),
                            child: ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)),
                                child: Stack(
                                  children: <Widget>[
                                    InkResponse(
                                        child: Image.network(
                                            Constants.BASE_URL +
                                                "utils/image/" +
                                                item,
                                            fit: BoxFit.cover,
                                            width: 1000.0),
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) {
                                                    return ImageView(
                                                        tag: item,
                                                        images: snapshot
                                                            .data['images']);
                                                  },
                                                  settings: RouteSettings(
                                                      name: 'ImageView')));
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
                      .toList()
                  : [];
              return Column(
                children: [
                  snapshot.data['images'] != null &&
                          snapshot.data['images'].length > 0
                      ? CarouselSlider(
                          options: CarouselOptions(
                            aspectRatio: 3.0,
                            enlargeCenterPage: true,
                            enableInfiniteScroll: false,
                            pageViewKey:
                                PageStorageKey<String>('carousel_slider'),
                          ),
                          items: imageSliders,
                        )
                      : Center(),
                  Expanded(
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data['answers'].length,
                        itemBuilder: (context, index) {
                          if (index == (snapshot.data['answers'].length - 1) &&
                              snapshot.data['answers'][index]['comment'] !=
                                  null) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  top: 20.0,
                                  left: 30.0,
                                  right: 20.0,
                                  bottom: 20.0),
                              child: Material(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 5.0),
                                        child: Text("Comment:",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                            )),
                                      ),
                                      Text(snapshot.data['answers'][index]
                                          ['comment']),
                                    ]),
                              ),
                            );
                          } else if (snapshot.data['answers'][index]
                                  ["question"] !=
                              null) {
                            return ListTile(
                              leading: snapshot.data['answers'][index]
                                          ["answer"] !=
                                      null
                                  ? new GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          showFullValue = !showFullValue;
                                        });
                                        print(showFullValue);
                                      },
                                      child: new Text(snapshot
                                                      .data['answers'][index]
                                                          ["answer"]
                                                      .length >=
                                                  6 &&
                                              !showFullValue
                                          ? snapshot.data['answers'][index]
                                                      ["answer"]
                                                  .substring(0, 6) +
                                              '..'
                                          : snapshot.data['answers'][index]
                                              ["answer"]),
                                    )
                                  : null,
                              title: Text(
                                  snapshot.data['answers'][index]["question"]),
                            );
                          } else {
                            return null;
                          }
                        }),
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
