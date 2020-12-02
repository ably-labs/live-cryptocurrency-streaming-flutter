import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DashboardView extends StatefulWidget {
  DashboardView({Key key}) : super(key: key);

  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
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
      body: ListView.builder(
        itemCount: 2,
        itemBuilder: (context, index) {
          return CoinGraphItem(
            coin: Coin(name: "bitcoin", price: 19362.5603),
          );
        },
      ),
    );
  }
}

class CoinGraphItem extends StatefulWidget {
  CoinGraphItem({Key key, this.coin}) : super(key: key);
  final Coin coin;
  @override
  _CoinGraphItemState createState() => _CoinGraphItemState();
}

class _CoinGraphItemState extends State<CoinGraphItem> {
  @override
  Widget build(BuildContext context) {
    List<DateTime> times = [
      DateTime.now(),
      DateTime.now().add(Duration(hours: 3)),
      DateTime.now().add(Duration(hours: 6)),
      DateTime.now().add(Duration(hours: 9)),
      DateTime.now().add(Duration(hours: 12))
    ];
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
                    "#${widget.coin.name}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              Text(
                "${widget.coin.price}",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ],
          ),
          SizedBox(height: 25),
          SfCartesianChart(
            // Initialize category axis
            primaryXAxis: DateTimeAxis(
              axisLine: AxisLine(width: 2, color: Colors.white),
              majorTickLines: MajorTickLines(color: Colors.transparent),
            ),
            primaryYAxis: NumericAxis(
              axisLine: AxisLine(width: 2, color: Colors.white),
              majorTickLines: MajorTickLines(color: Colors.transparent),
            ),
            plotAreaBorderColor: Colors.white.withOpacity(0.2),
            plotAreaBorderWidth: 0.2,

            series: <LineSeries<CoinPriceData, DateTime>>[
              LineSeries<CoinPriceData, DateTime>(
                markerSettings: MarkerSettings(
                  isVisible: true,
                  borderColor: Colors.white,
                  shape: DataMarkerType.circle,
                ),
                width: 3,
                color: Colors.white,
                dataSource: [
                  CoinPriceData(times[0], 1928238.5),
                  CoinPriceData(times[1], 1729938.5),
                  CoinPriceData(times[2], 1829938.5),
                  CoinPriceData(times[3], 1928138.5),
                  CoinPriceData(times[4], 1928138.5),
                ],
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

class Coin {
  final String name;
  final double price;
  Coin({
    this.name,
    this.price,
  });
}

class CoinPriceData {
  CoinPriceData(this.time, this.price);
  final DateTime time;
  final double price;
}
