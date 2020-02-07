import 'dart:core';
import 'dart:io';

import 'package:make_my_day/models/time_table.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class TimeTableHelper {
  static TimeTableHelper _databaseHelper;
  static Database _database;

  String timeTable = 'timetable';
  String colId = 'id';
  String colDescription = 'description';
  String colDay = 'day';
  String colStartTime = 'startTime';
  String colEndTime = 'endTime';

  TimeTableHelper._createInstance();

  factory TimeTableHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = TimeTableHelper._createInstance();
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
    String path = directory.path + 'timeatables.db';
    var scheduleDb = await openDatabase(path, version: 1, onCreate: _createDb);
    return scheduleDb;
  }

  void _createDb(Database db, int newVersion) async {
    var sql =
        'CREATE TABLE $timeTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colDay TEXT, $colDescription TEXT,$colStartTime TEXT, $colEndTime TEXT)';
    await db.execute(sql);
  }

  Future<List<Map<String, dynamic>>> getTimeTableMapList() async {
    Database db = await this.database;
    var result = await db.rawQuery('SELECT * FROM $timeTable');
    return result;
  }

  Future<int> insertTimeTable(TimeTable tt) async {
    Database db = await this.database;

    var res = db.insert(timeTable, tt.toMap());
    return res;
  }

  Future<int> deleteTimeTable(int id) async {
    Database db = await this.database;

    int res = await db.rawDelete('DELETE FROM $timeTable where $colId=$id');
    return res;
  }

  Future<int> updateTimeTable(TimeTable tt) async {
    Database db = await this.database;

    var res = db
        .update(timeTable, tt.toMap(), where: '$colId = ?', whereArgs: [tt.id]);
    return res;
  }

  Future<List<TimeTable>> getTimeTableList() async {
    var ttMap = await getTimeTableMapList();
    var count = ttMap.length;

    List<TimeTable> tts = List<TimeTable>();

    for (int i = 0; i < count; i++) {
      tts.add(TimeTable.fromMapObject(ttMap[i]));
    }
    return tts;
  }
}
