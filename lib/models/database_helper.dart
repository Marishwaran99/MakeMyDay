import 'dart:core';
import 'dart:io';

import 'package:make_my_day/models/todo.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper;
  static Database _database;

  String todoTable = 'todotable';
  String colId = 'id';
  String colTitle = 'title';
  String colCheck = 'isDone';
  String colIsDailyTask = 'isDailyTask';
  String colDate = 'createdAt';

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'todos.db';
    var todosDb = await openDatabase(path, version: 13, onCreate: _createDb);
    return todosDb;
  }

  void _createDb(Database db, int newVersion) async {
    var sql =
        'CREATE TABLE $todoTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colCheck TEXT,$colIsDailyTask TEXT, $colDate TEXT)';
    await db.execute(sql);
  }

  Future<List<Map<String, dynamic>>> getTodoMapList() async {
    Database db = await this.database;
    var result = await db.rawQuery('SELECT * FROM $todoTable');
    return result;
  }

  Future<int> insertTodo(Todo todo) async {
    Database db = await this.database;

    var res = db.insert(todoTable, todo.toMap());
    return res;
  }

  Future<int> deleteTodo(int id) async {
    Database db = await this.database;

    int res = await db.rawDelete('DELETE FROM $todoTable where $colId=$id');
    return res;
  }

  Future<int> updateTodo(Todo todo) async {
    Database db = await this.database;

    var res = db.update(todoTable, todo.toMap(),
        where: '$colId = ?', whereArgs: [todo.id]);
    return res;
  }

  Future<List<Todo>> getTodoList() async {
    var todoMap = await getTodoMapList();
    var count = todoMap.length;

    List<Todo> todos = List<Todo>();

    for (int i = 0; i < count; i++) {
      todos.add(Todo.fromMapObject(todoMap[i]));
    }
    return todos;
  }
}
