import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_app/survey_model.dart';

class DatabaseHelper {
  static final _databaseName = "cart.db";
  static final _databaseVersion = 1;

  static final surveyTable = 'survey';
  static final surveyId = '_id';
  static final surveyName = 'name';
  static final surveyDescription = 'description';

  static final questionTable = 'question';

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    //String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $surveyTable (
            $surveyId INTEGER PRIMARY KEY,
            $surveyName TEXT NOT NULL,
            $surveyDescription TEXT NOT NULL
          )
          ''');
    await db.execute('''
          CREATE TABLE question (
            qid INTEGER PRIMARY KEY,
            sid INTEGER NOT NULL,
            qtitle TEXT NOT NULL,
            dimension TEXT NOT NULL,
            qtype INTEGER NOT NULL,
            FOREIGN KEY (sid) REFERENCES survey (_id) ON DELETE NO ACTION ON UPDATE NO ACTION
          )
          ''');

    await db.execute('''
          CREATE TABLE response (
            rid INTEGER PRIMARY KEY AUTOINCREMENT,
            qid INTEGER NOT NULL,
            resp INTEGER NOT NULL,
            lat TEXT NOT NULL,
            lon TEXT NOT NULL,
            FOREIGN KEY (qid) REFERENCES question (qid) ON DELETE NO ACTION ON UPDATE NO ACTION
          )
          ''');
  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(surveyTable, row);
  }

  insertResponses(Map<dynamic, dynamic> row) async {}

  insertSurveyQuestions(Survey survey) async {
    Database db = await instance.database;
    Batch batch = db.batch();

    await db.insert(surveyTable, survey.toJson());
    /* survey.questions.forEach((question) async {
      //print(question.toJson(survey.id));
      await db.insert('question', question.toJson(survey.id));
    }); */
    var buffer = new StringBuffer();
    survey.questions.forEach((c) {
      if (buffer.isNotEmpty) {
        buffer.write(",\n");
      }

      buffer.write("('");
      buffer.write(c.id);
      buffer.write("', '");
      buffer.write(survey.id);
      buffer.write("', '");
      buffer.write(c.title);
      buffer.write("', '");
      buffer.write(c.dimension);
      buffer.write("', '");
      buffer.write(c.type);
      buffer.write("')");
    });
    var raw = await db
        .rawInsert("INSERT Into question (qid,sid,qtitle,dimension,qtype)"
            " VALUES ${buffer.toString()}");
    //print(raw);

    //queryAllRows().then((value) => print(value[0]));

    print("Seems like everything worked well");
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRowsSurvey() async {
    Database db = await instance.database;
    return await db.query(surveyTable);
  }

  Future<List<Map<String, dynamic>>> queryAllRowsQuestion() async {
    Database db = await instance.database;

    return await db.query(questionTable);
  }

  Future<List<Map<String, dynamic>>> queryRowsQuestion(int id) async {
    Database db = await instance.database;
    return await db.rawQuery('SELECT * FROM question WHERE sid=?', [id]);
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $surveyTable'));
  }

  //Query count of Question Table
  Future<int> queryRowCountQuestion() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM question'));
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[surveyId];
    return await db
        .update(surveyTable, row, where: '$surveyId = ?', whereArgs: [id]);
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db
        .delete(surveyTable, where: '$surveyId = ?', whereArgs: [id]);
  }

  Future<int> deleteAllQuestions() async {
    Database db = await instance.database;
    return await db.delete('question');
  }

  Future<int> deleteAllSurvey() async {
    Database db = await instance.database;
    return await db.delete(surveyTable);
  }

  Future<void> dropTableIfExists() async {
    Database db = await instance.database;

    //here we execute a query to drop the table if exists which is called "tableName"
    //and could be given as method's input parameter too
    await db.execute("DROP TABLE IF EXISTS question");

    //and finally here we recreate our beloved "tableName" again which needs

    await db.execute('''
          CREATE TABLE question (
            qid INTEGER PRIMARY KEY,
            sid INTEGER NOT NULL,
            qtitle TEXT NOT NULL,
            dimension TEXT NOT NULL,
            qtype INTEGER NOT NULL,
            FOREIGN KEY (sid) REFERENCES survey (_id) ON DELETE NO ACTION ON UPDATE NO ACTION
          )
          ''');

    //some columns initialization
    // await db.execute("CREATE TABLE tableName (id INTEGER, name TEXT)");
  }
}
