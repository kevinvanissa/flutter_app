import 'package:flutter/foundation.dart';

class Question {
  final int id;
  final String title;
  final String dimension;
  final int type;

  Question({
    @required this.id,
    @required this.title,
    @required this.dimension,
    @required this.type,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as int,
      title: json['title'] as String,
      dimension: json['dimension'] as String,
      type: json['type'] as int,
    );
  }

  Map<String, dynamic> toJson(int sid) {
    return {
      'qid': id,
      'sid': sid,
      'qtitle': title,
      'dimension': dimension,
      'qtype': type
    };
  }
}
