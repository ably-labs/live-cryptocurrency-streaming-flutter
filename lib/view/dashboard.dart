import 'dart:collection';

import 'package:ably_cryptocurrency/service/ably_service.dart';
import 'package:ably_cryptocurrency/view/chat.dart';
import 'package:ably_cryptocurrency/view/twitter_feed.dart';
import 'package:ably_flutter_plugin/ably_flutter_plugin.dart' as ably;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DashboardView extends StatefulWidget {
  DashboardView({Key key}) : super(key: key);

  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final List<CoinUpdates> prices = [];

  /// open a page for live chatting
  void _navigateToChatRoom() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatView(),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ablyService = Provider.of<AblyService>(context, listen: false);
    if (ablyService != null && prices.isEmpty) {
      setState(() {
        prices.addAll(ablyService.getCoinUpdates());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ablyService = Provider.of<AblyService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Ably"),
        actions: [
          IconButton(
            icon: Icon(Icons.chat_bubble),
            onPressed: _navigateToChatRoom,
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
      body: ablyService == null
          ? SizedBox()
          : Center(
              child: StreamProvider<ably.ConnectionStateChange>.value(
                value: ablyService.connection,
                child: Consumer<ably.ConnectionStateChange>(
                  builder: (context, connection, child) {
                    if (connection != null && connection.event == ably.ConnectionEvent.connected) {
                      return child;
                    } else
                      return CircularProgressIndicator();
                  },
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          for (CoinUpdates update in prices) CoinGraphItem(coinUpdates: update),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
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
  ChartSeriesController _chartSeriesController;

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
        builder: (_) => TwitterFeedView(hashtag: hashtag.toLowerCase()),
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
                      // onRendererCreated: (ChartSeriesController controller) {
                      //   _chartSeriesController = controller;
                      // },
                    )
                  ],
                )
              ],
            ),
    );
  }
}
