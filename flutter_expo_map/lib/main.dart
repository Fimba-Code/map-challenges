import 'package:flutter/material.dart';
import 'package:flutter_expo_map/src/ui/home_page/home_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final Key _mapKey = UniqueKey();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Expo Maps',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(key: _mapKey,),
    );
  }
}
