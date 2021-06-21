import 'package:flutter_app/question_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/selection_singleton.dart';

//ignore: must_be_immutable
class RadioButton extends StatefulWidget {
  final Question question;
  final Selection s;
  RadioButton(this.question, this.s);
  bool _isSelected = false;

  bool isSelected() {
    return _isSelected;
  }

  @override
  MyButtonState createState() => new MyButtonState();
}

class MyButtonState extends State<RadioButton> {
  int _selected = 9999;

  void onChanged(int value) {
    setState(() {
      _selected = value;
      widget._isSelected = true;
    });
    print('Value = $value');
  }

  int getSelected() {
    return this._selected;
  }

  List<Widget> makeRadios() {
    List<Widget> list = new List<Widget>();
    String _picked = "Two";
    //widget.s.selection["mad"] = 1;

    /* for (int i = 0; i < 3; i++) {
      list.add(new Row(
        children: [
          new Text('Radio $i'),
          new Radio(
              activeColor: Colors.green,
              value: i,
              groupValue: _selected,
              onChanged: (int value) {
                onChanged(value);
              })
        ],
      ));
    } //endfor */
    List<String> q = [
      "Strongly Agree",
      "Agree",
      "Unsure",
      "Disagree",
      "Strongly Disagree"
    ];

    List<String> r = ["Yes", "Unsure", "No"];

    var scores_q = {0: 20, 1: 5, 2: 0, 3: -5, 4: -20};
    var scores_r = {0: 15, 1: 0, 2: -15};

    list.add(new Text(widget.question.title));

    if (widget.question.type == 3) {
      for (int i = 0; i < q.length; i++) {
        list.add(new RadioListTile(
          value: i,
          title: new Text(q[i]),
          groupValue: _selected,
          onChanged: (int value) {
            onChanged(value);
            widget.s.selection[widget.question.id.toString()] =
                scores_q[_selected];
            // print('q' + widget.question.id.toString());
          },
          activeColor: Colors.red,
          secondary: new Icon(Icons.home),
          subtitle: new Text('Sub Title here'),
        ));
      }
    } else {
      for (int i = 0; i < r.length; i++) {
        list.add(new RadioListTile(
          value: i,
          title: new Text(r[i]),
          groupValue: _selected,
          onChanged: (int value) {
            onChanged(value);
            widget.s.selection[widget.question.id.toString()] =
                scores_r[_selected];
          },
          activeColor: Colors.red,
          secondary: new Icon(Icons.home),
          subtitle: new Text('Sub Title here'),
        ));
      }
    }

    //list.add(rbg);
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: makeRadios(),
    );
  }
}
