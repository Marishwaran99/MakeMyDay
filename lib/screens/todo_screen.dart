import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:make_my_day/models/database_helper.dart';
import 'package:make_my_day/models/todo.dart';
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
  var _time;
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
  GlobalKey<AnimatedListState> _animKey = GlobalKey<AnimatedListState>();
  Animation<Offset> _animOffset;
  AnimationController _animationController;
  Widget _searchTitle;
  @override
  void initState() {
    // _animationController =
    //     AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    // _animOffset = Tween<Offset>(begin: Offset(-1, 0), end: Offset.zero).animate(
    //     CurvedAnimation(parent: _animationController, curve: Curves.elasticIn));

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

  // checkPendingNotifications() async {
  //   var pendingNotificationRequests =
  //       await flutterLocalNotificationsPlugin.pendingNotificationRequests();
  //   var r = pendingNotificationRequests.elementAt(0);
  //   log('$r');
  //

  @override
  Widget build(BuildContext context) {
    if (todosList == null) {
      todosList = List<Todo>();
      filteredList = List<Todo>();
      updateTodoList();
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
          _taskController.text = '';
          _time = null;
          showModalBottomSheet(
              context: context,
              builder: (context) {
                Todo todo = Todo(title: '', createdAt: '', isDone: 'false');
                return Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: todoBottomSheet(todo, context),
                );
              });
        },
        child: Icon(
          CupertinoIcons.add,
          size: 36,
        ),
      ),
      body: Padding(
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
    );
  }

  Widget _taskCard(BuildContext context, Todo todo, index) {
    return Container(
      width: MediaQuery.of(context).size.width - 16.0,
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Material(
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.grey[200],
              child: InkWell(
                  borderRadius: BorderRadius.circular(8.0),
                  splashColor: Colors.grey[300],
                  hoverColor: Colors.grey[300],
                  focusColor: Colors.grey[300],
                  onTap: () {
                    setState(() {
                      selectedTodoIdx = index;
                    });
                    showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (context) {
                          _taskController.text = todo.title;
                          return Padding(
                            padding: MediaQuery.of(context).viewInsets,
                            child: todoBottomSheet(todo, context),
                          );
                        });
                  },
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Opacity(
                          opacity: todo.isDone == "false" ? 1 : 0.5,
                          child: Container(
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 8.0),
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
                                              todo.isDone = val.toString();
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
                                          IconButton(
                                              alignment: Alignment.centerRight,
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
                                                            const EdgeInsets
                                                                .only(top: 8.0),
                                                        child: Text(
                                                          'Are you sure to delete this todo ?',
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
                                                            _cancelNotification(
                                                                todo.id);
                                                            helper.deleteTodo(
                                                                todo.id);

                                                            updateTodoList();
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              })
                                        ]),
                                    todo.createdAt != ''
                                        ? Column(
                                            children: <Widget>[
                                              SizedBox(
                                                height: 16.0,
                                              ),
                                              Container(
                                                  margin: EdgeInsets.only(
                                                      left: 16.0),
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 8.0,
                                                      vertical: 4.0),
                                                  decoration: BoxDecoration(
                                                      color: Colors.grey[300],
                                                      borderRadius:
                                                          BorderRadius.circular(
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
                                                      Text(formatTimeOfDay(
                                                          TimeOfDay.fromDateTime(
                                                              DateTime.parse(todo
                                                                  .createdAt))))
                                                    ],
                                                  )),
                                            ],
                                          )
                                        : Container()
                                  ])),
                        )
                      ])))),
    );
  }

  String formatTimeOfDay(TimeOfDay tod) {
    final now = new DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm();
    return format.format(dt);
  }

  Widget todoBottomSheet(Todo todo, BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: 200,
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: EditableText(
                  controller: _taskController,
                  focusNode: _taskFocus,
                  onChanged: (val) {
                    setState(() {
                      todo.title = val;
                    });
                  },
                  onEditingComplete: () {
                    setState(() {
                      todo.title = _taskController.text;
                    });
                  },
                  autofocus: true,
                  backgroundCursorColor: Colors.deepPurple,
                  keyboardType: TextInputType.multiline,
                  maxLines: 10,
                  style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      letterSpacing: 0.5,
                      fontFamily: 'Montserrat',
                      color: Colors.black),
                  cursorColor: Colors.deepPurple,
                ),
              ),
              Container(
                  height: 64,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      GestureDetector(
                          onTap: () async {
                            var now = DateTime.now();
                            _time = await showTimePicker(
                                initialTime: todo.createdAt == ''
                                    ? TimeOfDay(
                                        hour: now.hour, minute: now.minute)
                                    : TimeOfDay(
                                        hour:
                                            DateTime.parse(todo.createdAt).hour,
                                        minute: DateTime.parse(todo.createdAt)
                                            .minute),
                                context: context);

                            var selectedTime = DateTime(now.year, now.month,
                                now.day, _time.hour, _time.minute);
                            if (todo.id != null) {
                              todo.createdAt = selectedTime.toString();
                              helper.updateTodo(todo);
                              _setNotification(todo, selectedTime);
                              updateTodoList();
                            } else
                              todo.createdAt = selectedTime.toString();
                          },
                          child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8.0)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    CupertinoIcons.bell_solid,
                                    size: 18.0,
                                  ),
                                  SizedBox(width: 4.0),
                                  todo.createdAt == null || todo.createdAt == ''
                                      ? Text(
                                          'Set reminder',
                                          style: TextStyle(fontSize: 14.0),
                                        )
                                      : Row(children: <Widget>[
                                          Text(
                                            _time == null || _time == ''
                                                ? formatTimeOfDay(
                                                    TimeOfDay.fromDateTime(
                                                        DateTime.parse(
                                                            todo.createdAt)))
                                                : formatTimeOfDay(_time),
                                            style: TextStyle(
                                                fontSize: 14.0,
                                                letterSpacing: 1),
                                          ),
                                          SizedBox(width: 8.0),
                                          GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  todo.createdAt = '';
                                                  if (todo.id != null) {
                                                    helper.updateTodo(todo);
                                                    _cancelNotification(
                                                        todo.id);
                                                    updateTodoList();
                                                  }
                                                });
                                              },
                                              child: Icon(Icons.clear))
                                        ]),
                                ],
                              ))),
                      FlatButton(
                          child: Text(
                            'Done',
                            style: TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.bold),
                          ),
                          onPressed: () async {
                            log(_taskController.text.length.toString());
                            if (_taskController.text.length > 0 ||
                                todo.title.length > 0) {
                              if (todo.id == null) {
                                todo.title = _taskController.text;

                                if (_time != null ||
                                    _time != '' ||
                                    todo.createdAt != '' ||
                                    todo.createdAt != null) {
                                  var now = DateTime.now();
                                  todo.createdAt = _time != null
                                      ? DateTime(now.year, now.month, now.day,
                                              _time.hour, _time.minute)
                                          .toString()
                                      : '';
                                }

                                int id = await helper.insertTodo(todo);
                                if (todo.createdAt != null ||
                                    todo.createdAt != '') {
                                  _setNotificationForNewTodo(id, todo);
                                }
                              } else {
                                helper.updateTodo(todo);
                              }
                              updateTodoList();

                              Navigator.pop(context);
                            }
                          })
                    ],
                  ))
            ]));
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

  Future _setNotificationForNewTodo(int id, Todo todo) async {
    var androidSpecificChanges = AndroidNotificationDetails(
      id.toString(),
      "channel1",
      "this is test channel",
    );
    var iosSpecificChanges = IOSNotificationDetails();

    var platformChannelSpecifics =
        NotificationDetails(androidSpecificChanges, iosSpecificChanges);
    await flutterLocalNotificationsPlugin.schedule(id, 'Todo', todo.title,
        DateTime.parse(todo.createdAt), platformChannelSpecifics);
  }

  Future _setNotification(Todo todo, var selectedTime) async {
    var androidSpecificChanges = AndroidNotificationDetails(
      todo.id.toString(),
      "channel1",
      "this is test channel",
    );
    var iosSpecificChanges = IOSNotificationDetails();

    var platformChannelSpecifics =
        NotificationDetails(androidSpecificChanges, iosSpecificChanges);
    await flutterLocalNotificationsPlugin.schedule(
        todo.id, 'Todo', todo.title, selectedTime, platformChannelSpecifics);
  }
}
