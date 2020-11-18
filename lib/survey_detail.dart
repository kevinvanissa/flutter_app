import 'package:flutter_app/survey_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/http_service.dart';
// import 'package:grouped_buttons/grouped_buttons.dart';
// import 'package:flutter_app/question_model.dart';
import 'package:flutter_app/survey_questions_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/login.dart';
import 'package:flutter_app/main.dart';

class SurveyDetail extends StatelessWidget {
  final Survey survey;
  final HttpService httpService = HttpService();

  SurveyDetail({@required this.survey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Survey Info"),
          actions: <Widget>[
            // TODO: This is not working!!!!!!!!!!
            FlatButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (BuildContext context) => MainPage()),
                    (Route<dynamic> route) => false);
              },
              child: Text("Refresh Surveys",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: <Widget>[
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      ListTile(
                        title: Text("Name"),
                        subtitle: Text(survey.name),
                      ),
                      ListTile(
                        title: Text("ID"),
                        subtitle: Text("${survey.id}"),
                      ),
                      ListTile(
                        title: Text("Description"),
                        subtitle: Text(survey.description),
                      ),
                      RaisedButton(
                        child: Text("Administer Survey"),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SurveyQuestionsDetail(
                              questions: survey.questions,
                              surveyid: survey.id,
                            ),
                          ),
                        ),
                        color: Colors.lightBlue,
                        textColor: Colors.white,
                        padding: EdgeInsets.fromLTRB(9, 9, 9, 9),
                        splashColor: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
