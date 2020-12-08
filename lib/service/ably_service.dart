import 'dart:async';

import 'package:ably_cryptocurrency/config.dart';
import 'package:ably_flutter_plugin/ably_flutter_plugin.dart' as ably;
import 'package:flutter/material.dart';

class Coin {
  final String name, code;
  final double price;
  final DateTime dateTime;

  Coin({
    this.name,
    this.code,
    this.price,
    this.dateTime,
  });
}

class ChatMessage {
  final String content;
  final DateTime dateTime;
  final bool isWriter;

  ChatMessage({
    this.content,
    this.dateTime,
    this.isWriter,
  });
}

class CoinUpdates extends ChangeNotifier {
  Coin _coin;
  Coin get coin => _coin;
  updateCoin(value) {
    this._coin = value;
    notifyListeners();
  }
}

class ChatUpdates extends ChangeNotifier {
  ChatMessage _message;
  ChatMessage get message => _message;
  updateChat(value) {
    this._message = value;
    notifyListeners();
  }
}

/// TODO: To add more currencies we only have to extent this map? right?
/// we should write this in a comment here if this is the case
const List<Map> _coinTypes = [
  {
    "name": "Bitcoin",
    "code": "btc",
  },
  {
    "name": "Ethurum",
    "code": "eth",
  },
  {
    "name": "Ripple",
    "code": "xrp",
  },
];

class AblyService {
  /// initialize a realtime instance
// TODO: I think this comment does not describe what this property is
  final ably.Realtime _realtime;

  ably.RealtimeChannel _chatChannel;

  /// to get the connection status of the realtime instance
  Stream<ably.ConnectionStateChange> get connection =>
      _realtime.connection.on();

  /// private constructor, as this class should only be initialized through
  /// the init() method
  AblyService._(this._realtime);

  static Future<AblyService> init() async {
    /// initialize client options for your Ably account
    final ably.ClientOptions _clientOptions =
        ably.ClientOptions.fromKey(APIKey);

    /// initialize real time object
    final _realtime = ably.Realtime(options: _clientOptions);

    await _realtime.connect();

    return AblyService._(_realtime);
  }

  ChatUpdates getChatUpdates() {
    ChatUpdates _chatUpdates = ChatUpdates();

    _chatChannel = _realtime.channels.get('public-chat');

    var messageStream = _chatChannel.subscribe();

    print(_chatChannel.name);

    messageStream.listen((message) {
      print(message);
      _chatUpdates.updateChat(
        ChatMessage(
          content: message.data,
          dateTime: message.timestamp,
          isWriter: message.name == "${_realtime.clientId}",
        ),
      );
    });

    return _chatUpdates;
  }

  /// TODO: add api doc
  Future sendMessage(String content) async {
    _realtime.channels.get('public-chat');

    await _chatChannel.publish(data: content, name: "${_realtime.clientId}");
  }

  List<CoinUpdates> _coinUpdates = [];

  /// Start listening to cryptocurrency prices from Coindesk hub
  List<CoinUpdates> getCoinUpdates() {
    if (_coinUpdates.isEmpty) {
      for (int i = 0; i < _coinUpdates.length; i++) {
        _coinUpdates[i] = CoinUpdates();

        String coinName = _coinTypes[i]['name'];
        String coinCode = _coinTypes[i]['code'];

        //launch a channel for each coin type
        ably.RealtimeChannel channel = _realtime.channels
            .get('[product:ably-coindesk/crypto-pricing]$coinCode:usd');

        //subscribe to receive channel messages
        final messageStream = channel.subscribe();

        //map each stream event to a Coin inside a list of streams
        messageStream.where((event) => event.data != null).listen((message) {
          _coinUpdates[i].updateCoin(
            Coin(
              name: coinName,
              code: coinCode,
              price: double.parse('${message.data}'),
              dateTime: message.timestamp,
            ),
          );
        });
      }
    }
    return _coinUpdates;
  }
}
