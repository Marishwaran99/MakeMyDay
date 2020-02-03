import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:make_my_day/models/note.dart';
import 'package:make_my_day/models/note_database_helper.dart';
import 'package:toast/toast.dart';

class AddNotePage extends StatefulWidget {
  final Note note;
  final String appBarTitle;

  AddNotePage(this.note, this.appBarTitle);
  @override
  _AddNotePageState createState() =>
      _AddNotePageState(this.note, this.appBarTitle);
}

class _AddNotePageState extends State<AddNotePage> {
  NotesDatabaseHelper helper = NotesDatabaseHelper();
  TextEditingController _descriptionController = TextEditingController();

  Note note;
  String appBarTitle;

  var _descriptionFocus = FocusNode();

  _AddNotePageState(this.note, this.appBarTitle);
  @override
  Widget build(BuildContext context) {
    _descriptionController.text = note.description;
    return Scaffold(
        resizeToAvoidBottomPadding: true,
        appBar: AppBar(
          title: Text(appBarTitle, style: TextStyle(fontSize: 18)),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
                _save();
              },
            )
          ],
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.chevron_left),
          ),
        ),
        body: Container(
            padding: EdgeInsets.all(24.0),
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Flexible(
                  child: Container(
                    child: EditableText(
                      autofocus: true,
                      controller: _descriptionController,
                      maxLines: 9999,
                      focusNode: _descriptionFocus,
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.grey[700],
                          fontSize: 16,
                          letterSpacing: 1,
                          height: 1.25),
                      backgroundCursorColor: Colors.deepPurple,
                      cursorColor: Colors.deepPurple,
                    ),
                  ),
                )
              ],
            )));
  }

  void _save() async {
    note.description = _descriptionController.text;
    note.noteColor = Color(0xffffffff).value.toString();

    var df = DateFormat('dd-MM-yyyy kk:mm a');
    note.createdAt = df.format(DateTime.now());
    int result;

    if (note.id == null)
      result = await helper.insertnote(note);
    else
      result = await helper.updatenote(note);
    if (result != 0) {
      Toast.show("Saved Successfully", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);

      Navigator.pop(context, true);
    } else {
      Toast.show("Something went wrong", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }
  }
}
