import 'dart:async';

import 'package:ably_cryptocurrency/config.dart';
import 'package:ably_flutter_plugin/ably_flutter_plugin.dart' as ably;
import 'package:flutter/material.dart';

/// In case more cryptocurrencies are added to Coindesk hub, you can
/// add them directly here, and the app will display the corresponding graph
const List<Map> _coinTypes = [
  {
    "name": "Bitcoin",
    "code": "btc",
  },
  {
    "name": "Etherum",
    "code": "eth",
  },
  {
    "name": "Ripple",
    "code": "xrp",
  },
];

class Coin {
  final String code;
  final double price;
  final DateTime dateTime;

  Coin({
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
  CoinUpdates({this.name});
  final String name;

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

class AblyService {
  /// This field is going to be initialized with the clientOptions from
  /// your Ably API Key, if a key isn't provided, the realtime instance
  /// will not be initialized properly.
  ///
  /// It's used for every connection happening between the app and Ably's
  /// realtime services, such as:
  /// 1. Connect to Realtime Ably service
  /// 2. Read connection status
  /// 3. Creating new channels
  /// 4. Connecting with hubs
  final ably.Realtime _realtime;

  ably.RealtimeChannel _chatChannel;

  /// to get the connection status of the realtime instance
  /// The different connection statuses are:
  /// [initialized, connecting, connected]
  /// [disconnected, suspended, closing, closed, failed, update]
  /// It's necessary to check for the connection status and make sure
  /// the user knows what's happening in case of failure.
  Stream<ably.ConnectionStateChange> get connection =>
      _realtime.connection.on();

  /// This is private constructor, as this class should only be initialized
  /// through the init() method, on the service registration at startup.
  ///
  /// The service is registered using `get_it`, to make sure we get the same
  /// instance through out the life of the app, but can be done using other
  /// solutions such as provider.
  ///
  /// Please refer to main.dart to see how registration has been done.
  AblyService._(this._realtime);

  /// The method to be called in order to create AblyService instance.
  /// This service is only initialized with this method, and to make it's
  /// declared as static to make it accessible without making an instance
  /// of AblyService.
  static Future<AblyService> init() async {
    /// initialize client options for your Ably account using your private API key
    final ably.ClientOptions _clientOptions =
        ably.ClientOptions.fromKey(APIKey);

    /// initialize real-time object with the client options
    final _realtime = ably.Realtime(options: _clientOptions);

    /// connect the app to Ably's Realtime sevices supported by this SDK
    await _realtime.connect();

    /// reaturn the single instance of AblyService with the local _realtime instance to
    /// be set as the value of the service's _realtime property, so it can be used in
    /// all methods.
    return AblyService._(_realtime);
  }

  List<CoinUpdates> _coinUpdates = [];

  /// Start listening to cryptocurrency prices from Coindesk hub
  /// and return a list of `CoinUpdates` for each currency.
  /// As data is coming as a stream, we listen to the stream inside this
  /// service, and send a ChangeNotifier object to the UI, where it can
  /// recieve latest value from the `Stream` without subscribing to it, making
  /// the usage inside the UI easier.
  List<CoinUpdates> getCoinUpdates() {
    if (_coinUpdates.isEmpty) {
      for (int i = 0; i < _coinTypes.length; i++) {
        String coinName = _coinTypes[i]['name'];
        String coinCode = _coinTypes[i]['code'];

        _coinUpdates.add(CoinUpdates(name: coinName));

        //launch a channel for each coin type
        ably.RealtimeChannel channel = _realtime.channels
            .get('[product:ably-coindesk/crypto-pricing]$coinCode:usd');

        //subscribe to receive channel messages
        final Stream<ably.Message> messageStream = channel.subscribe();

        //map each stream event to a Coin inside a list of streams
        messageStream.where((event) => event.data != null).listen((message) {
          _coinUpdates[i].updateCoin(
            Coin(
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

  /// To get chat messages posted to the [public-chat] channel,
  /// first find (or create) the channel if no one else has created it yet.
  /// Secondly, subscribe to the channel. Finally, listen to any updates coming.
  /// This method is called one time when the chat page is opened, it doesn't
  /// read history (messages sent previously) so each time you leave and get
  /// back to chat page past messages will be lost.
  ChatUpdates getChatUpdates() {
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

  /// connect to the same chat channel to publish new messages.
  /// The name of the channel is important, if it wasn't the same one subscribed
  /// to in [getChatUpdates] we won't get the published messages.
  Future sendMessage(String content) async {
    _realtime.channels.get('public-chat');

    await _chatChannel.publish(data: content, name: "${_realtime.clientId}");
  }
}
