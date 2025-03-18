import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/firebase_service.dart';
import '../core/services/auth_service.dart';
import 'add_expense_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late FirebaseService firebaseService;
  late AuthService authService;

  @override
  void initState() {
    super.initState();
    firebaseService = Provider.of<FirebaseService>(context, listen: false);
    authService = Provider.of<AuthService>(context, listen: false);
  }

  void _logout() async {
    await authService.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  void _navigateToAddExpense() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddExpenseScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E2C),
      appBar: AppBar(
        title: Text("Expense Tracker"),
        backgroundColor: Color(0xFF1E1E2C),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 20),

          /// **Bank Balance Display**
          FutureBuilder<int>(
            future: firebaseService.getBankBalance(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text(
                  "Error loading balance",
                  style: TextStyle(color: Colors.red),
                );
              }

              int bankBalance = snapshot.data ?? 0;
              return Card(
                color: Color(0xFF2A2A3A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Column(
                    children: [
                      Text(
                        "Bank Balance",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "₹$bankBalance",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.greenAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 20),

          /// **Recent Expenses List (Real-Time Updates)**
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: firebaseService.getRecentExpensesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error loading expenses",
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }

                var expenses = snapshot.data ?? [];

                if (expenses.isEmpty) {
                  return Center(
                    child: Text(
                      "No expenses yet!",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    var expense = expenses[index];
                    return Card(
                      color: Color(0xFF2A2A3A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      child: ListTile(
                        title: Text(
                          expense['title'],
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          "₹${expense['amount']}",
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
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
        onPressed: _navigateToAddExpense,
      ),
    );
  }
}
