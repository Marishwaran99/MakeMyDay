import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:make_my_day/models/database_helper.dart';
import 'package:make_my_day/models/todo.dart';
import 'package:toast/toast.dart';

class AddTodoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Add Todo'),
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.chevron_left),
          ),
        ),
        body: Container(padding: EdgeInsets.all(24.0), child: AddTodo()));
  }
}

class AddTodo extends StatefulWidget {
  @override
  _AddTodoState createState() => _AddTodoState();
}

class _AddTodoState extends State<AddTodo> {
  DatabaseHelper helper = DatabaseHelper();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  var _time;
  Todo todo = Todo();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    var initialisationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initialisationSettingsIos = IOSInitializationSettings();

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettings = InitializationSettings(
        initialisationSettingsAndroid, initialisationSettingsIos);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Enter your task',
              hasFloatingPlaceholder: true,
            )),
        SizedBox(
          height: 24,
        ),
        TextField(
            controller: _timeController,
            decoration: InputDecoration(
                labelText: 'Remind me at', hasFloatingPlaceholder: true),
            onTap: () async {
              _time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              _timeController.text = formatTimeOfDay(_time);
            }),
        SizedBox(
          height: 24,
        ),
        RaisedButton(
          onPressed: () {
            _save();
          },
          child: Text(
            'Save',
            style: TextStyle(color: Colors.white),
          ),
          color: Colors.deepPurple,
        )
      ],
    );
  }

  String formatTimeOfDay(TimeOfDay tod) {
    final now = new DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm();
    return format.format(dt);
  }

  void _save() async {
    todo.title = _titleController.text;
    todo.isDone = false.toString();
    DateTime now = DateTime.now();
    todo.isDailyTask = false.toString();
    var scheduledTime =
        new DateTime(now.year, now.month, now.day, _time.hour, _time.minute);

    todo.createdAt = formatTimeOfDay(_time).toString();
    int result;
    result = await helper.insertTodo(todo);
    _showNotification(result);
    if (result != 0) {
      Toast.show("Saved Successfully", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      Navigator.pop(context, true);
    } else {
      Toast.show("Something went wrong", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }
  }

  Future _showNotification(int id) async {
    DateTime now = DateTime.now();
    var scheduledTime =
        new DateTime(now.year, now.month, now.day, _time.hour, _time.minute);

    var androidSpecificChanges = AndroidNotificationDetails(
      id.toString(),
      "channel1",
      "this is test channel",
    );
    var iosSpecificChanges = IOSNotificationDetails();

    var platformChannelSpecifics =
        NotificationDetails(androidSpecificChanges, iosSpecificChanges);
    await flutterLocalNotificationsPlugin.schedule(id, 'Daily Task',
        _titleController.text, scheduledTime, platformChannelSpecifics);
  }
}
