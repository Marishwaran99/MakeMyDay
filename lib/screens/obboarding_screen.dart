import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:make_my_day/screens/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnBoarding extends StatefulWidget {
  @override
  _OnBoardingState createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  PageController _controller;
  int _pageIdx = 0;
  SharedPreferences _preferences;
  List<Widget> _pages = [
    OnBoardingContent(
        title: 'Add your Tasks/Notes',
        icon: Icons.edit,
        description:
            'Store your tasks to remind you. Save and share your important notes'),
    OnBoardingContent(
        title: 'Register you Events',
        icon: Icons.event_note,
        description: 'Store your events to remind you at that day')
  ];
  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: _pageIdx);
    initPreferences();
  }

  initPreferences() async {
    _preferences = await SharedPreferences.getInstance();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.deepPurple));
    return Scaffold(
        backgroundColor: Colors.deepPurple,
        body: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: PageView(
                children: <Widget>[
                  OnBoardingContent(
                      title: 'Add your Tasks/Notes',
                      icon: Icons.edit,
                      description:
                          'Store your tasks to remind you. Save and share your important notes'),
                  OnBoardingContent(
                      title: 'Register you Events',
                      icon: Icons.event_note,
                      description:
                          'Store your events to remind you at that day'),
                  OnBoardingContent(
                      title: 'Calculate your Budget',
                      icon: Icons.attach_money,
                      description:
                          'Save your incomes and expenses to calculate budgets. Also get the insights of your budget'),
                ],
                controller: _controller,
                onPageChanged: (i) {
                  setState(() {
                    _pageIdx = i;
                  });
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FlatButton(
                      onPressed: () {
                        _preferences.setBool("onboard", false);
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (BuildContext ctx) {
                          return Home();
                        }));
                      },
                      child:
                          Text('Skip', style: TextStyle(color: Colors.white))),
                  Row(
                    children: <Widget>[
                      Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                              color:
                                  _pageIdx == 0 ? Colors.white : Colors.white12,
                              borderRadius: BorderRadius.circular(8.0))),
                      SizedBox(width: 8.0),
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                            color:
                                _pageIdx == 1 ? Colors.white : Colors.white12,
                            borderRadius: BorderRadius.circular(8.0)),
                      ),
                      SizedBox(width: 8.0),
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                            color:
                                _pageIdx == 2 ? Colors.white : Colors.white12,
                            borderRadius: BorderRadius.circular(8.0)),
                      )
                    ],
                  ),
                  IconButton(
                      onPressed: () {
                        log(_pageIdx.toString());
                        if (_pageIdx < 2)
                          _controller.animateToPage(_pageIdx + 1,
                              duration: Duration(milliseconds: 200),
                              curve: Curves.easeIn);
                        else {
                          _preferences.setBool("onboard", false);

                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (BuildContext ctx) {
                            return Home();
                          }));
                        }
                      },
                      icon: Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                        size: 36,
                      )),
                ],
              ),
            )
          ],
        ));
  }
}

class OnBoardingContent extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;

  OnBoardingContent({this.title, this.icon, this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.deepPurple,
      padding: EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          _onBoardImage(icon, context),
          SizedBox(height: 24),
          Text(title,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
          SizedBox(height: 16),
          Container(
            width: MediaQuery.of(context).size.width * 0.75,
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(height: 1.5, fontSize: 14, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }

  Widget _onBoardImage(IconData icon, BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width * 0.5,
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(),
        child: Center(
            child: Icon(
          icon,
          color: Colors.white,
          size: MediaQuery.of(context).size.width * 0.5,
        )));
  }
}
