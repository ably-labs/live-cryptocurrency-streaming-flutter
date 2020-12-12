import 'dart:collection';

import 'package:ably_cryptocurrency/main.dart';
import 'package:ably_cryptocurrency/service/ably_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class ChatView extends StatefulWidget {
  const ChatView({Key key}) : super(key: key);

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  Queue<ChatMessage> messages = Queue();
  TextEditingController _controller = TextEditingController();
  ChatUpdates chatUpdates;
  VoidCallback _listener;

  @override
  void initState() {
    super.initState();
    
    chatUpdates = getIt.get<AblyService>().getChatUpdates();

    chatUpdates.addListener(
      _listener = () {
        if (chatUpdates.message != null)
          setState(() {
            messages.addFirst(chatUpdates.message);
          });
        if (messages.length > 100) {
          messages.removeFirst();
        }
      },
    );
  }

  @override
  void dispose() {
    chatUpdates.removeListener(_listener);
    super.dispose();
  }

  void onSend() async {
    final ablyService = getIt.get<AblyService>();
    await ablyService.sendMessage(_controller.text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat Room"),
      ),
      body: Column(
        children: [
          Flexible(
            fit: FlexFit.loose, // todo: this is the default of `fit` so we don't have to set it.
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ChatMessageBubble(
                  message: messages.toList()[index],
                  isWriter: messages.toList()[index].isWriter,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: Colors.white),
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      hintStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FlatButton(
                  height: 55,
                  onPressed: onSend,
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  child: Text("Sends"),
                )
              ],
            ),
          ),
          SizedBox(height: 30)
        ],
      ),
    );
  }
}

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    Key key,
    this.message,
    this.isWriter = false,
  }) : super(key: key);
  final ChatMessage message;
  final bool isWriter;

  final double radius = 15;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: isWriter ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: isWriter ? Theme.of(context).primaryColor.withOpacity(0.5) : Colors.white12,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(isWriter ? radius : 0),
                bottomRight: Radius.circular(isWriter ? 0 : radius),
                topLeft: Radius.circular(radius),
                topRight: Radius.circular(radius),
              ),
            ),
            width: MediaQuery.of(context).size.width * 0.6,
            constraints: BoxConstraints(minHeight: 50),
            child: Text(message.content),
          ),
          SizedBox(height: 5),
          Align(
            alignment: isWriter ? Alignment.bottomRight : Alignment.bottomLeft,
            child: Text(
              intl.DateFormat.Hm().format(message.dateTime),
              style: TextStyle(color: Colors.white24),
              textAlign: TextAlign.left,
            ),
          )
        ],
      ),
    );
  }
}
