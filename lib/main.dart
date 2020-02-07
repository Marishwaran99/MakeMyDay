import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:make_my_day/components/bottom_bar.dart';
import 'package:make_my_day/screens/budget_plan_screen.dart';
import 'package:make_my_day/screens/calendar_events_screen.dart';
import 'package:make_my_day/screens/news_page.dart';
import 'package:make_my_day/screens/schedule_screen.dart';
import 'package:make_my_day/screens/todo_screen.dart';
import 'package:make_my_day/screens/weekly_plan_screen.dart';

import 'screens/notes_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          brightness: Brightness.light,
          fontFamily: 'Montserrat',
          primaryColor: Colors.deepPurple,
          accentColor: Colors.deepPurple),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _index = 0;
  PageController _pageController;
  List<BarItem> _bottomBarItem = [
    BarItem(title: 'Tasks', iconData: Icons.playlist_add_check),
    BarItem(title: 'Notes', iconData: Icons.edit),
    BarItem(title: 'News', iconData: Icons.live_tv),
    BarItem(title: 'Plan', iconData: Icons.event_note),
    BarItem(title: 'Budget', iconData: Icons.attach_money),
  ];
  final List<Widget> _screens = [
    TodoScreen(),
    NotesScreen(),
    NewsPage(),
    ScheduleScreen(),
    BudgetPlanScreen()
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: PageView.builder(
            scrollDirection: Axis.horizontal,
            physics: NeverScrollableScrollPhysics(),
            controller: _pageController,
            // onPageChanged: (i) {
            //   setState(() {
            //     _index = i;
            //   });
            // },
            itemCount: _screens.length,
            itemBuilder: (BuildContext context, int i) {
              return _screens[i];
            }),
        bottomNavigationBar: AnimatedBottomBar(
            barItems: _bottomBarItem,
            duration: Duration(milliseconds: 200),
            onBarTap: (i) {
              _pageController.animateToPage(i,
                  duration: Duration(milliseconds: 250),
                  curve: Curves.easeInOut);
            }));
  }
}
