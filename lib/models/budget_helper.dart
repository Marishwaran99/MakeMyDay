import 'dart:core';
import 'dart:io';

import 'package:make_my_day/models/budget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class BudgetHelper {
  static BudgetHelper _databaseHelper;
  static Database _database;

  String budgetTable = 'budgettable';
  String colId = 'id';
  String colAmount = 'amount';
  String colDescription = 'description';
  String colCategory = 'category';
  String colPaymentMode = 'paymentMode';
  String colTime = 'time';
  String colType = 'type';

  BudgetHelper._createInstance();

  factory BudgetHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = BudgetHelper._createInstance();
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
    String path = directory.path + 'budget.db';
    var budgetDb = await openDatabase(path, version: 4, onCreate: _createDb);
    return budgetDb;
  }

  void _createDb(Database db, int newVersion) async {
    var sql =
        'CREATE TABLE $budgetTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colAmount TEXT, $colDescription TEXT,$colCategory TEXT, $colPaymentMode, $colTime TEXT, $colType TEXT)';
    await db.execute(sql);
  }

  Future<List<Map<String, dynamic>>> getBudgetMapList() async {
    Database db = await this.database;
    var result = await db.rawQuery('SELECT * FROM $budgetTable');
    return result;
  }

  Future<int> insertBudget(Budget budget) async {
    Database db = await this.database;

    var res = db.insert(budgetTable, budget.toMap());
    return res;
  }

  Future<int> deleteBudget(int id) async {
    Database db = await this.database;

    int res = await db.rawDelete('DELETE FROM $budgetTable where $colId=$id');
    return res;
  }

  Future<int> updateBudget(Budget budget) async {
    Database db = await this.database;

    var res = db.update(budgetTable, budget.toMap(),
        where: '$colId = ?', whereArgs: [budget.id]);
    return res;
  }

  Future<List<Budget>> getBudgetList() async {
    var budgetMap = await getBudgetMapList();
    var count = budgetMap.length;

    List<Budget> budgets = List<Budget>();

    for (int i = 0; i < count; i++) {
      budgets.add(Budget.fromMapObject(budgetMap[i]));
    }
    return budgets;
  }
}
