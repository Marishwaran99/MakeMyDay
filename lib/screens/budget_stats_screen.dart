import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:make_my_day/models/budget.dart';
import 'package:make_my_day/models/budget_helper.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:sqflite/sqflite.dart';

class BudgetStatsScreen extends StatefulWidget {
  @override
  _BudgetStatsScreenState createState() => _BudgetStatsScreenState();
}

class _BudgetStatsScreenState extends State<BudgetStatsScreen> {
  List<Budget> budgets;
  BudgetHelper _helper = BudgetHelper();

  int totalIncome;
  int totalExpense;
  int remainingBalance;
  Map<String, double> dataMap = Map<String, double>();
  List<Color> colorList = [Colors.red[200], Colors.deepPurple];
  @override
  void initState() {
    super.initState();
    totalIncome = 0;
    totalExpense = 0;
    remainingBalance = 0;
  }

  @override
  Widget build(BuildContext context) {
    if (budgets == null) {
      budgets = List<Budget>();
      updateBudgetList();
    }
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: dataMap != null && dataMap.isNotEmpty
            ? Column(
                children: <Widget>[
                  PieChart(
                    dataMap: dataMap,
                    legendPosition: LegendPosition.right,
                    chartValueStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.25),
                    chartValueBackgroundColor: Colors.transparent,
                    chartRadius: MediaQuery.of(context).size.width * 0.75,
                    colorList: colorList,
                    showChartValues: true,
                    showChartValueLabel: true,
                    showChartValuesInPercentage: true,
                    showLegends: true,
                    chartType: ChartType.disc,
                  ),
                  SizedBox(height: 24),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Text('Income: $totalIncome'),
                        Text('Expense: $totalExpense'),
                        Text('Balance: $remainingBalance'),
                      ])
                ],
              )
            : Container());
  }

  calculateBudget() {
    log('hello');
    for (int i = 0; i < budgets.length; i++) {
      var a = int.parse(budgets.elementAt(i).amount);
      if (budgets.elementAt(i).type == 'Income') {
        totalIncome += a;
      } else {
        totalExpense += a;
      }
    }
    setState(() {
      remainingBalance = totalIncome - totalExpense;
      dataMap.putIfAbsent("Expense", () => totalExpense.toDouble());
      dataMap.putIfAbsent("Balance", () => remainingBalance.toDouble());
    });
  }

  updateBudgetList() {
    Future<Database> dbFuture = _helper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Budget>> budgetFuture = _helper.getBudgetList();
      budgetFuture.then((budgetDb) {
        setState(() {
          this.budgets = budgetDb;

          calculateBudget();
        });
      });
    });
  }
}
