import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:make_my_day/models/database_helper.dart';
import 'package:make_my_day/models/todo.dart';

class AddTodoScreen extends StatefulWidget {
  final Todo todo;
  AddTodoScreen(this.todo);
  @override
  _AddTodoScreenState createState() => _AddTodoScreenState(this.todo);
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  Todo todo;
  TextEditingController _taskController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  DatabaseHelper helper = DatabaseHelper();
  var _selectedDt;
  var _time, _date;

  _AddTodoScreenState(this.todo);
  @override
  void initState() {
    super.initState();
    _taskController.text = todo.title;
    _date = todo.createdAt != '' ? DateTime.parse(todo.createdAt) : '';
    _time = todo.createdAt != ''
        ? TimeOfDay.fromDateTime(DateTime.parse(todo.createdAt))
        : '';
    _dateController.text = _date == '' ? '' : formatDate(_date);
    _timeController.text = _time == '' ? '' : formatTime(_time);
    if (_date != '' || _time != '')
      _selectedDt = DateTime(
          _date.year, _date.month, _date.day, _time.hour, _time.minute);
    else
      _selectedDt = null;
    var initialisationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    var initialisationSettingsIos = IOSInitializationSettings();

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettings = InitializationSettings(
        initialisationSettingsAndroid, initialisationSettingsIos);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  formatDate(DateTime dt) {
    if (dt != null) return DateFormat.yMMMd().format(dt);
  }

  formatTime(TimeOfDay td) {
    if (td != null) {
      var now = DateTime.now();
      var dt = DateTime(now.year, now.month, now.day, td.hour, td.minute);
      return DateFormat.jm().format(dt);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Todo',
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
              TextField(
                autofocus: true,
                controller: _taskController,
                onChanged: (val) {
                  setState(() {
                    todo.title = val;
                  });
                },
                decoration: InputDecoration(
                    hasFloatingPlaceholder: true,
                    labelText: 'Enter your task here',
                    hintText: 'Eg: Client Meeting'),
              ),
              SizedBox(
                height: 16,
              ),
              TextField(
                controller: _dateController,
                readOnly: true,
                onTap: () async {
                  var d = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020, DateTime.now().month),
                      lastDate: DateTime(2025));
                  if (d != null)
                    setState(() {
                      _date = d;
                      _dateController.text = formatDate(d);
                    });
                },
                decoration: InputDecoration(
                    hasFloatingPlaceholder: true,
                    labelText: 'Remind At Day',
                    hintText: 'Eg: Jan 1, 2020'),
              ),
              SizedBox(
                height: 16,
              ),
              TextField(
                readOnly: true,
                controller: _timeController,
                onTap: () async {
                  TimeOfDay t = await showTimePicker(
                      context: context, initialTime: TimeOfDay.now());
                  if (t != null)
                    setState(() {
                      _time = t;
                      _timeController.text = formatTime(t);
                      if (_date == '' || _date == null) {
                        _date = DateTime.now();
                      }
                      _dateController.text = formatDate(_date);
                      _selectedDt = DateTime(_date.year, _date.month, _date.day,
                          _time.hour, _time.minute);
                      todo.createdAt = _selectedDt.toString();
                    });
                },
                decoration: InputDecoration(
                    hasFloatingPlaceholder: true,
                    labelText: 'Remind At Time',
                    hintText: '12:00 PM'),
              ),
              SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Text('Daily Task'),
                  SizedBox(width: 8),
                  Checkbox(
                      tristate: false,
                      value: todo.isDailyTask == 'false' ? false : true,
                      onChanged: (val) {
                        setState(() {
                          todo.isDailyTask = val.toString();
                        });
                      }),
                ],
              ),
              SizedBox(height: 24),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    FlatButton(
                        color: Colors.deepPurple,
                        textColor: Colors.white,
                        onPressed: () async {
                          if (todo.title.length > 1) {
                            if (todo.id == null) {
                              int id = await helper.insertTodo(todo);
                              if (todo.createdAt != '')
                                _setNotificationForNewTodo(id, todo);
                            } else {
                              helper.updateTodo(todo);
                              if ((_selectedDt != '' || _selectedDt != null) &&
                                  todo.createdAt != '') {
                                log(_selectedDt.toString());
                                _setNotification(todo, _selectedDt);
                              }
                            }

                            Navigator.pop(context, true);
                          }
                        },
                        child: Text('Save')),
                    todo.id != null && todo.createdAt != ''
                        ? FlatButton(
                            color: Colors.deepPurple,
                            textColor: Colors.white,
                            onPressed: () async {
                              todo.createdAt = '';
                              _dateController.text = '';
                              _timeController.text = '';
                              _selectedDt = '';
                              if (todo.id != null) _cancelNotification(todo.id);
                              setState(() {});
                            },
                            child: Text('Cancel Noification'))
                        : Container()
                  ])
            ],
          )),
    );
  }

  Future _cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future _setNotificationForNewTodo(int id, Todo todo) async {
    var androidSpecificChanges = AndroidNotificationDetails(
      id.toString(),
      "channel1",
      "this is test channel",
    );
    var iosSpecificChanges = IOSNotificationDetails();

    var platformChannelSpecifics =
        NotificationDetails(androidSpecificChanges, iosSpecificChanges);

    if (todo.isDailyTask == 'false')
      await flutterLocalNotificationsPlugin.schedule(id, 'Todo', todo.title,
          DateTime.parse(todo.createdAt), platformChannelSpecifics);
    else {
      var d = DateTime.parse(todo.createdAt);
      Time t = Time(d.hour, d.minute);
      log(t.toString());
      await flutterLocalNotificationsPlugin.showDailyAtTime(
          id, 'Todo', todo.title, t, platformChannelSpecifics);
    }
  }

  Future _setNotification(Todo todo, DateTime selectedTime) async {
    var androidSpecificChanges = AndroidNotificationDetails(
      todo.id.toString(),
      "channel1",
      "this is test channel",
    );
    var iosSpecificChanges = IOSNotificationDetails();

    var platformChannelSpecifics =
        NotificationDetails(androidSpecificChanges, iosSpecificChanges);

        if (todo.isDailyTask == 'false')
      await flutterLocalNotificationsPlugin.schedule(
        todo.id, 'Todo', todo.title, selectedTime, platformChannelSpecifics);
    else {
      var d = DateTime.parse(todo.createdAt);
      Time t = Time(d.hour, d.minute);
      log(t.toString());
      await flutterLocalNotificationsPlugin.schedule(
        todo.id, 'Todo', todo.title, selectedTime, platformChannelSpecifics);
    }
    
  }
}
