import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:make_my_day/models/time_table.dart';
import 'package:make_my_day/models/time_table_helper.dart';
import 'package:sqflite/sqflite.dart';

class WeeklyPlanScreenRoute extends CupertinoPageRoute {
  WeeklyPlanScreenRoute()
      : super(builder: (BuildContext context) => new WeeklyPlanScreen());
}

class WeeklyPlanScreen extends StatefulWidget {
  @override
  _WeeklyPlanScreenState createState() => _WeeklyPlanScreenState();
}

class _WeeklyPlanScreenState extends State<WeeklyPlanScreen> {
  TimeTableHelper _helper = TimeTableHelper();
  List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  List<TimeTable> tts;
  var _time1, _time2;
  TextEditingController _ttController = TextEditingController();
  var _daysIdx = 0;
  PageController _pageController;
  FocusNode _ttFocus = FocusNode();
  @override
  void initState() {
    super.initState();
    int day = DateTime.now().weekday;
    // var subDays = days.sublist((day - 1), (days.length - 1));

    // var otherDays = days.sublist(0, day - 1);
    // subDays.addAll(otherDays);
    // days = subDays;
    _pageController = PageController(initialPage: day - 1);
  }

  @override
  Widget build(BuildContext context) {
    if (tts == null) {
      tts = List<TimeTable>();
      updateTTList();
    }
    return Scaffold(
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              _ttController.text = '';
              _time1 = null;
              _time2 = null;
              showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    TimeTable tt = TimeTable(
                        day: '', startTime: '', endTime: '', description: '');
                    return Padding(
                      padding: MediaQuery.of(context).viewInsets,
                      child: _ttBottomSheet(tt, context, 1),
                    );
                  });
            },
            child: Icon(CupertinoIcons.add, size: 36)),
        body: SingleChildScrollView(
            child: Container(
                height: MediaQuery.of(context).size.height * 0.75,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (i) {
                    setState(() {
                      _daysIdx = i;
                    });
                  },
                  itemCount: days.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _scheduleCard(context, index);
                  },
                ))));
  }

  Widget _ttBottomSheet(TimeTable tt, BuildContext context, int pageIndex) {
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
                  controller: _ttController,
                  focusNode: _ttFocus,
                  onChanged: (val) {
                    setState(() {
                      tt.description = val;
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
                            _time1 = await showTimePicker(
                                initialTime: tt.startTime == ''
                                    ? TimeOfDay(
                                        hour: now.hour, minute: now.minute)
                                    : TimeOfDay(
                                        hour: DateTime.parse(tt.startTime).hour,
                                        minute: DateTime.parse(tt.startTime)
                                            .minute),
                                context: context);

                            var selectedTime = DateTime(now.year, now.month,
                                now.day, _time1.hour, _time1.minute);

                            setState(() {
                              if (tt.id != null) {
                                tt.startTime = selectedTime.toString();
                                _helper.updateTimeTable(tt);
                                updateTTList();
                              } else
                                tt.startTime = selectedTime.toString();
                            });
                          },
                          child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8.0)),
                              child: tt.startTime == null ||
                                      tt.startTime == '' && _time1 == null
                                  ? Text(
                                      'Start Time',
                                      style: TextStyle(fontSize: 14.0),
                                    )
                                  : Row(
                                      children: <Widget>[
                                        Text(
                                          _time1 == null || _time1 == ''
                                              ? formatTimeOfDay(
                                                  TimeOfDay.fromDateTime(
                                                      DateTime.parse(
                                                          tt.startTime)))
                                              : formatTimeOfDay(_time1),
                                          style: TextStyle(
                                              fontSize: 14.0, letterSpacing: 1),
                                        ),
                                      ],
                                    ))),
                      GestureDetector(
                          onTap: () async {
                            var now = DateTime.now();
                            _time2 = await showTimePicker(
                                initialTime: tt.endTime == ''
                                    ? TimeOfDay(
                                        hour: now.hour, minute: now.minute)
                                    : TimeOfDay(
                                        hour: DateTime.parse(tt.endTime).hour,
                                        minute:
                                            DateTime.parse(tt.endTime).minute),
                                context: context);

                            var selectedTime = DateTime(now.year, now.month,
                                now.day, _time2.hour, _time2.minute);
                            setState(() {
                              if (tt.id != null) {
                                tt.endTime = selectedTime.toString();
                                _helper.updateTimeTable(tt);
                                updateTTList();
                              } else
                                tt.endTime = selectedTime.toString();
                            });
                          },
                          child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8.0)),
                              child: tt.endTime == null ||
                                      tt.endTime == '' && _time2 == null
                                  ? Text(
                                      'End Time',
                                      style: TextStyle(fontSize: 14.0),
                                    )
                                  : Row(
                                      children: <Widget>[
                                        Text(
                                          _time2 == null || _time2 == ''
                                              ? formatTimeOfDay(
                                                  TimeOfDay.fromDateTime(
                                                      DateTime.parse(
                                                          tt.endTime)))
                                              : formatTimeOfDay(_time2),
                                          style: TextStyle(
                                              fontSize: 14.0, letterSpacing: 1),
                                        ),
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
                            tt.day = days[_daysIdx];
                            if (_ttController.text.length > 0 ||
                                tt.description.length > 0) {
                              if (tt.id == null) {
                                tt.description = _ttController.text;

                                if ((_time1 != null || _time1 != '') &&
                                    (_time2 != null || _time2 != '') &&
                                    (tt.description != '' ||
                                        tt.description != null)) {
                                  var now = DateTime.now();
                                  tt.startTime = _time1 != null
                                      ? DateTime(now.year, now.month, now.day,
                                              _time1.hour, _time1.minute)
                                          .toString()
                                      : '';

                                  tt.endTime = _time2 != null
                                      ? DateTime(now.year, now.month, now.day,
                                              _time2.hour, _time2.minute)
                                          .toString()
                                      : '';
                                }

                                await _helper.insertTimeTable(tt);
                              } else {
                                _helper.updateTimeTable(tt);
                              }
                              updateTTList();
                              Navigator.pop(context);
                            }
                          })
                    ],
                  ))
            ]));
  }

  String formatTimeOfDay(TimeOfDay tod) {
    final now = new DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm();
    return format.format(dt);
  }

  Widget _scheduleCard(BuildContext context, int pageIndex) {
    return Container(
      child: Column(children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            days[pageIndex],
            style: TextStyle(fontSize: 16, color: Colors.deepPurple),
          ),
        ),
        Expanded(
            child: tts == null
                ? CircularProgressIndicator()
                : tts.length > 0
                    ? ListView.builder(
                        itemCount: tts.length,
                        itemBuilder: (BuildContext context, int index) {
                          if (tts[index].day == days[pageIndex])
                            return _tt(context, tts[index], index);
                          else
                            return Container();
                        })
                    : Center(child: Text('No Work Today')))
      ]),
    );
  }

  Widget _tt(BuildContext context, TimeTable tt, int i) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
        padding: EdgeInsets.only(top: 8.0, left: 16, right: 16, bottom: 16),
        decoration: BoxDecoration(
            color: Colors.grey[200], borderRadius: BorderRadius.circular(8.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  tt.description,
                  style: TextStyle(fontSize: 16),
                ),
                IconButton(
                    icon: Icon(
                      CupertinoIcons.delete_simple,
                      color: Colors.red[300],
                    ),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return CupertinoAlertDialog(
                              title: Text('Delete'),
                              content: Text('Are you sure?'),
                              actions: <Widget>[
                                FlatButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      'Keep',
                                      style: TextStyle(
                                          color: Colors.deepPurple[400]),
                                    )),
                                FlatButton(
                                    onPressed: () {
                                      _helper.deleteTimeTable(tt.id);
                                      updateTTList();
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red[700]),
                                    )),
                              ],
                            );
                          });
                    })
              ],
            ),
            tt.startTime == null || tt.startTime == ''
                ? Container()
                : Column(
                    children: <Widget>[
                      SizedBox(height: 16),
                      Text(formatTimeOfDay(TimeOfDay.fromDateTime(
                              DateTime.parse(tt.startTime))) +
                          ' - ' +
                          formatTimeOfDay(TimeOfDay.fromDateTime(
                              DateTime.parse(tt.endTime)))),
                    ],
                  )
          ],
        ));
  }

  void updateTTList() async {
    Future<Database> dbFuture = _helper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<TimeTable>> ttFuture = _helper.getTimeTableList();

      ttFuture.then((tt) {
        if (this.mounted)
          setState(() {
            this.tts = tt;
          });
      });
    });
  }
}
