import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddEventScreen extends StatefulWidget {
  final Map<String, dynamic> event;
  final DateTime selectedDay;
  AddEventScreen(this.event, this.selectedDay);
  @override
  _AddEventScreenState createState() =>
      _AddEventScreenState(this.event, this.selectedDay);
}

class _AddEventScreenState extends State<AddEventScreen> {
  List<Map<String, dynamic>> _menuIcons = [
    {"icon": Icons.check_box, "title": "Event"},
    {"icon": Icons.cake, "title": "Birthday"},
    {"icon": Icons.bookmark, "title": "Anniversary"}
  ];
  int idx = 0;
  List<Widget> _sections;
  Map<String, dynamic> event;
  Map<DateTime, List<dynamic>> _events;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  TextEditingController _eventTitleController = TextEditingController();
  TextEditingController _eventWhenController = TextEditingController();
  TextEditingController _eventLocationController = TextEditingController();
  TextEditingController _eventGuestController = TextEditingController();
  SharedPreferences _preferences;
  DateTime selectedDay;
  Map<DateTime, dynamic> newEvent;
  _AddEventScreenState(this.event, this.selectedDay);
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
    _sections = [_eventSection(), _birthdaySection(), _anniversarySection()];
    _events = Map<DateTime, List<dynamic>>();
    newEvent = {};
    _eventTitleController.text = event["title"];
    _eventWhenController.text = formatDate(selectedDay);
    if (event["type"] == "Event")
      idx = 0;
    else if (event["type"] == "Birthday")
      idx = 1;
    else if (event["type"] == "Anniversary") idx = 2;
    initializeSharedPrefs();
  }

  initializeSharedPrefs() async {
    _preferences = await SharedPreferences.getInstance();

    setState(() {
      _events = Map<DateTime, List<dynamic>>.from(
          decodeMap(json.decode(_preferences.getString('events') ?? "{}")));
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
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.check,
              ),
              onPressed: () {
                _saveEvent();
              },
            )
          ],
          title: Text(
            'Add Event',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          leading: IconButton(
              icon: Icon(Icons.chevron_left),
              onPressed: () {
                Navigator.pop(context, false);
              }),
        ),
        body: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _menuIcons.map((m) {
                        int i = _menuIcons.indexOf(m);
                        return _menuIcon(m, i);
                      }).toList()),
                  SizedBox(height: 16),
                  SingleChildScrollView(child: _sections[idx])
                ])));
  }

  Widget _menuIcon(Map<String, dynamic> data, int i) {
    return InkWell(
      onTap: () {
        setState(() {
          idx = i;
          event["type"] = _menuIcons.elementAt(idx)["title"];
        });
      },
      child: Column(
        children: <Widget>[
          Icon(
            data["icon"],
            color: idx == i ? Colors.deepPurple : Colors.grey,
          ),
          SizedBox(
            height: 4.0,
          ),
          Text(
            data["title"],
            style: TextStyle(
                color: idx == i ? Colors.deepPurple : Colors.grey,
                fontSize: 12),
          )
        ],
      ),
    );
  }

  Widget _eventTitle() {
    return Container(
        child: Column(
      children: <Widget>[
        TextField(
          controller: _eventTitleController,
          onChanged: (val) {
            event["title"] = val;
          },
          decoration: InputDecoration(
              hasFloatingPlaceholder: true,
              labelText: 'Event Title',
              hintText: 'Eg: Your event'),
        ),
        SizedBox(
          height: 16,
        ),
      ],
    ));
  }

  Widget _eventWhen() {
    return Container(
        child: Column(
      children: <Widget>[
        TextField(
          controller: _eventWhenController,
          readOnly: true,
          onTap: () async {
            var d = await showDatePicker(
                context: context,
                firstDate: DateTime(2020, DateTime.now().month),
                initialDate: DateTime.now(),
                lastDate: DateTime(3000));
            if (d != null) {
              selectedDay = d;
              _eventWhenController.text = formatDate(d);
            }
          },
          decoration: InputDecoration(
              hasFloatingPlaceholder: true,
              labelText: 'Event Date',
              hintText: 'Eg: Jan, 1 2020'),
        ),
        SizedBox(
          height: 16,
        ),
      ],
    ));
  }

  Widget _eventSection() {
    return Column(
      children: <Widget>[
        _eventTitle(),
        _eventWhen(),
        TextField(
          controller: _eventLocationController,
          onChanged: (val) {
            event["location"] = val;
          },
          decoration: InputDecoration(
              hasFloatingPlaceholder: true,
              labelText: 'Location',
              hintText: 'Eg: Mumbai'),
        ),
        SizedBox(height: 16),
        TextField(
          controller: _eventGuestController,
          onChanged: (val) {
            event["guests"] = val;
          },
          decoration: InputDecoration(
              hasFloatingPlaceholder: true,
              labelText: 'Guests',
              hintText: 'Eg: Guest_Name 1, Guest_Name 2, etc..'),
        ),
        SizedBox(height: 16)
      ],
    );
  }

  Widget _birthdaySection() {
    return Column(
      children: <Widget>[
        _eventTitle(),
        _eventWhen(),
      ],
    );
  }

  Widget _anniversarySection() {
    return Column(
      children: <Widget>[
        _eventTitle(),
        _eventWhen(),
      ],
    );
  }

  Future _setNotification(
      Map<String, dynamic> event, DateTime selectedTime) async {
    var androidSpecificChanges = AndroidNotificationDetails(
      event['id'].toString(),
      "channel1",
      "this is test channel",
    );
    var iosSpecificChanges = IOSNotificationDetails();

    var notfiyAt =
        new DateTime(selectedTime.year, selectedTime.month, selectedTime.day);

    var platformChannelSpecifics =
        NotificationDetails(androidSpecificChanges, iosSpecificChanges);
    if (DateTime.now().isBefore(notfiyAt))
      await flutterLocalNotificationsPlugin
          .schedule(event['id'], event['type'], event['title'], notfiyAt,
              platformChannelSpecifics)
          .then((v) {
        print('notify at' + DateFormat.yMMMEd().add_jms().format(notfiyAt));
      });
  }

  formatDate(DateTime dt) {
    if (dt != null) return DateFormat.yMMMd().format(dt);
  }

  void _saveEvent() {
    var i = 0;
    if (event["title"].toString().length > 0 && selectedDay != null) {
      if (event["id"] != null) {
        _events[selectedDay].forEach((k) {
          if (event["id"] == k["id"]) {
            print("log");
            _events[selectedDay].removeAt(i);
            _events[selectedDay].insert(i, event);
          }
          i += 1;
        });
      } else {
        print("log");

        event["id"] = Random().nextInt(100000);
        if (_events[selectedDay] != null) {
          _events[selectedDay].add(event);
        } else {
          _events[selectedDay] = [event];
        }
      }
      _preferences.setString("events", json.encode(encodeMap(_events)));

      _setNotification(event, selectedDay);
      Navigator.pop(context, true);
    }
  }
}
