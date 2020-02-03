class Note {
  String description;
  String createdAt;
  String noteColor;
  int id;
  Note({this.description, this.createdAt, this.noteColor});

  Note.withId(this.id, this.description, this.createdAt, this.noteColor);

  int get _id => id;

  String get _createdAt => createdAt;
  String get _description => description;
  String get _noteColor => noteColor;

  set _description(String c) {
    this.description = c;
  }

  set _createdAt(String d) {
    this.createdAt = d;
  }

  set _noteColor(String nc) {
    this.noteColor = nc;
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    if (id != null) {
      map['id'] = id;
    }

    map['description'] = description;

    map['createdAt'] = createdAt;
    map['noteColor'] = noteColor;

    return map;
  }

  Note.fromMapObject(Map<String, dynamic> map) {
    this.id = map['id'];
    this.description = map['description'];
    this.createdAt = map['createdAt'];
    this.noteColor = map['noteColor'];
  }
}
