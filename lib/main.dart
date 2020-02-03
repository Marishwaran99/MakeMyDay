import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:make_my_day/screens/news_page.dart';
import 'package:make_my_day/screens/todo_screen.dart';

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
  int _index = 0;

  final List<Widget> _screens = [TodoScreen(), NotesScreen(), NewsPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _index,
          items: [
            BottomNavigationBarItem(
                title: Text('Tasks'),
                icon: Icon(CupertinoIcons.bookmark_solid)),
            BottomNavigationBarItem(
                title: Text('Notes'), icon: Icon(CupertinoIcons.pencil)),
            BottomNavigationBarItem(
                title: Text('News'), icon: Icon(CupertinoIcons.news_solid))
          ],
          onTap: (i) {
            setState(() {
              _index = i;
            });
          }),
    );
  }
}
