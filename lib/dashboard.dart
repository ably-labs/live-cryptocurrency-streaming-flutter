import 'package:ably_cryptocurrency/ably_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DashboardView extends StatefulWidget {
  DashboardView({Key key}) : super(key: key);

  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  Map<DateTime, Coin> btc = {};
  Map<DateTime, Coin> xrp = {};
  Map<DateTime, Coin> eth = {};

  List<String> coinTypes = ['btc', 'xrp', 'eth'];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ablyService = Provider.of<AblyService>(context);
    if (ablyService != null) {
      ablyService.listenToStream(coinTypes);

      ablyService.btcStream.onData((data) {
        print("${data.name}: ${data.price}");
        setState(() {
          btc.addAll({DateTime.now(): data});
        });
      });

      ablyService.xrpStream.onData((data) {
        print("${data.name}: ${data.price}");
        setState(() {
          xrp.addAll({DateTime.now(): data});
        });
      });

      ablyService.ethStream.onData((data) {
        print("${data.name}: ${data.price}");
        setState(() {
          eth.addAll({DateTime.now(): data});
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ably"),
        actions: [
          IconButton(
            icon: Icon(Icons.chat_bubble),
            onPressed: () {},
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
      body: ListView(
        children: [
          if (btc.length > 10) CoinGraphItem(list: btc),
          if (xrp.length > 10) CoinGraphItem(list: xrp),
          if (xrp.length > 10) CoinGraphItem(list: eth),
        ],
      ),
    );
  }
}

class CoinGraphItem extends StatefulWidget {
  CoinGraphItem({Key key, this.list}) : super(key: key);
  final Map<DateTime, Coin> list;
  @override
  _CoinGraphItemState createState() => _CoinGraphItemState();
}

class _CoinGraphItemState extends State<CoinGraphItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(30),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(color: Color(0xffEDEDED).withOpacity(0.05), borderRadius: BorderRadius.circular(8.0)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/icon_awesome_twitter.png',
                    height: 20,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "#${widget.list.values.last.name}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              Text(
                "${widget.list.values.last.price}",
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
              intervalType: DateTimeIntervalType.minutes,
              desiredIntervals: 10,
              visibleMinimum: DateTime.now().subtract(Duration(minutes: 2)),
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

            series: <LineSeries<CoinPriceData, DateTime>>[
              LineSeries<CoinPriceData, DateTime>(
                width: 3,
                color: Colors.white,
                dataSource:
                    widget.list.keys.map((dateTime) => CoinPriceData(dateTime, widget.list[dateTime].price)).toList(),
                xValueMapper: (CoinPriceData prices, _) => prices.time,
                yValueMapper: (CoinPriceData prices, _) => prices.price,
              )
            ],
          )
        ],
      ),
    );
  }
}

class CoinPriceData {
  CoinPriceData(this.time, this.price);
  final DateTime time;
  final double price;
}
