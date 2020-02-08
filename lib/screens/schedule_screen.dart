import 'package:flutter/material.dart';
import 'package:make_my_day/screens/calendar_events_screen.dart';
import 'package:make_my_day/screens/weekly_plan_screen.dart';

class ScheduleScreen extends StatefulWidget {
  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<String> _scheduleTabs = ['Day Schdule', 'Week Schedule'];
  List<Widget> _screens = [CalendarEventsScreen(), WeeklyPlanScreen()];
  int _index = 0;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: _scheduleTabs.map((t) {
                int i = _scheduleTabs.indexOf(t);
                bool isSelected = _index == i;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _index = _index == 0 ? 1 : 0;
                    });
                  },
                  child: Container(
                      height: 36,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          color: isSelected ? Colors.white : Colors.deepPurple),
                      child: Center(
                        child: Text(
                          t,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color:
                                isSelected ? Colors.deepPurple : Colors.white,
                          ),
                        ),
                      )),
                );
              }).toList())),
      body: _screens[_index],
    );
  }
}
