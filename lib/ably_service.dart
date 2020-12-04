import 'dart:async';

import 'package:ably_cryptocurrency/config.dart';
import 'package:ably_flutter_plugin/ably_flutter_plugin.dart' as ably;

class AblyService {
  /// initialize client options for your Ably account
  final ably.ClientOptions _clientOptions;
  final ably.Realtime _realtime;

  /// private constructor
  AblyService._(this._realtime, this._clientOptions);

  static Future<AblyService> init() async {
    final ably.ClientOptions _clientOptions = ably.ClientOptions.fromKey(APIKey);

    /// this line is optional, but usseful to have more detailed logs
    _clientOptions.logLevel = ably.LogLevel.verbose;

    /// initialize real time object
    final _realtime = ably.Realtime(options: _clientOptions);

    await _realtime.connect();

    _realtime.connection.on().listen((ably.ConnectionStateChange stateChange) async {
      print('Realtime connection state changed: ${stateChange.event}');
    });

    return AblyService._(_realtime, _clientOptions);
  }

  static const List<CoinType> _coinTypes = [
    CoinType.btc,
    CoinType.eth,
    CoinType.xrp,
  ];

  /// Listen to data from Coindesk hub
  Map<String, Stream<Coin>> listenToCoinsPrice() {
    Map<String, Stream<Coin>> _streams = {};
    for (CoinType coinType in _coinTypes) {
      //launch a channel for each coin type

      ably.RealtimeChannel channel =
          _realtime.channels.get('[product:ably-coindesk/crypto-pricing]${coinType.code}:usd');
      //subscribe to receive channel messages
      final messageStream = channel.subscribe();

      //map each stream event to a Coin
      _streams.addAll({
        '${coinType.code}': messageStream.map((message) {
          print(message.data);
          if (message.data != null)
            return Coin(
              name: coinType.name,
              code: coinType.code,
              price: double.parse('${message.data}'),
              dateTime: DateTime.now(),
            );
        }),
      });
    }

    return _streams;
  }
}

enum CoinType {
  btc,
  eth,
  xrp,
}

extension CointTypeExtension on CoinType {
  String get name {
    switch (this) {
      case CoinType.btc:
        return 'Bitcoin';
        break;
      case CoinType.eth:
        return 'Ethurum';
        break;
      case CoinType.xrp:
        return 'Ripple';
        break;
    }
  }

  String get code {
    switch (this) {
      case CoinType.btc:
        return 'btc';
        break;
      case CoinType.eth:
        return 'eth';
        break;
      case CoinType.xrp:
        return 'xrp';
        break;
    }
  }
}

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
