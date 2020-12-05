import 'package:flutter/material.dart';

class ChatView extends StatefulWidget {
  const ChatView({Key key}) : super(key: key);

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat Room"),
      ),
    );
  }
}
