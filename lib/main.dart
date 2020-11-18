import 'dart:convert';
import 'package:async/async.dart';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/http_service.dart';
import 'package:flutter_app/survey_model.dart';
import 'package:flutter_app/survey_detail.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
//import 'package:connectivity/connectivity.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Cart Survey App",
      debugShowCheckedModeBanner: false,
      home: MainPage(),
      theme: ThemeData(accentColor: Colors.white70),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  SharedPreferences sharedPreferences;
  final HttpService httpService = HttpService();

  @override
  void initState() {
    //debugPrint("Hello=======>");
    super.initState();
    Future(() {
      checkLoginStatus();
    });
  }

  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    //print(sharedPreferences.getString("token"));
    String myToken = sharedPreferences.getString("token");

    if (sharedPreferences.getString("token") == null ||
        JwtDecoder.isExpired(myToken)) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
          (Route<dynamic> route) => false);
    }
  }

  FutureBuilder makeFutureBuilder() {
    Widget fb = FutureBuilder(
      future: httpService.getSurveys(),
      builder: (BuildContext context, AsyncSnapshot<List<Survey>> snapshot) {
        if (snapshot.hasError) return Text("Error has occurred");

        if (snapshot.hasData) {
          List<Survey> surveys = snapshot.data;
          return ListView(
            children: surveys
                .map(
                  (Survey survey) => ListTile(
                    title: Text("${survey.name}"),
                    subtitle: Text("${survey.id}"),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SurveyDetail(
                          survey: survey,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
    return fb;
  } //End Future Builder

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Surveys", style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (BuildContext context) => MainPage()),
                  (Route<dynamic> route) => false);
            },
            child:
                Text("Referesh Surveys", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: makeFutureBuilder(),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Options'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Help'),
              onTap: () {},
            ),
            ListTile(
              title: Text('Log Out'),
              onTap: () {
                sharedPreferences.clear();
                sharedPreferences.commit();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (BuildContext context) => LoginPage()),
                    (Route<dynamic> route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
