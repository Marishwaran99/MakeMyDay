import 'package:flutter/material.dart';

class NewsSettings extends StatefulWidget {
  @override
  _NewsSettingsState createState() => _NewsSettingsState();
}

class _NewsSettingsState extends State<NewsSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: <Widget>[],
        ),
      ),
    );
  }
}
