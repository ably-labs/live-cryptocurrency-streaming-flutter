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

  StreamController<Coin> _pricesStream = StreamController<Coin>();

  /// Listen to data from Coidesk hub
  Stream<Coin> listenToCoinsPrice() {
    ably.RealtimeChannel channel = _realtime.channels.get('[product:ably-coindesk/crypto-pricing]btc:usd');

    channel.on().listen((ably.ChannelStateChange stateChange) {
      print("Channel state changed: ${stateChange.current}");
    });
    var messageStream = channel.subscribe();

    Coin coinData = Coin(name: 'bitcoin', price: 0.0);
    
    messageStream.listen((ably.Message message) {
      if (message.data != null) {
        coinData = Coin(name: 'bitcoin', price: double.parse('${message.data}'));
      }

      _pricesStream.add(coinData);
    });
    return _pricesStream.stream;
  }
}

class Coin {
  final String name;
  final double price;
  Coin({
    this.name,
    this.price,
  });
}
