import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:make_my_day/screens/add_budget_plan_screen.dart';
import 'package:make_my_day/screens/all_transaction_screen.dart';
import 'package:make_my_day/screens/budget_stats_screen.dart';

class BudgetPlanScreen extends StatefulWidget {
  @override
  _BudgetPlanScreenState createState() => _BudgetPlanScreenState();
}

class _BudgetPlanScreenState extends State<BudgetPlanScreen>
    with SingleTickerProviderStateMixin {
  List<String> tabItems = [
    'Transactions',
    'Statistics',
  ];
  int _currentIndex;
  TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabItems.length, vsync: this);
    _currentIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daily  Expenses',
          style: TextStyle(
              fontSize: 16, letterSpacing: 1.5, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: tabItems
              .map((t) => Tab(
                    child: Text(t),
                  ))
              .toList(),
        ),
      ),
      floatingActionButton: _currentIndex == 0
          ? SpeedDial(
              animatedIcon: AnimatedIcons.menu_close,
              animatedIconTheme: IconThemeData(size: 22.0),
              // this is ignored if animatedIcon is non null
              // child: Icon(Icons.add),
              // If true user is forced to close dial manually
              // by tapping main button and overlay is not rendered.
              closeManually: false,
              curve: Curves.bounceIn,
              overlayColor: Colors.black,
              overlayOpacity: 0.5,
              onOpen: () => print('OPENING DIAL'),
              onClose: () => print('DIAL CLOSED'),
              tooltip: 'Speed Dial',
              heroTag: 'speed-dial-hero-tag',
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 8.0,
              shape: CircleBorder(),
              children: [
                SpeedDialChild(
                    child: Icon(Icons.add),
                    backgroundColor: Colors.deepPurple,
                    onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (BuildContext context) {
                          return AddBudgetPlanScreen('Income', null);
                        }))),
                SpeedDialChild(
                    child: Center(
                      child: Text(
                        '-',
                        style: TextStyle(
                            fontSize: 36, fontWeight: FontWeight.bold),
                      ),
                    ),
                    backgroundColor: Colors.red,
                    onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (BuildContext context) {
                          _tabController.animateTo(0);

                          return AddBudgetPlanScreen('Expense', null);
                        }))),
              ],
            )
          : FloatingActionButton(onPressed: () {}),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[AllTransactionScreen(), BudgetStatsScreen()],
      ),
    );
  }
}
