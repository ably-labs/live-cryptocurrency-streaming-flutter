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


const Map<String, String> _coinTypes = {
  "btc": "Bitcoin",
  "eth": "Ethurum",
  "xrp": "Ripple",
};

class AblyService {
  /// initialize client options for your Ably account
  final ably.ClientOptions _clientOptions;

  /// initialize a realtime instance
  final ably.Realtime _realtime;

  ably.RealtimeChannel _chatChannel;

  /// to get the connection status of the realtime instance
  Stream<ably.ConnectionStateChange> get connection => _realtime.connection.on();

  /// private constructor
  AblyService._(this._realtime, this._clientOptions);

  static Future<AblyService> init() async {
    final ably.ClientOptions _clientOptions = ably.ClientOptions.fromKey(APIKey);

    /// initialize real time object
    final _realtime = ably.Realtime(options: _clientOptions);

    await _realtime.connect();

    return AblyService._(_realtime, _clientOptions);
  }

  ChatUpdates listenToChatMessages() {
    ChatUpdates _chatUpdates = ChatUpdates();

    _chatChannel = _realtime.channels.get('public-chat');

    var messageStream = _chatChannel.subscribe();

    messageStream.listen((message) {
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

  Future sendMessage(String content) async {
    _realtime.channels.get('public-chat');

    await _chatChannel.publish(data: content, name: "${_realtime.clientId}");
  }

  /// Listen to cryptocurrency prices from Coindesk hub
  List<CoinUpdates> getCoinUpdates() {
    Map<String, CoinUpdates> _coinUpdates = {};

    for (String coinType in _coinTypes.keys) {
      _coinUpdates.addAll({'$coinType': CoinUpdates()});

      //launch a channel for each coin type
      ably.RealtimeChannel channel = _realtime.channels.get('[product:ably-coindesk/crypto-pricing]$coinType:usd');

      //subscribe to receive channel messages
      final messageStream = channel.subscribe();

      //map each stream event to a Coin inside a list of streams

      messageStream.where((event) => event.data != null).listen((message) {
        _coinUpdates['$coinType'].updateCoin(
          Coin(
            name: _coinTypes[coinType],
            code: coinType,
            price: double.parse('${message.data}'),
            dateTime: message.timestamp,
          ),
        );
      });
    }

    return _coinUpdates.values.toList();
  }
}