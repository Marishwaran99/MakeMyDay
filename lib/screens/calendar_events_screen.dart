import 'dart:convert';
import 'dart:developer';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:make_my_day/models/calendar_event.dart';
import 'package:make_my_day/models/calendar_event_helper.dart';
import 'package:make_my_day/screens/add_event.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/uuid.dart';

class CalendarEventsScreen extends StatefulWidget {
  @override
  _CalendarEventsScreenState createState() => _CalendarEventsScreenState();
}

class _CalendarEventsScreenState extends State<CalendarEventsScreen> {
  CalendarController _calendarController;
  Map<DateTime, List<dynamic>> _events;
  List<dynamic> _selectedEvents;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  TextEditingController _eventController = TextEditingController();
  SharedPreferences _preferences;
  Map<String, dynamic> event;

  @override
  void initState() {
    super.initState();
    var initialisationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    var initialisationSettingsIos = IOSInitializationSettings();

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettings = InitializationSettings(
        initialisationSettingsAndroid, initialisationSettingsIos);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    _calendarController = CalendarController();
    _events = Map<DateTime, List<dynamic>>();
    _selectedEvents = List<dynamic>();

    initializeSharedPrefs();
  }

  initializeSharedPrefs() async {
    _preferences = await SharedPreferences.getInstance();

    setState(() {
      _events = Map<DateTime, List<dynamic>>.from(
          decodeMap(json.decode(_preferences.getString('events') ?? "{}")));

      var now = DateTime.now();
      _selectedEvents =
          _events[DateTime.utc(now.year, now.month, now.day, 12, 0, 0, 0)];
      print(_events.toString());
      print(_selectedEvents.toString());
    });
  }

  Map<String, dynamic> encodeMap(Map<DateTime, dynamic> map) {
    Map<String, dynamic> newMap = {};
    map.forEach((key, value) {
      newMap[key.toString()] = map[key];
    });
    return newMap;
  }

  Map<DateTime, dynamic> decodeMap(Map<String, dynamic> map) {
    Map<DateTime, dynamic> newMap = {};
    map.forEach((key, value) {
      newMap[DateTime.parse(key.toString())] = map[key];
    });
    return newMap;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        'Day  Schedule',
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.25),
      )),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            event = {
              "id": null,
              "title": "",
              "description": "",
              "location": "",
              "guests": "",
              "type": "Event",
            };

            bool chk = await Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext ctx) {
              print(_calendarController.selectedDay.toString());
              return AddEventScreen(event, _calendarController.selectedDay);
            }));
            if (chk) {
              initializeSharedPrefs();
            }
          },
          child: Icon(Icons.add)),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TableCalendar(
              initialCalendarFormat: CalendarFormat.month,
              events: _events,
              calendarStyle: CalendarStyle(
                  canEventMarkersOverflow: false,
                  markersColor: Colors.red[200],
                  todayColor: Colors.deepPurple,
                  selectedColor: Colors.grey.withOpacity(0.25),
                  todayStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      color: Colors.white)),
              headerStyle: HeaderStyle(
                centerHeaderTitle: true,
                formatButtonDecoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(40.0),
                ),
                formatButtonTextStyle: TextStyle(color: Colors.white),
                formatButtonShowsNext: false,
              ),
              startingDayOfWeek: StartingDayOfWeek.monday,
              onDaySelected: (date, events) {
                setState(() {
                  _selectedEvents = events;
                });
              },
              builders: CalendarBuilders(
                  selectedDayBuilder: (context, date, events) => Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(48.0)),
                      child: Text(
                        date.day.toString(),
                        style: TextStyle(color: Colors.white),
                      )),
                  todayDayBuilder: (context, date, events) {
                    return Container(
                        margin: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(48.0)),
                        child: Text(
                          date.day.toString(),
                          style: TextStyle(color: Colors.white),
                        ));
                  }),
              calendarController: _calendarController,
            ),
            SizedBox(
              height: 16,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'On this Day',
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontSize: 14,
                  wordSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 16.0,
            ),
            Expanded(
                child: _selectedEvents != null
                    ? _selectedEvents.length > 0
                        ? ListView.builder(
                            itemCount: _selectedEvents.length,
                            itemBuilder: (BuildContext context, int i) {
                              Map<String, dynamic> evt =
                                  _selectedEvents.elementAt(i);

                              IconData icon;
                              String evtType =
                                  evt["type"].toString().toLowerCase();
                              print(evt);
                              if (evtType == "event")
                                icon = Icons.check_box;
                              else if (evtType == "birthday")
                                icon = Icons.cake;
                              else
                                icon = Icons.bookmark;

                              return InkWell(
                                onTap: () async {
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (BuildContext ctx) {
                                    return AddEventScreen(
                                        evt, _calendarController.selectedDay);
                                  }));
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  padding: EdgeInsets.only(
                                      left: 8, top: 16, right: 8),
                                  decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8.0)),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(
                                            icon,
                                            color: Colors.deepPurple,
                                            size: 16,
                                          ),
                                          SizedBox(width: 8.0),
                                          Text(evt["title"],
                                              style: TextStyle(fontSize: 16)),
                                        ],
                                      ),
                                      SizedBox(height: 16.0),
                                      evt["location"] != ''
                                          ? Column(
                                              children: <Widget>[
                                                Row(
                                                  children: <Widget>[
                                                    Icon(Icons.location_on,
                                                        size: 14,
                                                        color:
                                                            Colors.deepPurple),
                                                    SizedBox(width: 8.0),
                                                    Text(
                                                      evt["location"],
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 8.0),
                                              ],
                                            )
                                          : Container(),
                                      evt["guests"] != ''
                                          ? Column(
                                              children: <Widget>[
                                                Row(
                                                  children: <Widget>[
                                                    Icon(
                                                      Icons.group,
                                                      size: 14,
                                                      color: Colors.deepPurple,
                                                    ),
                                                    SizedBox(width: 8.0),
                                                    Text(evt["guests"]),
                                                  ],
                                                ),
                                                SizedBox(height: 8.0),
                                              ],
                                            )
                                          : Container(),
                                      Row(
                                        children: <Widget>[
                                          IconButton(
                                              color: Colors.red[300],
                                              icon: Icon(
                                                  CupertinoIcons.delete_simple),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return CupertinoAlertDialog(
                                                      title: Text(
                                                        'Delete Event',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Montserrat'),
                                                      ),
                                                      content: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 8.0),
                                                        child: Text(
                                                          'Are you sure to delete this event ?',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Montserrat',
                                                              letterSpacing:
                                                                  0.5),
                                                        ),
                                                      ),
                                                      actions: <Widget>[
                                                        FlatButton(
                                                          child: Text('Keep',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white)),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                        ),
                                                        FlatButton(
                                                          child: Text(
                                                            'Delete',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .redAccent),
                                                          ),
                                                          onPressed: () {
                                                            setState(() {
                                                              var e =
                                                                  _selectedEvents
                                                                      .removeAt(
                                                                          i);

                                                              _events[_calendarController
                                                                      .selectedDay] =
                                                                  _selectedEvents;
                                                              print(e);
                                                              _cancelNotification(
                                                                  e["id"]);
                                                              _preferences.setString(
                                                                  'events',
                                                                  json.encode(
                                                                      encodeMap(
                                                                          _events)));
                                                            });
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              }),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            })
                        : Container(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('No Events'))
                    : Container(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('No Events')))
          ],
        ),
      ),
    );
  }

  Future _cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future _setNotification(
      Map<String, dynamic> event, DateTime selectedTime) async {
    var androidSpecificChanges = AndroidNotificationDetails(
      event['id'].toString(),
      "channel1",
      "this is test channel",
    );
    var iosSpecificChanges = IOSNotificationDetails();

    var platformChannelSpecifics =
        NotificationDetails(androidSpecificChanges, iosSpecificChanges);
    await flutterLocalNotificationsPlugin.schedule(event['id'], 'Event',
        event['title'], selectedTime, platformChannelSpecifics);
  }
}
