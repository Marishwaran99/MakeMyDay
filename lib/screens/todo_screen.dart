import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:make_my_day/models/database_helper.dart';
import 'package:make_my_day/models/todo.dart';
import 'package:make_my_day/screens/add_todo.dart';
import 'package:sqflite/sqflite.dart';

class TodoScreenRoute extends CupertinoPageRoute {
  TodoScreenRoute()
      : super(builder: (BuildContext context) => new TodoScreen());
}

class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen>
    with SingleTickerProviderStateMixin {
  DatabaseHelper helper = DatabaseHelper();
  int count = 0;
  List<Todo> todosList;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  TextEditingController _taskController = TextEditingController();
  var _taskFocus = FocusNode();
  Todo selectedTodo;
  TimeOfDay _time;
  int selectedTodoIdx;
  List<Todo> filteredList;

  TextEditingController _searchController = TextEditingController();

  Widget _appBarTitle = Text('Tasks',
      style: TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5));

  Widget _appBarTitleCopy = Text('Tasks',
      style: TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5));
  Icon _searchIcon = new Icon(
    CupertinoIcons.search,
  );
  Icon _closeIcon = new Icon(
    CupertinoIcons.clear,
    size: 36,
  );
  Widget _searchTitle;
  bool _isVisible;
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

    _searchTitle = TextField(
      autofocus: true,
      controller: _searchController,
      keyboardType: TextInputType.text,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(border: InputBorder.none),
      onChanged: (val) {
        setState(() {
          filteredList = todosList
              .where((n) => (n.title.toLowerCase().contains(val.toLowerCase())))
              .toList();
        });
      },
    );
    if (this.mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _isVisible = true;
    if (todosList == null) {
      todosList = List<Todo>();
      filteredList = List<Todo>();
      updateTodoList();

      log(todosList.toString());
    }
    return Scaffold(
      appBar: AppBar(title: this._appBarTitle, actions: <Widget>[
        IconButton(
            icon: this._searchIcon,
            onPressed: () {
              setState(() {
                if (this._searchIcon.icon == CupertinoIcons.search) {
                  this._searchIcon = _closeIcon;
                  this._appBarTitle = _searchTitle;
                } else {
                  _searchController.text = '';
                  filteredList = todosList;
                  this._searchIcon = Icon(CupertinoIcons.search);
                  this._appBarTitle = _appBarTitleCopy;
                }
              });
            })
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool nav = await Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext ctx) {
            return AddTodoScreen(Todo(
                title: '',
                isDone: 'false',
                isDailyTask: 'false',
                createdAt: ''));
          }));
          if (nav) updateTodoList();
        },
        child: Icon(
          CupertinoIcons.add,
          size: 36,
        ),
      ),
      body: AnimatedOpacity(
        child: Padding(
            padding: EdgeInsets.all(4.0),
            child: filteredList == null
                ? CircularProgressIndicator()
                : filteredList.length > 0
                    ? ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return _taskCard(context, filteredList[index], index);
                        },
                      )
                    : filteredList == null
                        ? CircularProgressIndicator()
                        : Center(child: Text('No Tasks yet'))),
        opacity: _isVisible ? 1 : 0.75,
        duration: Duration(milliseconds: 400),
      ),
    );
  }

  Widget _taskCard(BuildContext context, Todo todo, index) {
    return Container(
      width: MediaQuery.of(context).size.width - 16.0,
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
          child: Material(
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.grey[200],
              child: InkWell(
                  borderRadius: BorderRadius.circular(8.0),
                  splashColor: Colors.grey[300],
                  hoverColor: Colors.grey[300],
                  focusColor: Colors.grey[300],
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (BuildContext ctx) {
                      return AddTodoScreen(todo);
                    }));
                  },
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Opacity(
                          opacity: todo.isDone == "false" ? 1 : 0.5,
                          child: Container(
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.symmetric(vertical: 4.0),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0)),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Checkbox(
                                            value: todo.isDone == 'false'
                                                ? false
                                                : true,
                                            tristate: false,
                                            onChanged: (val) {
                                              log(val.toString());
                                              todo.isDone = val.toString();
                                              if (todo.isDone == "true" &&
                                                  val) {
                                                _cancelNotification(todo.id);
                                              } else if (todo.isDone ==
                                                      "false" &&
                                                  !val) {
                                                if (todo.createdAt != '') {
                                                  var dt = DateTime.parse(
                                                      todo.createdAt);
                                                  if (DateTime.now()
                                                      .isBefore(dt)) {
                                                    log('evt ' +
                                                        todo.createdAt);
                                                    _setNotification(
                                                        todo,
                                                        DateTime.parse(
                                                            todo.createdAt));
                                                  }
                                                }
                                              }
                                              helper.updateTodo(todo);
                                              setState(() {});
                                            },
                                          ),
                                          Expanded(
                                            child: Text(todo.title,
                                                style: TextStyle(
                                                    height: 1.5,
                                                    decoration: todo.isDone ==
                                                            'false'
                                                        ? TextDecoration.none
                                                        : TextDecoration
                                                            .lineThrough)),
                                          ),
                                        ]),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        todo.createdAt != ''
                                            ? Column(
                                                children: <Widget>[
                                                  Container(
                                                      margin: EdgeInsets.only(
                                                          left: 16.0),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 8.0,
                                                              vertical: 4.0),
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Colors.grey[300],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0)),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: <Widget>[
                                                          Icon(CupertinoIcons
                                                              .bell_solid),
                                                          SizedBox(
                                                            width: 8.0,
                                                          ),
                                                          Text(todo.isDailyTask ==
                                                                  "false"
                                                              ? formatDt(DateTime
                                                                  .parse(todo
                                                                      .createdAt))
                                                              : formatTime(DateTime
                                                                  .parse(todo
                                                                      .createdAt))),
                                                          SizedBox(width: 4.0),
                                                          InkWell(
                                                            onTap: () {
                                                              log('mm');
                                                              todo.createdAt =
                                                                  '';
                                                              _cancelNotification(
                                                                  todo.id);

                                                              helper.updateTodo(
                                                                  todo);
                                                              updateTodoList();
                                                            },
                                                            child: Icon(
                                                                Icons.clear),
                                                          ),
                                                        ],
                                                      )),
                                                ],
                                              )
                                            : Container(),
                                        todo.isDailyTask == "true"
                                            ? Container(
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 16),
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 4.0,
                                                    horizontal: 8.0),
                                                //margin: EdgeInsets.all(8.0),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    color: Colors.deepPurple),
                                                child: Text(
                                                  'Daily Task',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      letterSpacing: 1,
                                                      color: Colors.white),
                                                ))
                                            : Container(),
                                        IconButton(
                                            icon: Icon(
                                              CupertinoIcons.delete_simple,
                                              color: Colors.red[300],
                                            ),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return CupertinoAlertDialog(
                                                    title: Text(
                                                      'Delete Todo',
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Montserrat'),
                                                    ),
                                                    content: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 8.0),
                                                      child: Text(
                                                        'Are you sure to delete this todo ?',
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
                                                          _cancelNotification(
                                                              todo.id);
                                                          helper.deleteTodo(
                                                              todo.id);

                                                          updateTodoList();
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            })
                                      ],
                                    ),
                                  ])),
                        )
                      ])))),
    );
  }

  formatDt(DateTime dt) {
    var day = dt.day;
    return DateFormat.MMMd().add_jm().format(dt);
  }

  String formatTime(DateTime dt) {
    return DateFormat.jm().format(dt);
  }

  void updateTodoList() {
    Future<Database> dbFuture = helper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Todo>> todosFuture = helper.getTodoList();
      todosFuture.then((todos) {
        setState(() {
          this.todosList = todos;
          this.filteredList = todos;
          this.count = todos.length;
          selectedTodoIdx = -1;
        });
      });
    });
  }

  Future _cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
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
    if (todo.isDailyTask == 'false') {
      log(selectedTime.toString());

      await flutterLocalNotificationsPlugin
          .schedule(todo.id, 'Todo', todo.title, selectedTime,
              platformChannelSpecifics)
          .then((v) {
        log('notification set');
      });
    } else {
      var d = DateTime.parse(todo.createdAt);
      Time t = Time(d.hour, d.minute);
      log(t.toString());
      await flutterLocalNotificationsPlugin.schedule(
          todo.id, 'Todo', todo.title, selectedTime, platformChannelSpecifics);
    }
  }
}
