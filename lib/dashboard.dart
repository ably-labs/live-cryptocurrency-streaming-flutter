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
  Map<DateTime, Coin> coinsData = {};
  
  @override
  Widget build(BuildContext context) {
    final ablyService = Provider.of<AblyService>(context);

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
        itemCount: 1,
        itemBuilder: (context, index) {
          return StreamBuilder<Coin>(
            stream: ablyService.listenToCoinsPrice(),
            builder: (context, snapshot) {
              print(snapshot.data);
              if (snapshot.connectionState == ConnectionState.waiting) return Center();
              if (snapshot.hasData) {
                Coin coin = snapshot.data;
                coinsData.addAll({DateTime.now(): coin});
                return CoinGraphItem(list: coinsData);
              }

              return Center();
            },
          );
        },
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
          if(widget.list.length < 20)
          CircularProgressIndicator(),
          if(widget.list.length > 20)
          SfCartesianChart(
            // Initialize category axis
            enableAxisAnimation: false,
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
                dataSource:
                    widget.list.keys.map((dateTime) => CoinPriceData(dateTime, widget.list[dateTime].price)).toList().getRange(widget.list.length - 20, widget.list.length).toList(),
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
