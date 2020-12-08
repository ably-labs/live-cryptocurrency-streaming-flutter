import 'dart:collection';
import 'package:ably_cryptocurrency/main.dart';
import 'package:flutter/material.dart';

import 'package:ably_flutter_plugin/ably_flutter_plugin.dart' as ably;
import 'package:intl/intl.dart' as intl;
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:ably_cryptocurrency/service/ably_service.dart';
import 'package:ably_cryptocurrency/view/chat.dart';
import 'package:ably_cryptocurrency/view/twitter_feed.dart';

class DashboardView extends StatelessWidget {
  DashboardView({Key key}) : super(key: key);

  /// open a page for live chatting
  void _navigateToChatRoom(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ably"),
        actions: [
          IconButton(
            icon: Icon(Icons.chat_bubble),
            onPressed: () => _navigateToChatRoom(context),
          )
        ],
        bottom: PreferredSize(
          child: Container(
            color: Colors.white,
            height: 1.0,
          ),
          preferredSize: Size.fromHeight(1.0),
        ),
      ),
      body: GraphsList(),
    );
  }
}

class GraphsList extends StatefulWidget {
  const GraphsList({
    Key key,
  }) : super(key: key);

  @override
  _GraphsListState createState() => _GraphsListState();
}

class _GraphsListState extends State<GraphsList> {
  final List<CoinUpdates> prices = [];
  AblyService ablyService;

  @override
  void initState() {
    getCoinPrices();
    super.initState();
  }

  Future getCoinPrices() async {
    ablyService = getIt.get<AblyService>();

    if (ablyService != null && prices.isEmpty) {
      if (mounted)
        setState(() {
          prices.addAll(ablyService.getCoinUpdates());
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getIt.allReady(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          else
            return Center(
              child: StreamBuilder<ably.ConnectionStateChange>(
                stream: ablyService.connection,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data.event == ably.ConnectionEvent.connected) {
                    return Align(
                      alignment: Alignment.topCenter,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            for (CoinUpdates update in prices) CoinGraphItem(coinUpdates: update),
                          ],
                        ),
                      ),
                    );
                  } else if (snapshot.data.event == ably.ConnectionEvent.failed) {
                    return Center(child: Text("No connection."));
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
            );
        });
  }
}

class CoinGraphItem extends StatefulWidget {
  CoinGraphItem({Key key, this.coinUpdates}) : super(key: key);
  final CoinUpdates coinUpdates;
  @override
  _CoinGraphItemState createState() => _CoinGraphItemState();
}

class _CoinGraphItemState extends State<CoinGraphItem> {
  Queue<Coin> queue = Queue();
  VoidCallback _listener;

  @override
  void initState() {
    widget.coinUpdates.addListener(
      _listener = () {
        setState(() {
          queue.add(widget.coinUpdates.coin);
        });

        if (queue.length > 100) {
          queue.removeFirst();
        }
      },
    );

    super.initState();
  }

  @override
  void dispose() {
    widget.coinUpdates.removeListener(_listener);
    super.dispose();
  }

  /// open a page that shows a list of tweets with the cryptocurrency tag
  void _navigateToTwitterFeed(String hashtag) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TwitterFeedView(
          hashtag: hashtag.toLowerCase(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(30),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(color: Color(0xffEDEDED).withOpacity(0.05), borderRadius: BorderRadius.circular(8.0)),
      child: queue.isEmpty
          ? Center()
          : Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FlatButton(
                      onPressed: () => _navigateToTwitterFeed(queue.last.name),
                      textColor: Colors.white,
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/icon_awesome_twitter.png',
                            height: 20,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "#${widget.coinUpdates.coin.name}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "${widget.coinUpdates.coin.price}",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 25),
                SfCartesianChart(
                  enableAxisAnimation: true,
                  primaryXAxis: DateTimeAxis(
                    dateFormat: intl.DateFormat.Hms(),
                    intervalType: DateTimeIntervalType.minutes,
                    desiredIntervals: 10,
                    axisLine: AxisLine(width: 2, color: Colors.white),
                    majorTickLines: MajorTickLines(color: Colors.transparent),
                  ),
                  primaryYAxis: NumericAxis(
                    desiredIntervals: 6,
                    decimalPlaces: 4,
                    axisLine: AxisLine(width: 2, color: Colors.white),
                    majorTickLines: MajorTickLines(color: Colors.transparent),
                  ),
                  plotAreaBorderColor: Colors.white.withOpacity(0.2),
                  plotAreaBorderWidth: 0.2,
                  series: <LineSeries<Coin, DateTime>>[
                    LineSeries<Coin, DateTime>(
                      animationDuration: 0.0,
                      width: 2,
                      color: Theme.of(context).primaryColor,
                      dataSource: queue.toList(),
                      xValueMapper: (Coin coin, _) => coin.dateTime,
                      yValueMapper: (Coin coin, _) => coin.price,
                    )
                  ],
                )
              ],
            ),
    );
  }
}
