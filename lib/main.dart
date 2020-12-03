import 'package:ably_cryptocurrency/ably_service.dart';
import 'package:flutter/material.dart';
import 'package:ably_cryptocurrency/dashboard.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    FutureProvider<AblyService>(
      create: (_) => AblyService.init(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Color(0xffFF5416),
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
    );
  }
}
