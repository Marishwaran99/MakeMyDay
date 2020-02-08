import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:make_my_day/models/news_loc.dart';
import 'package:http/http.dart' as http;
import 'package:make_my_day/screens/news_detail.dart';
import 'package:make_my_day/screens/news_sources_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';

class NewsScreenRoute extends CupertinoPageRoute {
  NewsScreenRoute() : super(builder: (BuildContext context) => new NewsPage());
}

class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage>
    with SingleTickerProviderStateMixin {
  List<NewsLoc> source;

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
    source = List<NewsLoc>(7);
    for (int i = 0; i < newsCategories.length; i++) {
      var c = newsCategories[i];
      url =
          'https://newsapi.org/v2/top-headlines?country=in&category=$c&apiKey=b76dd2d5ab994d29aedacb95ad4fa36e';
      fetchData(i);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  fetchData(int i) async {
    var category = newsCategories.elementAt(i);
    url =
        'https://newsapi.org/v2/top-headlines?country=in&category=$category&apiKey=b76dd2d5ab994d29aedacb95ad4fa36e';
    var res = await http.get(url);
    var decodedJson = jsonDecode(res.body);
    source[i] = NewsLoc.fromJson(decodedJson);
    if (this.mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News',
            style: TextStyle(
                fontSize: 16,
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
      body: TabBarView(controller: _tabController, children: <Widget>[
        _news(source[0]),
        _news(source[1]),
        _news(source[2]),
        _news(source[3]),
        _news(source[4]),
        _news(source[5]),
        _news(source[6]),
      ]),
    );
    // Expanded(
    //     child: ListView.builder(
    //         itemCount: source != null
    //             ? source.articles != null
    //                 ? source.articles.length
    //                 : 0
    //             : 0,
    //         itemBuilder: ((BuildContext context, int index) {
    //           return _newsSource(
    //               source.articles.elementAt(index));
    //         })))
  }

  Widget _news(var source) {
    return source == null
        ? Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : ListView.builder(
            itemCount: source != null
                ? source.articles != null ? source.articles.length : 0
                : 0,
            itemBuilder: ((BuildContext context, int index) {
              return _newsSource(source.articles.elementAt(index));
            }));
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
                            child: Stack(children: <Widget>[
                              Center(
                                child: CircularProgressIndicator(),
                              ),
                              Center(
                                child: FadeInImage.memoryNetwork(
                                    placeholder: kTransparentImage,
                                    image: article.urlToImage),
                              )
                            ]),
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
