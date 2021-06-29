import 'package:flutter_app/main.dart';
import 'package:flutter_app/question_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/selection_singleton.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:flutter_app/http_service.dart';
import 'package:flutter_app/radio_button.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_app/my_geolocation.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_app/db_nosql.dart';
import 'package:flutter_app/components/ResponseType.dart';

class SurveyQuestionsDetail extends StatefulWidget {
  final List<Question> questions;
  final int surveyid;
  final String surveyname;
  double val = 0;

  SurveyQuestionsDetail(
      {@required this.questions,
      @required this.surveyid,
      @required this.surveyname});

  @override
  _SurveyQuestionsDetailState createState() => _SurveyQuestionsDetailState();
}

class _SurveyQuestionsDetailState extends State<SurveyQuestionsDetail> {
  final Selection selection = Selection();

  final HttpService httpService = HttpService();

  final MyGeolocation mygeo = MyGeolocation();

  final dbHelperNosql = AppDatabase.instance;

  // double val = 3;

  stateChange(_val) {
    setState(() {
      print("VAL: ${_val}");
      widget.val = _val;
    });
  }

  makeQuestionsCards(BuildContext context) {
    selection.createInitialValues(
        {"lat": "0.000000", "lon": "0.000000", "sid": 0, "uid": 0});
    List<RadioButton> rb = [];
    List<Widget> wl = [];

    print(widget.questions.length);
    for (int i = 0; i < widget.questions.length; i++) {
      rb.add(RadioButton(widget.questions[i], selection));
    }

    for (int i = 0; i < widget.questions.length; i++) {
      print("title: ${widget.questions[i].title}");
      print("type: ${widget.questions[i].type}");
      wl.add(Card(
        key: UniqueKey(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ListTile(
              title: Text("Question ${i + 1}"),
            ),
            ListTile(
              title: Text(widget.questions[i].title),
            ),
            SizedBox(
                child: ResponseType(widget.questions[i].type,
                    val: widget.val,
                    min: 0,
                    divisions: 5,
                    max: 5,
                    text: widget.questions[i].title,
                    update: stateChange)
                // .getType(widget.questions[i].type,
                // val: val,
                // min: 0,
                // divisions: 5,
                // max: 5,
                // text: widget.questions[i].title,
                // update: stateChange)
                ),
            // ),
          ],
        ),
      ));
    }

    selection.list = wl;
    selection.rb = rb;
    //print(wl);
    //print(selection.list);
  }

  Future<String> getUserId() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String s = sharedPreferences.getString("userid");
    return s;
  }

  @override
  Widget build(BuildContext context) {
    makeQuestionsCards(context);
    //String userid;
    getUserId().then((value) => selection.selection["uid"] = value);
    //List<Widget> rbuttons = selection.list;
    Position _currentPosition;

    TextField tf_lon = TextField(
      onChanged: (value) {
        selection.selection["lon"] = value;
      },
      controller: TextEditingController(text: "0.000000"),
      decoration: InputDecoration(
        border: new OutlineInputBorder(
            borderSide: new BorderSide(color: Colors.teal)),
        labelText: 'Longitude',
      ),
    );

    TextField tf_lat = TextField(
      onChanged: (value) {
        selection.selection["lat"] = value;
      },
      controller: TextEditingController(text: "0.000000"),
      decoration: InputDecoration(
        border: new OutlineInputBorder(
            borderSide: new BorderSide(color: Colors.teal)),
        labelText: 'Latitude',
      ),
    );

    List<Widget> otherWidgets = [
      Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text("Fetch Coordinates"),
              onPressed: () {
                print("Entering onpressed");
                mygeo.getPositon().then((val) {
                  print("Entering getPositon");
                  _currentPosition = val;
                  var lat_p = val.latitude.toString();
                  var lon_p = val.longitude.toString();
                  tf_lat.controller.text = lat_p;
                  tf_lon.controller.text = lon_p;
                  selection.selection["lat"] = lat_p;
                  selection.selection["lon"] = lon_p;
                });
              },
              color: Colors.blue,
              textColor: Colors.white,
              padding: EdgeInsets.fromLTRB(5, 3, 5, 3),
              splashColor: Colors.grey,
            ),
            tf_lat,
            SizedBox(height: 10),
            tf_lon,
            RaisedButton(
              child: Text("Save this Survey"),
              onPressed: () async {
                if (selection.checkPressedAll(widget.questions.length)) {
                  selection.selection["sid"] = widget.surveyid;
                  getUserId()
                      .then((value) => selection.selection["uid"] = value);
                  print("Selection: ${selection.selection}");
                  if (!await httpService.isConnected()) {
                    //Try insert the response in sembast when no connection
                    dbHelperNosql.insertResponse(selection.selection);
                    Toast.show(
                        "No internet connection. Operating in offline mode",
                        context,
                        duration: Toast.LENGTH_LONG,
                        gravity: Toast.CENTER);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MyApp(),
                      ),
                    );
                  }
                  final code =
                      await httpService.saveSurvey(selection.selection);
                  if (code.compareTo(1) == 0) {
                    Toast.show("Survey Succesfully Saved.", context,
                        duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
                    selection.selection.clear();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MyApp(),
                      ),
                    );
                  } else {
                    Toast.show("Error: Server Failed to return", context,
                        duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
                  }
                } else {
                  Toast.show("Need to fill out all fields", context,
                      duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
                }
              },
              color: Colors.lightBlue,
              textColor: Colors.white,
              padding: EdgeInsets.fromLTRB(9, 9, 9, 9),
              splashColor: Colors.grey,
            ),
          ],
        ),
      )
    ];
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.surveyname),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: selection.list + otherWidgets, // map
            ),
          ),
        ));
  }
}
