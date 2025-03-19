import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'login_screen.dart'; // Import your login screen

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bankBalance = 0;
  bool _isLoading = true;
  bool _hasSetBankBalance = false;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching user info: $e")),
      );
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
                    SnackBar(content: Text("Enter a valid non-negative number")),
                  );
                  return;
                }

                SharedPreferences prefs = await SharedPreferences.getInstance();
                String? token = prefs.getString('token');

                if (token == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("No token found, please log in again")),
                  );
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
      MaterialPageRoute(builder: (context) => LoginScreen()), // Redirect to login
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
          if (_hasSetBankBalance)
            IconButton(
              icon: Icon(Icons.account_balance_wallet),
              onPressed: _setBankBalance,
            ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Bank Balance: ₹$_bankBalance",
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                    ),
                    onPressed: _setBankBalance,
                    child: Text(
                      _hasSetBankBalance ? "Update Bank Balance" : "Set Bank Balance",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    onPressed: _logout,
                    child: Text(
                      "Logout",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}