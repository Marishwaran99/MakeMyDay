import 'package:flutter/material.dart';
import 'package:make_my_day/screens/calendar_events_screen.dart';
import 'package:make_my_day/screens/weekly_plan_screen.dart';

class ScheduleScreen extends StatefulWidget {
  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  String title = 'Plan';
  List<String> _scheduleTabs = ['Day Schdule', 'Week Schedule'];
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _scheduleTabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
            controller: _tabController,
            tabs: _scheduleTabs.map((t) => Tab(child: Text(t))).toList()),
      ),
      body: TabBarView(
          controller: _tabController,
          children: <Widget>[CalendarEventsScreen(), WeeklyPlanScreen()]),
    );
  }
}
