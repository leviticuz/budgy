import 'package:Budgy/list.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CustomUIPage(),  // Use the UITemplate widget directly
    );
  }
}