import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarEventsScreen extends StatefulWidget {
  @override
  _CalendarEventsScreenState createState() => _CalendarEventsScreenState();
}

class _CalendarEventsScreenState extends State<CalendarEventsScreen> {
  CalendarController _calendarController;
  Map<DateTime, List<dynamic>> _events;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  List<dynamic> _selectedEvents;
  TextEditingController _eventController;
  SharedPreferences _sharedPreferences;
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
    _eventController = TextEditingController();
    initializeSharedPrefs();
  }

  initializeSharedPrefs() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    _events = Map<DateTime, List<dynamic>>.from(
        decodeMap(json.decode(_sharedPreferences.getString("events") ?? "{}")));

    _selectedEvents = _events[_calendarController.selectedDay];
    setState(() {});
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
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              _showEventAddDialog(context);
            },
            child: Icon(Icons.add)),
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TableCalendar(
                  initialCalendarFormat: CalendarFormat.month,
                  events: _events,
                  calendarStyle: CalendarStyle(
                      canEventMarkersOverflow: true,
                      todayColor: Colors.deepPurple,
                      selectedColor:
                          Theme.of(context).primaryColor.withOpacity(0.25),
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
                    'Events',
                    style: TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5),
                  ),
                ),
                SizedBox(
                  height: 16.0,
                ),
                LimitedBox(
                    maxHeight: 500,
                    child: _selectedEvents != null
                        ? ListView.builder(
                            itemCount: _selectedEvents.length,
                            itemBuilder: (BuildContext context, int i) =>
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8.0)),
                                  child: ListTile(
                                      trailing: InkWell(
                                          child: Icon(
                                            CupertinoIcons.delete_simple,
                                            color: Colors.red[300],
                                          ),
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return CupertinoAlertDialog(
                                                  title: Text(
                                                    'Delete Event',
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Montserrat'),
                                                  ),
                                                  content: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 8.0),
                                                    child: Text(
                                                      'Are you sure to delete this event ?',
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Montserrat',
                                                          letterSpacing: 0.5),
                                                    ),
                                                  ),
                                                  actions: <Widget>[
                                                    FlatButton(
                                                      child: Text('Keep',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white)),
                                                      onPressed: () {
                                                        Navigator.of(context)
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
                                                          _selectedEvents
                                                              .removeAt(i);
                                                          _events[_calendarController
                                                                  .selectedDay] =
                                                              _selectedEvents;
                                                        });
                                                        Navigator.pop(context);
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          }),
                                      title:
                                          Text(_selectedEvents.elementAt(i))),
                                ))
                        : Text('No Events'))
              ],
            ),
          ),
        ));
  }

  _showEventAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Add Event',
            style: TextStyle(fontFamily: 'Montserrat'),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextField(
              controller: _eventController,
              style: TextStyle(fontFamily: 'Montserrat', letterSpacing: 0.5),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                'Save',
                style: TextStyle(color: Colors.deepPurple),
              ),
              onPressed: () {
                if (_eventController.text.isEmpty) {
                  return;
                }
                setState(() {
                  if (_events[_calendarController.selectedDay] != null) {
                    _events[_calendarController.selectedDay]
                        .add(_eventController.text);
                  } else {
                    _events[_calendarController.selectedDay] = [
                      _eventController.text
                    ];
                  }
                  _sharedPreferences.setString(
                      "events", json.encode(encodeMap(_events)));

                  _eventController.clear();
                  Navigator.pop(context);
                });
              },
            ),
          ],
        );
      },
    );
  }
}
