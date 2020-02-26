import 'dart:io';

import 'package:make_my_day/models/calendar_event.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class CalendarEventHelper {
  static CalendarEventHelper _helper;
  static Database _database;

  String eventTable = 'calendareventtable';
  String colId = 'id';
  String colTitle = 'title';
  String colDate = 'date';

  CalendarEventHelper._createInstance();

  factory CalendarEventHelper() {
    if (_helper == null) {
      _helper = CalendarEventHelper._createInstance();
    }
    return _helper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initialiseDatabase();
    }
    return _database;
  }

  Future<Database> initialiseDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'calevents.db';
    var eventsDb = await openDatabase(path, version: 1, onCreate: _createDb);
    return eventsDb;
  }

  void _createDb(Database db, int version) async {
    var sql =
        'CREATE TABLE $eventTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDate TEXT)';
    await db.execute(sql);
  }

  Future<List<Map<String, dynamic>>> getEventsMapList() async {
    Database db = await this.database;
    var result = await db.rawQuery('SELECT * FROM $eventTable');
    return result;
  }

  Future<int> insertEvent(CalendarEvent calendarEvent) async {
    Database db = await this.database;

    var res = db.insert(eventTable, calendarEvent.toMap());
    return res;
  }

  Future<int> deleteEvent(int id) async {
    Database db = await this.database;

    int res = await db.rawDelete('DELETE FROM $eventTable where $colId=$id');
    return res;
  }

  Future<int> updateEvent(CalendarEvent calendarEvent) async {
    Database db = await this.database;

    var res = db.update(eventTable, calendarEvent.toMap(),
        where: '$colId = ?', whereArgs: [calendarEvent.id]);
    return res;
  }

  Future<List<CalendarEvent>> getEventsList() async {
    var eventMap = await getEventsMapList();
    var count = eventMap.length;

    List<CalendarEvent> ce = List<CalendarEvent>();

    for (int i = 0; i < count; i++) {
      ce.add(CalendarEvent.fromMapObject(eventMap[i]));
    }
    return ce;
  }
}
