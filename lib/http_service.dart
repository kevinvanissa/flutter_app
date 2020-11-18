import 'dart:convert';
import 'package:http/http.dart';
import 'package:flutter_app/survey_model.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/db.dart';
import 'package:flutter_app/question_model.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_app/db_nosql.dart';

//const SERVER_IP = 'http://10.0.2.2:5000';
const SERVER_IP = 'http://192.168.100.69:5000';

class HttpService {
  final String surveysURL = "$SERVER_IP/rest_surveys";
  SharedPreferences sharedPreferences;
  final dbHelper = DatabaseHelper.instance;
  final dbHelperNosql = AppDatabase.instance;

  Future<List<Survey>> getSurveys() async {
    sharedPreferences = await SharedPreferences.getInstance();
    List<Survey> surveys;
    String checker;
    //boolean that will be used to check connection

    var isConnectCheck = await isConnected();
    //print("In getSurvey");
    //bool con = true;
    //debugPrint("Problem HEre");
    //debugPrint("$isConnectCheck");
    //if (isConnectCheck) {
    if (isConnectCheck) {
      //debugPrint("YES I AM CONNECTED>>>>>>>>>>");
      Response res = await get(
        surveysURL,
        headers: {'x-access-token': sharedPreferences.getString("token")},
      );

      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        // debugPrint('my debug==============>: $body');
        surveys = body
            .map(
              (dynamic item) => Survey.fromJson(item),
            )
            .toList();

        //debugPrint('my debug==============>: $surveys');
        //TODO: insert here
        //dbHelper.dropTableIfExists();

        //HERE I will send off all saved responses then delete data
        dbHelperNosql.getResponses().then((listResponse) {
          listResponse.forEach((response) async {
            print(response);
            await this.saveSurvey(response);
            await dbHelperNosql.deleteResponses();
          });
        });

        dbHelper.deleteAllQuestions();
        dbHelper.deleteAllSurvey();

        surveys.forEach((survey) async {
          await dbHelper.insertSurveyQuestions(survey);
        });
      } else {
        throw "Can't get posts.";
      } //ifelse for connection

    } else {
      debugPrint("I AM NOT CONNECTED!!!!!!!!!!!!!");
      List<Survey> lSurvey = new List();
      await dbHelper.queryAllRowsSurvey().then((surveyList) {
        //print(surveyList);
        surveyList.forEach((survey) async {
          //print(survey);
          List<Question> qList = new List();
          var questionList = await dbHelper.queryRowsQuestion(survey['_id']);
          //print(questionList);
          questionList.forEach((question) {
            //print(question);
            qList.add(new Question(
                id: question['qid'],
                title: question['qtitle'],
                dimension: question['dimension'],
                type: question['qtype']));
          });
          //print(qList[0].title);
          //print(survey['_id']);
          List<Survey> surveysLocal = new List();
          surveysLocal.add(new Survey(
              id: survey['_id'],
              name: survey['name'],
              description: survey['description'],
              questions: qList));
          //Survey survey = new Survey();
          //print(r);
          //Question question = new Question();
          //print(surveysLocal[0].description);
          surveys = surveysLocal;
          //return surveysLocal;
          //print(surveys);
        });
        //print(lSurvey);
      });
      //print("No Connection");
      //print(surveysLocal);
      //return surveysLocal;

    }
    //print(surveys);
    //print("not hsere");
    //print(checker);
    await new Future.delayed(const Duration(seconds: 3));
    return surveys;
  } //end getSurveys

  Future<int> saveSurvey(Map<String, dynamic> data) async {
    sharedPreferences = await SharedPreferences.getInstance();

    var jsonResponse = null;
    var response = await post("$SERVER_IP/rest_save_survey",
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'x-access-token': sharedPreferences.getString("token"),
        },
        body: json.encode(data));
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      //return Future.value(1);
      return 1;
    } else {
      print(response.body);
      return Future.value(-1);
    }
  } //save Survey

  isConnected() async {
    var connected = true;
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      // Mobile is not Connected to Internet

      connected = false;
    }
    //print("Is connectedL: $connected");
    //return connected;
    return Future.value(connected);
  }

  void _insert() async {
    // row to insert
    Map<String, dynamic> row = {
      DatabaseHelper.surveyId: 1,
      DatabaseHelper.surveyName: 'My survey',
      DatabaseHelper.surveyDescription: 'My Description'
    };
    final id = await dbHelper.insert(row);
    print('inserted row id: $id');
  } //end _insert

}
