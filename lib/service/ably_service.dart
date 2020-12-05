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
        '$coinType': messageStream.map((message) {
          if (message.data != null)
            return Coin(
              name: _coinTypes[coinType],
              code: coinType,
              price: double.parse('${message.data}'),
              dateTime: DateTime.now(),
            );
        }),
      });
    }

    return _streams;
  }
}
