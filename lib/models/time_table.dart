class TimeTable {
  String day;
  String startTime;
  String endTime;
  String description;
  int id;

  TimeTable({this.day, this.startTime, this.endTime, this.description});
  TimeTable.withId(
      this.id, this.day, this.description, this.startTime, this.endTime);
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = id;
    }
    map['description'] = description;
    map['day'] = day;
    map['startTime'] = startTime;
    map['endTime'] = endTime;

    return map;
  }

  TimeTable.fromMapObject(Map<String, dynamic> map) {
    this.id = map['id'];
    this.day = map['day'];
    this.description = map['description'];
    this.endTime = map['endTime'];
    this.startTime = map['startTime'];
  }
}

class Time {
  String startTime;
  String endTime;
  Time({startTime, endTime});
}
