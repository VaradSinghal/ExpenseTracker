import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'login_screen.dart';
import 'add_expense_screen.dart';
import 'analytics_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bankBalance = 0;
  bool _isLoading = true;
  bool _hasSetBankBalance = false;
  List<dynamic> _expenses = [];

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
    _fetchRecentExpenses();
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

        setState(() {
          _bankBalance = data["bankBalance"] ?? 0;
          _hasSetBankBalance = data["hasSetBankBalance"] ?? false;
          _isLoading = false;
        });

        if (data["userId"] != null) {
          await prefs.setString('userId', data["userId"].toString());
        }

        if (!_hasSetBankBalance) {
          Future.delayed(Duration(milliseconds: 500), () => _setBankBalance());
        }
      } else {
        setState(() => _isLoading = false);
        _showSnackBar("Failed to fetch user info: ${response.statusCode}", isError: true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar("Error fetching user info: $e", isError: true);
    }
  }

  Future<void> _fetchRecentExpenses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      _showSnackBar("No token found, please log in again", isError: true);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("http://192.168.1.47:8000/api/expenses/recent"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _expenses = data;
        });
      } else if (response.statusCode == 401) {
        _showSnackBar("Session expired, please log in again", isError: true);
        _logout();
      } else {
        _showSnackBar("Failed to fetch expenses: ${response.statusCode}", isError: true);
      }
    } catch (e) {
      _showSnackBar("Error fetching expenses: $e", isError: true);
    }
  }

  Future<void> _deleteExpense(String expenseId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      _showSnackBar("No token found, please log in again", isError: true);
      return;
    }

    try {
      final expense = _expenses.firstWhere((expense) => expense["_id"] == expenseId);
      final int deletedAmount = expense["amount"];

      final response = await http.delete(
        Uri.parse("http://192.168.1.47:8000/api/expenses/$expenseId"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        setState(() {
          _expenses.removeWhere((expense) => expense["_id"] == expenseId);
          _bankBalance += deletedAmount;
        });

        final updateResponse = await http.put(
          Uri.parse("http://192.168.1.47:8000/api/user/set-bank-balance"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode({"bankBalance": _bankBalance}),
        );

        if (updateResponse.statusCode == 200) {
          _showSnackBar("Expense deleted and balance updated!");
        } else {
          _showSnackBar("Expense deleted but failed to update balance: ${updateResponse.statusCode}", isError: true);
        }
      } else {
        _showSnackBar("Failed to delete expense: ${response.statusCode}", isError: true);
      }
    } catch (e) {
      _showSnackBar("Error deleting expense: $e", isError: true);
    }
  }

  Future<void> _setBankBalance() async {
    final TextEditingController _balanceController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildDialog("Set Bank Balance", _balanceController, true),
    );
  }

  Future<void> _updateBankBalance() async {
    final TextEditingController _balanceController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildDialog("Update Bank Balance", _balanceController, false),
    );
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  // Custom SnackBar method
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.redAccent : Colors.greenAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(10),
        duration: Duration(seconds: 3),
      ),
    );
  }

  // Custom Dialog widget
  Widget _buildDialog(String title, TextEditingController controller, bool isInitialSet) {
    return AlertDialog(
      backgroundColor: Color(0xFF2A2A3E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          filled: true,
          fillColor: Color(0xFF1A1A2E),
          hintText: "Enter bank balance",
          hintStyle: TextStyle(color: Colors.white54),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(Icons.currency_rupee, color: Colors.greenAccent),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (isInitialSet && !_hasSetBankBalance) {
              _showSnackBar("You must set your bank balance!", isError: true);
            } else {
              Navigator.pop(context);
            }
          },
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            int? balance = int.tryParse(controller.text);
            if (balance == null || balance < 0) {
              _showSnackBar("Enter a valid non-negative number", isError: true);
              return;
            }

            SharedPreferences prefs = await SharedPreferences.getInstance();
            String? token = prefs.getString('token');

            if (token == null) {
              _showSnackBar("No token found, please log in again", isError: true);
              Navigator.pop(context);
              return;
            }

            try {
              final response = await http.put(
                Uri.parse("http://192.168.1.47:8000/api/user/set-bank-balance"),
                headers: {
                  "Content-Type": "application/json",
                  "Authorization": "Bearer $token",
                },
                body: jsonEncode({"bankBalance": balance}),
              );

              if (response.statusCode == 200) {
                setState(() {
                  _bankBalance = balance;
                  if (isInitialSet) _hasSetBankBalance = true;
                });
                Navigator.pop(context);
                _showSnackBar(isInitialSet ? "Bank balance set successfully!" : "Bank balance updated successfully!");
              } else {
                _showSnackBar("Failed to update balance: ${response.statusCode}", isError: true);
              }
            } catch (e) {
              _showSnackBar("Error updating balance: $e", isError: true);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.greenAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(
            isInitialSet ? "Set" : "Update",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Expense Tracker",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.bar_chart, color: Colors.white70),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AnalyticsScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.account_balance_wallet_outlined, color: Colors.white70),
            onPressed: _updateBankBalance,
          ),
          IconButton(
            icon: Icon(Icons.logout_rounded, color: Colors.white70),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.greenAccent))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.greenAccent, Colors.tealAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Bank Balance",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "₹$_bankBalance",
                          style: TextStyle(
                            fontSize: 36,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    "Recent Expenses",
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: _expenses.isEmpty
                        ? Center(
                            child: Text(
                              "No expenses yet!",
                              style: TextStyle(fontSize: 18, color: Colors.white54),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _expenses.length,
                            itemBuilder: (context, index) {
                              final expense = _expenses[index];
                              return Dismissible(
                                key: Key(expense["_id"]),
                                direction: DismissDirection.endToStart,
                                onDismissed: (direction) {
                                  _deleteExpense(expense["_id"]);
                                },
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.only(right: 20),
                                  color: Colors.redAccent,
                                  child: Icon(Icons.delete, color: Colors.white),
                                ),
                                child: Card(
                                  color: Color(0xFF2A2A3E),
                                  elevation: 2,
                                  margin: EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.greenAccent.withOpacity(0.2),
                                      child: Icon(Icons.money_off, color: Colors.greenAccent),
                                    ),
                                    title: Text(
                                      expense["title"],
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "₹${expense["amount"]}",
                                      style: TextStyle(fontSize: 16, color: Colors.white54),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.delete_outline, color: Colors.redAccent),
                                      onPressed: () => _deleteExpense(expense["_id"]),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
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
        backgroundColor: Colors.greenAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Icon(Icons.add, size: 30),
      ),
    );
  }
}