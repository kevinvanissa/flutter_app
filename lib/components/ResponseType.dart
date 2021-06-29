import 'package:flutter/material.dart';
import 'package:flutter_app/components/containers.dart';

// https://www.geeksforgeeks.org/flutter-outputting-widgets-conditionally/
class ResponseType extends StatefulWidget {
  int type;
  double val;
  String text;
  double min;
  double max;
  int divisions;
  dynamic update;
  ResponseType(int this.type,
      {Key key,
      String this.text,
      double this.val = 30,
      double this.min = 0,
      double this.max = 100,
      int this.divisions = 10,
      update})
      : super(key: key);
  @override
  ResponseTypeState createState() => ResponseTypeState();
}

class ResponseTypeState extends State<ResponseType> {
  stateChange(_val) {
    setState(() {
      // print("VAL: ${_val}");
      widget.val = _val;
    });
  }

  Widget build(BuildContext context) {
    return getType(widget.type,
        val: widget.val,
        min: widget.min,
        divisions: widget.divisions,
        max: widget.max,
        text: widget.text,
        update: stateChange);
  }
}

getType(int type,
    {String text,
    double val = 30,
    double min = 0,
    double max = 100,
    int divisions = 10,
    update(val)}) {
  Widget widg;
  switch (type) {
    case 1:
      widg = textBox(text);
      break;
    case 2:
      widg = textBox(text);
      break;
    case 3:
      widg = slider(val, min, max, divisions, update);
      break;
    default:
      widg = null;
  }
  return widg;
}
