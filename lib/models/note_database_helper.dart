import 'dart:core';
import 'dart:io';

import 'package:make_my_day/models/note.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class NotesDatabaseHelper {
  static NotesDatabaseHelper _databaseHelper;
  static Database _database;

  String noteTable = 'notetable';
  String colId = 'id';
  String colDescription = 'description';
  String colDate = 'createdAt';
  String colColor = 'noteColor';

  NotesDatabaseHelper._createInstance();

  factory NotesDatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = NotesDatabaseHelper._createInstance();
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
    String path = directory.path + 'notes.db';
    var notesDb = await openDatabase(path, version: 10, onCreate: _createDb);
    return notesDb;
  }

  void _createDb(Database db, int newVersion) async {
    var sql =
        'CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT,$colColor TEXT, $colDescription TEXT, $colDate TEXT)';
    await db.execute(sql);
  }

  Future<List<Map<String, dynamic>>> getnoteMapList() async {
    Database db = await this.database;
    var result = await db.rawQuery('SELECT * FROM $noteTable');
    return result;
  }

  Future<int> insertnote(Note note) async {
    Database db = await this.database;

    var res = db.insert(noteTable, note.toMap());
    return res;
  }

  Future<int> deletenote(int id) async {
    Database db = await this.database;

    int res = await db.rawDelete('DELETE FROM $noteTable where $colId=$id');
    return res;
  }

  Future<int> updatenote(Note note) async {
    Database db = await this.database;

    var res = db.update(noteTable, note.toMap(),
        where: '$colId = ?', whereArgs: [note.id]);
    return res;
  }

  Future<List<Note>> getnoteList() async {
    var noteMap = await getnoteMapList();
    var count = noteMap.length;

    List<Note> notes = List<Note>();

    for (int i = 0; i < count; i++) {
      notes.add(Note.fromMapObject(noteMap[i]));
    }
    return notes;
  }
}
