import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'login_screen.dart'; // Import login screen
import 'add_expense_screen.dart'; // Import add expense screen
import 'analytics_screen.dart'; // Import analytics screen

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bankBalance = 0;
  bool _isLoading = true;
  bool _hasSetBankBalance = false;
  List<dynamic> _expenses = []; // List to store fetched expenses

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
    _fetchRecentExpenses(); // Fetch expenses for the current day
  }

  Future<void> _fetchUserInfo() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  if (token == null) {
    setState(() => _isLoading = false);
    return;
  }

  try {
    final response = await http.get(
      Uri.parse("http://192.168.1.47:8000/api/user/user-info"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      print("User info response: $data"); // Debugging print

      setState(() {
        _bankBalance = data["bankBalance"] ?? 0;
        _hasSetBankBalance = data["hasSetBankBalance"] ?? false;
        _isLoading = false;
      });

      // Ensure userId is properly stored
      if (data["userId"] != null) {
        await prefs.setString('userId', data["userId"].toString());
      } else {
        print("Error: userId is null");
      }

      if (!_hasSetBankBalance) {
        Future.delayed(Duration(milliseconds: 500), () => _setBankBalance());
      }
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch user info: ${response.statusCode}")),
      );
    }
  } catch (e) {
    setState(() => _isLoading = false);
    print("Error fetching user info: $e"); // Debugging
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error fetching user info: $e")),
    );
  }
}

  Future<void> _fetchRecentExpenses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      print(
        "Token is null. User is not logged in or token is missing.",
      ); // Debug print
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No token found, please log in again")),
      );
      return;
    }

    print("Token: $token"); // Debug print

    try {
      final response = await http.get(
        Uri.parse("http://192.168.1.47:8000/api/expenses/recent"),
        headers: {"Authorization": "Bearer $token"},
      );

      print("Response status code: ${response.statusCode}"); // Debug print
      print("Response body: ${response.body}"); // Debug print

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _expenses = data; // Update the expenses list
        });
      } else if (response.statusCode == 401) {
        // Handle token expiry
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Session expired, please log in again")),
        );
        _logout(); // Call the logout method
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to fetch expenses: ${response.statusCode}"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error fetching expenses: $e")));
    }
  }

  Future<void> _deleteExpense(String expenseId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No token found, please log in again")),
      );
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse("http://192.168.1.47:8000/api/expenses/$expenseId"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        setState(() {
          _expenses.removeWhere((expense) => expense["_id"] == expenseId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Expense deleted successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to delete expense: ${response.statusCode}"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error deleting expense: $e")));
    }
  }

  Future<void> _setBankBalance() async {
    final TextEditingController _balanceController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text("Set Bank Balance"),
          content: TextField(
            controller: _balanceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: "Enter your bank balance"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (!_hasSetBankBalance) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("You must set your bank balance!")),
                  );
                } else {
                  Navigator.pop(context);
                }
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                int? balance = int.tryParse(_balanceController.text);
                if (balance == null || balance < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Enter a valid non-negative number"),
                    ),
                  );
                  return;
                }

                SharedPreferences prefs = await SharedPreferences.getInstance();
                String? token = prefs.getString('token');

                if (token == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("No token found, please log in again"),
                    ),
                  );
                  Navigator.pop(context);
                  return;
                }

                try {
                  final response = await http.put(
                    Uri.parse(
                      "http://192.168.1.47:8000/api/user/set-bank-balance",
                    ),
                    headers: {
                      "Content-Type": "application/json",
                      "Authorization": "Bearer $token",
                    },
                    body: jsonEncode({"bankBalance": balance}),
                  );

                  if (response.statusCode == 200) {
                    final data = jsonDecode(response.body);
                    setState(() {
                      _bankBalance = data["bankBalance"] ?? balance;
                      _hasSetBankBalance = true;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Bank balance set successfully!")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Failed to set bank balance: ${response.statusCode} - ${response.body}",
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error setting bank balance: $e")),
                  );
                }
              },
              child: Text("Set"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Clear token
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E2C),
      appBar: AppBar(
        title: Text("Home"),
        backgroundColor: Colors.greenAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.analytics),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AnalyticsScreen()),
              );
            },
          ),
          IconButton(icon: Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Bank Balance: ₹$_bankBalance",
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _expenses.length,
                      itemBuilder: (context, index) {
                        final expense = _expenses[index];
                        return ListTile(
                          title: Text(
                            expense["title"],
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            "₹${expense["amount"]}",
                            style: TextStyle(color: Colors.white54),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteExpense(expense["_id"]),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddExpenseScreen()),
          ).then((_) {
            _fetchRecentExpenses();
            _fetchUserInfo();
          });
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.greenAccent,
      ),
    );
  }
}
