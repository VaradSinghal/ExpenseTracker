import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bankBalance = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBankBalance();
  }

  Future<void> _fetchBankBalance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      setState(() => _isLoading = false);
      return;
    }

    final response = await http.get(
      Uri.parse("http://10.9.76.13:8000/api/user/get-bank-balance"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _bankBalance = data["bankBalance"] ?? 0;
        _isLoading = false;
      });

      // If balance is 0, prompt user to set it
      if (_bankBalance == 0) {
        Future.delayed(Duration(milliseconds: 500), () => _setBankBalance());
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _setBankBalance() async {
    final TextEditingController _balanceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Set Initial Bank Balance"),
          content: TextField(
            controller: _balanceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: "Enter your bank balance"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                int? balance = int.tryParse(_balanceController.text);
                if (balance == null || balance < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Enter a valid balance")),
                  );
                  return;
                }

                SharedPreferences prefs = await SharedPreferences.getInstance();
                String? token = prefs.getString('token');

                final response = await http.put(
                  Uri.parse("http://localhost:8000/api/user/set-bank-balance"),
                  headers: {
                    "Content-Type": "application/json",
                    "Authorization": "Bearer $token"
                  },
                  body: jsonEncode({"bankBalance": balance}),
                );

                if (response.statusCode == 200) {
                  setState(() {
                    _bankBalance = balance;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Bank balance set successfully!")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to set bank balance")),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E2C),
      appBar: AppBar(
        title: Text("Home"),
        backgroundColor: Colors.greenAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.account_balance_wallet),
            onPressed: _setBankBalance, // Allow user to update balance
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
                      "Set/Update Bank Balance",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
