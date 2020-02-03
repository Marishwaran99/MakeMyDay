class Todo {
  String title;
  String isDone;
  String createdAt;
  String isDailyTask;
  int id;
  Todo({this.title, this.isDone, this.createdAt, this.isDailyTask});

  Todo.withId(
      this.id, this.title, this.isDone, this.createdAt, this.isDailyTask);

  int get _id => id;

  String get _title => title;
  String get _createdAt => createdAt;
  String get _check => isDone;
  String get _isDailyTask => isDailyTask;

  set _title(String t) {
    if (t.length < 200) {
      this.title = t;
    }
  }

  set _isDone(String c) {
    this.isDone = c;
  }

  set _isDailyTask(String dt) {
    this.isDailyTask = dt;
  }

  set _createdAt(String d) {
    this.createdAt = d;
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    if (id != null) {
      map['id'] = id;
    }

    map['title'] = title;

    map['isDone'] = isDone;

    map['createdAt'] = createdAt;
    map['isDailyTask'] = isDailyTask;

    return map;
  }

  Todo.fromMapObject(Map<String, dynamic> map) {
    this.id = map['id'];
    this.title = map['title'];
    this.isDone = map['isDone'];
    this.createdAt = map['createdAt'];
    this.isDailyTask = map['isDailyTask'];
  }
}
