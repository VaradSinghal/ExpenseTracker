import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/firebase_service.dart';
import 'add_expense_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text("Expense Tracker"), backgroundColor: Colors.black),
      body: Column(
        children: [
          SizedBox(height: 20),

          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(Provider.of<FirebaseService>(context, listen: false).userId).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return CircularProgressIndicator();

              double bankBalance = snapshot.data!.get('bankBalance') ?? 0;
              return Text("Bank Balance: ₹$bankBalance",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white));
            },
          ),

          SizedBox(height: 20),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('expenses')
                  .where('userId', isEqualTo: Provider.of<FirebaseService>(context, listen: false).userId)
                  .orderBy('date', descending: true)
                  .limit(10)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                
                var expenses = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    var expense = expenses[index];
                    return ListTile(
                      title: Text(expense['title'], style: TextStyle(color: Colors.white)),
                      subtitle: Text("₹${expense['amount']}", style: TextStyle(color: Colors.redAccent)),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AddExpenseScreen()));
        },
      ),
    );
  }
}
