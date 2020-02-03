import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:make_my_day/models/news_loc.dart';
import 'package:http/http.dart' as http;
import 'package:make_my_day/screens/news_detail.dart';
import 'package:make_my_day/screens/news_sources_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage>
    with SingleTickerProviderStateMixin {
  NewsLoc _newsLoc;

  List<String> newsCategories = [
    'business',
    'entertainment',
    'general',
    'health',
    'sports',
    'technology',
    'science'
  ];
  TabController _tabController;
  var category;

  var url;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: newsCategories.length);
    category = newsCategories[0];
    url =
        'https://newsapi.org/v2/top-headlines?country=in&category=$category&apiKey=48ff06d79a6d4c4e845b60345b3028ae';
    fetchData();

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        log('helo');
        setState(() {
          category = newsCategories[_tabController.index];
          fetchData();
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  fetchData() async {
    _newsLoc = null;
    url =
        'https://newsapi.org/v2/top-headlines?country=in&category=$category&apiKey=48ff06d79a6d4c4e845b60345b3028ae';
    var res = await http.get(url);
    var decodedJson = jsonDecode(res.body);
    _newsLoc = NewsLoc.fromJson(decodedJson);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        log('helo');
        setState(() {
          category = newsCategories[_tabController.index];
          fetchData();
        });
      }
    });
    return Scaffold(
        appBar: AppBar(
          title: Text('News',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.25)),
          bottom: TabBar(
              isScrollable: true,
              controller: _tabController,
              tabs: newsCategories
                  .map((nc) =>
                      Tab(child: Text(nc[0].toUpperCase() + nc.substring(1))))
                  .toList()),
        ),
        body: TabBarView(
            controller: _tabController,
            children: newsCategories
                .map(
                  (n) => Container(
                    padding: EdgeInsets.only(top: 8.0),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: _newsLoc == null
                        ? Container(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: Center(child: CircularProgressIndicator()))
                        : ListView.builder(
                            itemCount: _newsLoc.articles.length,
                            itemBuilder: ((BuildContext context, int index) {
                              return _newsSource(
                                  _newsLoc.articles.elementAt(index));
                            })),
                  ),
                )
                .toList()
            // Expanded(
            //     child: ListView.builder(
            //         itemCount: _newsLoc != null
            //             ? _newsLoc.articles != null
            //                 ? _newsLoc.articles.length
            //                 : 0
            //             : 0,
            //         itemBuilder: ((BuildContext context, int index) {
            //           return _newsSource(
            //               _newsLoc.articles.elementAt(index));
            //         })))
            ));
  }

  Widget _newsSource(var article) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return NewsDetail(article.url);
            }));
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 16.0,
                ),
                article.urlToImage != null
                    ? Column(
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width - 32,
                            height: MediaQuery.of(context).size.height * 0.4,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: NetworkImage(article.urlToImage),
                                    fit: BoxFit.cover)),
                          ),
                          SizedBox(
                            height: 16.0,
                          ),
                        ],
                      )
                    : Container(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        article.title,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, height: 1.75),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 16.0,
                ),
                article.description != null
                    ? Text(
                        article.description,
                        style: TextStyle(color: Colors.grey[700], height: 1.5),
                      )
                    : SizedBox(
                        height: 0,
                      ),
                SizedBox(
                  height: 16.0,
                ),
                Divider(
                  height: 0.5,
                  color: Colors.grey[400],
                ),
              ],
            ),
          )),
    );
  }
}
