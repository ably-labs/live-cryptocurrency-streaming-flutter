import 'package:flutter/material.dart';

class TwitterFeedView extends StatefulWidget {
  const TwitterFeedView({Key key, @required this.hashtag}) : super(key: key);
  final String hashtag;

  @override
  _TwitterFeedViewState createState() => _TwitterFeedViewState();
}

class _TwitterFeedViewState extends State<TwitterFeedView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("#${widget.hashtag}"),
      ),
    );
  }
}
