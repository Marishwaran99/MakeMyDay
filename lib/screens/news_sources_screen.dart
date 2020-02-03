import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:make_my_day/models/news_source.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NewsSourceScreen extends StatefulWidget {
  @override
  _NewsSourceScreenState createState() => _NewsSourceScreenState();
}

class _NewsSourceScreenState extends State<NewsSourceScreen>
    with SingleTickerProviderStateMixin {
  var url =
      'https://newsapi.org/v2/sources?apiKey=48ff06d79a6d4c4e845b60345b3028ae';
  NewsSources _newsSources;
  List<String> subscriptionList = List<String>();
  SharedPreferences sharedPreferences;
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  fetchData() async {
    sharedPreferences = await SharedPreferences.getInstance();
    bool sublist = sharedPreferences.containsKey('subscriptionList');
    var res = await http.get(url);
    var decodedJson = jsonDecode(res.body);
    _newsSources = NewsSources.fromJson(decodedJson);

    if (sublist) {
      var sl = sharedPreferences.getStringList('subscriptionList');
      if (sl.isNotEmpty) {
        subscriptionList.addAll(sl);
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          bottom: PreferredSize(
            child: Row(
              children: <Widget>[],
            ),
            preferredSize: Size(MediaQuery.of(context).size.width, 48.0),
          ),
          leading: IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            ' News Sources',
            style: TextStyle(fontSize: 18),
          ),
        ),
        body: Container(
            padding: EdgeInsets.only(top: 8.0),
            child: _newsSources == null
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _newsSources.sources.length,
                    itemBuilder: ((BuildContext context, int index) {
                      return _newsSource(_newsSources.sources.elementAt(index));
                    }))));
  }

  Widget _newsSource(Sources source) {
    return Container(
        padding: EdgeInsets.only(left: 16, right: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  source.name,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1),
                ),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              source.description != null ? source.description : '',
              style: TextStyle(
                  color: Colors.grey[700], letterSpacing: 0.5, height: 1.5),
            ),
            SizedBox(
              height: 16,
            ),
            Row(
              children: <Widget>[
                Text('Category'),
                SizedBox(
                  width: 8,
                ),
                Chip(
                  label: Text(
                    source.category,
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 16.0,
            ),
            FlatButton(
              color: Colors.deepPurple,
              textColor: Colors.white,
              onPressed: () async {
                setState(() {
                  if (subscriptionList.contains(source.id)) {
                    subscriptionList.remove(source.id);
                  } else {
                    subscriptionList.add(source.id);
                  }
                  if (sharedPreferences == null) {
                    log("null");
                  } else
                    sharedPreferences.setStringList(
                        'subscriptionList', subscriptionList);
                });
                log('$subscriptionList');
                //check whther data alreafy present
              },
              child: Text(subscriptionList.contains(source.id)
                  ? 'UnSubscribe'
                  : 'Subscribe'),
            ),
            Divider(
              color: Colors.grey[400],
            )
          ],
        ));
  }
}
