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

  StreamController<Coin> pricesStream = StreamController<Coin>.broadcast();

  Stream<Coin> get _bStream => pricesStream.stream;

  StreamSubscription<Coin> get btcStream => _bStream.where((event) => event.name == 'btc').listen((event) {
        return event;
      });
  StreamSubscription<Coin> get xrpStream => _bStream.where((event) => event.name == 'xrp').listen((event) {
        return event;
      });
  StreamSubscription<Coin> get ethStream => _bStream.where((event) => event.name == 'eth').listen((event) {
        return event;
      });

  void listenToStream(List<String> coinTypes) {
    for (String type in coinTypes) {
      _listenToCoinsPrice(type);
    }
  }

  /// Listen to data from Coidesk hub
  void _listenToCoinsPrice(String coinType) async {
    ably.RealtimeChannel channel = _realtime.channels.get('[product:ably-coindesk/crypto-pricing]$coinType:usd');

    var messageStream = channel.subscribe();

    Coin coinData = Coin(name: '', price: 0.0);

    messageStream.listen((ably.Message message) {
      if (message.data != null) {
        coinData = Coin(name: coinType, price: double.parse('${message.data}'));
      }
      pricesStream.add(coinData);
    });
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
