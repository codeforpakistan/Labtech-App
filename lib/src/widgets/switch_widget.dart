import 'package:flutter/material.dart';

// ignore: must_be_immutable
class SwitchWidgetClass extends StatefulWidget {
  Function(bool val, int qid, int sqid) notifyParent;
  int qid; //question id
  int sqid; //sub question id
  bool currentValue;
  SwitchWidgetClass(this.notifyParent, this.qid, this.sqid, this.currentValue);

  @override
  _SwitchWidgetClassState createState() => _SwitchWidgetClassState(
      this.notifyParent, this.qid, this.sqid, this.currentValue);
}

class _SwitchWidgetClassState extends State<SwitchWidgetClass> {
  Function(bool val, int qid, int sqid) notifyParent;
  int qid; //question id
  int sqid; //sub question id
  bool currentValue;
  bool switchControl = false;

  _SwitchWidgetClassState(
      this.notifyParent, this.qid, this.sqid, this.currentValue);

  @override
  void initState() {
    super.initState();
    this.switchControl = this.currentValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Transform.scale(
          scale: 1.5,
          child: Switch(
            onChanged: toggleSwitch,
            value: switchControl,
            activeColor: Colors.lightGreen,
            activeTrackColor: Colors.lightGreen[200],
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey[300],
          )),
    ]);
  }

  void toggleSwitch(bool value) {
    setState(() {
      switchControl = !switchControl;
    });
    this.notifyParent(switchControl, this.qid, this.sqid);
  }
}
