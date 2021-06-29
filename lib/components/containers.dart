import 'package:flutter/material.dart';

slider(double val, double min, double max, int divisions, update) {
  return Container(
      child: SliderTheme(
          data: SliderThemeData(
            activeTrackColor: Colors.green,
            thumbColor: Colors.blue,
            // overlayColor: Colors.blue
          ),
          child: Slider(
            value: val,
            min: min,
            max: max,
            divisions: divisions,
            label: val.round().toString(),
            onChanged: update,
          )));
}

textBox(String text) {
  return Container(
      child: TextField(
    decoration: InputDecoration(border: OutlineInputBorder(), hintText: text),
  ));
}
