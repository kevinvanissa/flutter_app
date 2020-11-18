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

class SurveyQuestionsDetail extends StatelessWidget {
  final List<Question> questions;
  final int surveyid;
  final Selection selection = Selection();
  final HttpService httpService = HttpService();
  final MyGeolocation mygeo = MyGeolocation();
  final dbHelperNosql = AppDatabase.instance;

  SurveyQuestionsDetail({
    @required this.questions,
    @required this.surveyid,
  });
  //SurveyQuestionsDetail({@required this.questions, @required this.surveyid});

  makeQuestionsCards(BuildContext context) {
    //set default values for selection
    //selection.selection["lat"] = "0.000000";
    //selection.selection["lon"] = "0.000000";

    selection.createInitialValues(
        {"lat": "0.000000", "lon": "0.000000", "sid": 0, "uid": 0});
    List<RadioButton> rb = new List();
    List<Widget> wl = new List();

    //list = new List<Widget>();
    /*    selection.list = questions
        .map(
          (Question question) => Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ListTile(
                  title: Text("ID"),
                  subtitle: Text("${question.id}"),
                ),
                RadioButton(question, selection),
              ],
            ),
          ),
        )
        .toList(); */
    //return list;

    for (int i = 0; i < questions.length; i++) {
      rb.add(RadioButton(questions[i], selection));
    }

    for (int i = 0; i < questions.length; i++) {
      wl.add(Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ListTile(
              title: Text("ID"),
              subtitle: Text("${questions[i].id}"),
            ),
            rb[i],
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

                  //print(lat_p);

                  //print(_currentPosition.latitude);
                });
              },
              color: Colors.lightGreen,
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
                //  if (questions.length == selection.diffMaps()) {

                if (selection.checkPressedAll(questions.length)) {
                  selection.selection["sid"] = surveyid;
                  getUserId()
                      .then((value) => selection.selection["uid"] = value);
                  print("Selection: ${selection.selection}");

                  if (!await httpService.isConnected()) {
                    //Try insert the response in sembast when no connection
                    dbHelperNosql.insertResponse(selection.selection);
                    Toast.show(
                        "Not connection. Operating in offline mode", context,
                        duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MyApp(),
                      ),
                    );
                  }

                  final code =
                      await httpService.saveSurvey(selection.selection);
                  //final code = 1;

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
                  //print("selection: ${selection.selection}");
                  //getUserId().then((value) => print(value));
                  // print(selection.diffMaps());
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
    // rbuttons.addAll(otherWidgets);
    //print("sdfsdfsfs======>");
    //print(selection.list);
    return Scaffold(
        appBar: AppBar(
          title: Text("Survey"),
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
