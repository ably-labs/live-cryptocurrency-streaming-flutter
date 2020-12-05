import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:ably_cryptocurrency/service/ably_service.dart';
import 'package:ably_cryptocurrency/view/dashboard.dart';

void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //initialize AblyService for the whole app
    return FutureProvider<AblyService>(
      create: (_) => AblyService.init(),
      child: MaterialApp(
        title: 'Ably',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Color(0xffFF5416),
          accentColor: Color(0xffFF5416),
          scaffoldBackgroundColor: Color(0xff292831),
          appBarTheme: AppBarTheme(
            elevation: 0.0,
          ),
          textTheme: TextTheme(
            bodyText1: TextStyle(color: Colors.white),
            bodyText2: TextStyle(color: Colors.white),
          ),
        ),
        home: DashboardView(),
      ),
    );
  }
}
