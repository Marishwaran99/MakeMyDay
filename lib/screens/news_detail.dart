import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NewsDetail extends StatefulWidget {
  final String url;

  NewsDetail(this.url);

  @override
  _NewsDetailState createState() => _NewsDetailState();
}

class _NewsDetailState extends State<NewsDetail> {
  bool isLoading = true;

  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Stack(children: <Widget>[
      WebView(
        initialUrl: widget.url,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController wvc) {
          _controller.complete(wvc);
        },
        onPageFinished: (finish) {
          log('$finish');
        },
        onPageStarted: (start) {
          setState(() {
            isLoading = false;
          });
        },
      ),
      isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container()
    ])));
  }
}
