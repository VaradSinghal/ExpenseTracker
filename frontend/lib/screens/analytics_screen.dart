import 'package:flutter/material.dart';

class AnalyticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Analytics"),
        backgroundColor: Colors.greenAccent,
      ),
      body: Center(
        child: Text(
          "Analytics will be displayed here",
          style: TextStyle(fontSize: 18, color: Colors.white54),
        ),
      ),
    );
  }
}