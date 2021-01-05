import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hospection/src/utils/constants.dart';

class ImageView extends StatefulWidget {
  final String tag;
  final List<dynamic> images;
  ImageView({Key key, @required this.tag, @required this.images})
    : assert(tag != null),
      assert(images != null),
      super(key: key);
  @override
  _ImageViewState createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  @override
  initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
  }
  final _scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  void dispose() {
    //SystemChrome.restoreSystemUIOverlays();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar(
      title: Text(
        "Survey Images",
        style: TextStyle(color: Colors.white),
      ),
    );
     final List<Widget> imageSliders = widget.images
      .map<Widget>((item) => Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.fromLTRB(0.0, 1.0, 0.0, 0.0),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          child: Stack(
            children: <Widget>[
              Image.network(
                  Constants.BASE_URL + "utils/image/" + item,
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height
                ),
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
                        vertical: 5.0, horizontal: 10.0),
                    child: Text(
                      '${widget.images.indexOf(item) + 1}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ),
        ))
      .toList();
    return Scaffold(
      key: _scaffoldKey,
      appBar: appBar,
      body: Column(
        children: [
          widget.images.length > 0
            ? CarouselSlider(
              options: CarouselOptions(
                viewportFraction: 0.98,  
                height: MediaQuery.of(context).size.height - (appBar.preferredSize.height * 2.5),
                aspectRatio: 1.0,
                enlargeCenterPage: true,
                enableInfiniteScroll: false,
                pageViewKey: PageStorageKey<String>('carousel_slider'),
              ),
              items: imageSliders,
            )
          : Center(),
        ],
      )
    );
  }

}