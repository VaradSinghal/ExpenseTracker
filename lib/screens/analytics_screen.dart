import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/services/firebase_service.dart';

class AnalyticsScreen extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Expense Analytics")),
      body: StreamBuilder(
        stream: _firebaseService.getExpenses(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          double totalAmount = snapshot.data!.docs.fold(
            0.0,
            (sum, doc) => sum + (doc['amount'] as num).toDouble(),
          );

          return Center(
            child: Text(
              "Total Expenses: ₹${totalAmount.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }
}
