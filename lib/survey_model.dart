import 'package:flutter/foundation.dart';
import 'package:flutter_app/question_model.dart';

class Survey {
  final int id;
  final String name;
  final String description;
  final List<Question> questions;

  Survey({
    @required this.id,
    @required this.name,
    @required this.description,
    @required this.questions,
  });

  factory Survey.fromJson(Map<String, dynamic> json) {
    return Survey(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      // questions: json['questions'] as List<Question>,
      questions: List<Question>.from(
          json["questions"].map((e) => Question.fromJson(e))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
    };
  }
}
