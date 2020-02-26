import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:make_my_day/components/bottom_bar.dart';
import 'package:make_my_day/screens/calendar_events_screen.dart';
import 'package:make_my_day/screens/news_page.dart';

import 'budget_plan_screen.dart';
import 'notes_screen.dart';
import 'todo_screen.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _index = 0;
  List<BarItem> _bottomBarItem = [
    BarItem(title: 'Tasks', iconData: Icons.playlist_add_check),
    BarItem(title: 'Notes', iconData: Icons.edit),
    BarItem(title: 'Plan', iconData: Icons.event_note),
    BarItem(title: 'Budget', iconData: Icons.attach_money),
  ];
  final List<Widget> _screens = [
    TodoScreen(),
    NotesScreen(),
    CalendarEventsScreen(),
    BudgetPlanScreen()
  ];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _screens[_index],
        bottomNavigationBar: AnimatedBottomBar(
            barItems: _bottomBarItem,
            duration: Duration(milliseconds: 200),
            onBarTap: (i) {
              setState(() {
                _index = i;
              });
            }));
  }
}
