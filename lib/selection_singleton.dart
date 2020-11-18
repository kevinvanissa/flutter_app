import 'package:flutter/material.dart';
import 'package:flutter_app/radio_button.dart';

class Selection {
  static final Selection _singleton = Selection._internal();
  Map<String, dynamic> selection = new Map();
  var countInitialValues = 0;
  // List of radio buttons
  List<Widget> list = new List<Widget>();
  List<RadioButton> rb = new List<RadioButton>();

  createInitialValues(Map<String, dynamic> initialValues) {
    selection = initialValues;
    countInitialValues = initialValues.length;
  }

  int diffMaps() {
    var diff = 0;
    diff = selection.length - countInitialValues;
    return diff;
  }

  bool checkPressedAll(int questionListSize) {
    var checked = false;
    var counter = 0;
    print("List RB length ${rb.length}");
    for (int i = 0; i < list.length; i++) {
      print("${rb[i].isSelected()}");
      if (rb[i].isSelected()) {
        counter += 1;
      }
    }
    if (counter == questionListSize) {
      checked = true;
    }

    return checked;
  }

  factory Selection() {
    return _singleton;
  }

  Selection._internal();
}
