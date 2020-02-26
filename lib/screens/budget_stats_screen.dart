import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:make_my_day/models/budget.dart';
import 'package:make_my_day/models/budget_helper.dart';
import 'package:make_my_day/screens/add_budget_plan_screen.dart';
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
  Map<String, double> expenseMap = Map<String, double>();

  Map<String, double> expenseCauseMap = Map<String, double>();
  List<Color> colorList = [Colors.red[200], Colors.deepPurple];

  List<String> expenseCause = List<String>();

  List<double> expenseCauseVal = List<double>();

  @override
  void initState() {
    super.initState();
    totalIncome = 0;
    totalExpense = 0;
    remainingBalance = 0;
    if (budgets == null) {
      budgets = List<Budget>();
      updateBudgetList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            children: <Widget>[
              dataMap != null && dataMap.isNotEmpty
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
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              _statsCard(Colors.green, 'Income', totalIncome),
                              _statsCard(
                                  Colors.red[300], 'Expense', totalExpense),
                              _statsCard(Colors.deepPurple, 'Balance',
                                  remainingBalance),
                            ])
                      ],
                    )
                  : Container(),
              SizedBox(height: 24),
              expenseMap != null && expenseMap.isNotEmpty
                  ? Column(
                      children: <Widget>[
                        PieChart(
                          dataMap: expenseMap,
                          legendPosition: LegendPosition.right,
                          chartValueStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.25),
                          chartValueBackgroundColor: Colors.transparent,
                          chartRadius: MediaQuery.of(context).size.width * 0.75,
                          showChartValues: true,
                          showChartValueLabel: true,
                          showChartValuesInPercentage: true,
                          showLegends: true,
                          chartType: ChartType.disc,
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        Column(children: getExpenseCard())
                      ],
                    )
                  : Container(),
            ],
          )),
    );
  }

  Widget _statsCard(Color indicatorColor, String title, int val) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
          color: Colors.grey[200], borderRadius: BorderRadius.circular(8.0)),
      child: Row(
        children: <Widget>[
          Container(
            width: 12,
            height: 12,
            color: indicatorColor,
          ),
          SizedBox(width: 8),
          Text(
            '$title: $val',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
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

      for (int i = 0; i < budgets.length; i++) {
        int a = int.parse(budgets.elementAt(i).amount);
        if (budgets.elementAt(i).type == 'Expense') {
          expenseMap.update(
              budgets.elementAt(i).category, (val) => val + a.toDouble(),
              ifAbsent: () => a.toDouble());
        }
      }

      expenseCauseVal = expenseMap.values.toList();
      log(expenseCauseVal.toString());
    });
  }

  List<Widget> getExpenseCard() {
    List<Widget> l = List<Widget>();
    expenseMap.forEach((key, val) {
      l.add(_statsCard(Colors.red[200], key, val.toInt()));
    });
    return l;
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
