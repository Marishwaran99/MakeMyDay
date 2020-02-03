import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:make_my_day/models/note.dart';
import 'package:make_my_day/models/note_database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:developer';
import 'add_note.dart';

class NotesScreen extends StatefulWidget {
  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  NotesDatabaseHelper helper = NotesDatabaseHelper();
  int count = 0;
  List<Note> notesList;
  List<Note> filteredList;

  TextEditingController _searchController = TextEditingController();
  final colors = [
    Color(0xffffffff), // classic white
    Color(0xfff7bd02), // yellow
    Color(0xfffbf476), // light yellow
    Color(0xffcdff90), // light green
    Color(0xffa7feeb), // turquoise
    Color(0xffcbf0f8), // light cyan
    Color(0xffafcbfa), // light blue
    Color(0xffd7aefc), // plum
    Color(0xfffbcfe9), // misty rose
    Color(0xffe6c9a9), // light brown
    Color(0xffe9eaee) // light gray
  ];

  Color noteColor;
  int currentColorIdx = 0;
  Widget _searchTitle;
  Widget _appBarTitle = Text('Notes',
      style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.25));

  Widget _appBarTitleCopy = Text('Notes',
      style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.25));
  Icon _searchIcon = new Icon(CupertinoIcons.search);
  Icon _closeIcon = new Icon(
    CupertinoIcons.clear,
    size: 36,
  );
  final _check = Icon(
    Icons.check,
    color: Colors.deepPurple,
  );

  @override
  Widget build(BuildContext context) {
    if (notesList == null) {
      notesList = List<Note>();
      filteredList = List<Note>();
      updateTodoList();
    }

    _searchTitle = TextField(
      autofocus: true,
      controller: _searchController,
      keyboardType: TextInputType.text,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(border: InputBorder.none),
      onChanged: (val) {
        setState(() {
          filteredList = notesList
              .where((n) =>
                  (n.description.toLowerCase().contains(val.toLowerCase())))
              .toList();
        });
      },
    );
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
                  filteredList = notesList;
                  this._searchIcon = Icon(Icons.search);
                  this._appBarTitle = _appBarTitleCopy;
                }
              });
            })
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool result = await Navigator.push(context,
              MaterialPageRoute(builder: (context) {
            return AddNotePage(Note(), 'Add Notes');
          }));

          if (result) {
            updateTodoList();
          }
        },
        child: Icon(Icons.add),
      ),
      body: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: ListView.builder(
            itemCount: filteredList.length,
            itemBuilder: (BuildContext context, int index) {
              return _noteCard(context, filteredList[index], index);
            },
          )),
    );
  }

  Widget _noteCard(BuildContext context, Note note, int index) {
    return Container(
      width: MediaQuery.of(context).size.width - 32,
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0)),
          child: Material(
            borderRadius: BorderRadius.circular(8.0),
            color: Color(int.parse(note.noteColor)),
            child: InkWell(
              borderRadius: BorderRadius.circular(8.0),
              focusColor: Color(int.parse(note.noteColor)),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return AddNotePage(note, 'Edit Note');
                }));
              },
              child: Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(8.0)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 16.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        note.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16, height: 1.5),
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      Text(
                        'Created at ' + note.createdAt,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      SizedBox(
                        height: 24.0,
                      ),
                      Row(
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                  builder: (BuildContext context) {
                                    return Container(
                                        height: 100,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: colors.length,
                                          itemBuilder: (context, i) {
                                            return GestureDetector(
                                                onTap: () {
                                                  _selectColor(index, i);
                                                  setState(() {});
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(8),
                                                  width: 48,
                                                  height: 48,
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle),
                                                  child: CircleAvatar(
                                                    backgroundColor: colors[i],
                                                  ),
                                                ));
                                          },
                                        ));
                                  },
                                  context: context);
                            },
                            child: Icon(
                              Icons.color_lens,
                              color: Colors.deepPurple,
                            ),
                          ),
                          SizedBox(width: 24),
                          InkWell(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Delete Note'),
                                      content: Text(
                                          'Are you sure to delete this note ?'),
                                      actions: <Widget>[
                                        FlatButton(
                                          child: Text('Keep',
                                              style: TextStyle(
                                                  color: Colors.deepPurple)),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        FlatButton(
                                          child: Text(
                                            'Delete',
                                            style: TextStyle(
                                                color: Colors.redAccent),
                                          ),
                                          onPressed: () {
                                            helper.deletenote(note.id);
                                            updateTodoList();
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  });
                            },
                            child: Icon(
                              CupertinoIcons.delete_simple,
                              color: Colors.red[300],
                            ),
                          ),
                        ],
                      ),
                    ]),
              ),
            ),
          )),
    );
  }

  Widget _checkOrNot(int i) {
    if (i == currentColorIdx) {
      return _check;
    }
    return null;
  }

  void _selectColor(int index, int colorIdx) {
    setState(() {
      noteColor = colors[colorIdx];
      currentColorIdx = colorIdx;

      filteredList[index].noteColor = noteColor.value.toString();
      helper.updatenote(filteredList[index]);
    });
  }

  void filterList() {}
  void updateTodoList() {
    Future<Database> dbFuture = helper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> todosFuture = helper.getnoteList();
      todosFuture.then((notes) {
        setState(() {
          this.notesList = notes;
          this.filteredList = notes;
          this.count = notes.length;
        });
      });
    });
  }
}
