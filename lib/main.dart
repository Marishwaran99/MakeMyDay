import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:make_my_day/components/bottom_bar.dart';
import 'package:make_my_day/screens/budget_plan_screen.dart';
import 'package:make_my_day/screens/calendar_events_screen.dart';
import 'package:make_my_day/screens/home.dart';
import 'package:make_my_day/screens/obboarding_screen.dart';
import 'package:make_my_day/screens/schedule_screen.dart';
import 'package:make_my_day/screens/todo_screen.dart';
import 'package:make_my_day/screens/weekly_plan_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/notes_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Make My Day',
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

class HomeScreenState extends State<HomeScreen> {
  SharedPreferences _preferences;
  bool onboard = true;
  @override
  void initState() {
    super.initState();
    initPreferences();
  }

  initPreferences() async {
    _preferences = await SharedPreferences.getInstance();
    onboard = _preferences.getBool("onboard") == null ? true : false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: onboard ? OnBoarding() : Home());
  }
}
