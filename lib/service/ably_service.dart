import 'dart:async';

import 'package:ably_cryptocurrency/config.dart';
import 'package:ably_flutter_plugin/ably_flutter_plugin.dart' as ably;

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

    /// this line is optional, but usseful to have more detailed logs
    _clientOptions.logLevel = ably.LogLevel.verbose;

    /// initialize real time object
    final _realtime = ably.Realtime(options: _clientOptions);

    await _realtime.connect();

    return AblyService._(_realtime, _clientOptions);
  }

  Stream<ChatMessage> listenToChatMessages() {
    _chatChannel = _realtime.channels.get('public-chat');

    var messageStream = _chatChannel.subscribe();

    return messageStream.map((message) {
      return ChatMessage(content: message.data, dateTime: message.timestamp, isWriter: message.name == "user");
    });
  }

  Future sendMessage(String content) async {
    _realtime.channels.get('public-chat');

    await _chatChannel.publish(data: content, name: "user");
  }

  /// Listen to cryptocurrency prices from Coindesk hub
  Map<String, Stream<Coin>> listenToCoinsPrice() {
    Map<String, Stream<Coin>> _streams = {};
    for (String coinType in _coinTypes.keys) {
      //launch a channel for each coin type
      ably.RealtimeChannel channel = _realtime.channels.get('[product:ably-coindesk/crypto-pricing]$coinType:usd');

      //subscribe to receive channel messages
      final messageStream = channel.subscribe();

      //map each stream event to a Coin inside a list of streams
      _streams.addAll({
        '$coinType': messageStream.where((event) => event.data != null).map((message) {
          return Coin(
            name: _coinTypes[coinType],
            code: coinType,
            price: double.parse('${message.data}'),
            dateTime: message.timestamp,
          );
        }),
      });
    }

    return _streams;
  }
}
