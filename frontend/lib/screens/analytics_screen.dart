import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AnalyticsScreen extends StatefulWidget {
  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  List<Map<String, dynamic>> _last7DaysExpenses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLast7DaysExpenses();
  }

 Future<void> _fetchLast7DaysExpenses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("No token found, please log in again")),
        );
        return;
    }

    try {
        final response = await http.get(
            Uri.parse("http://192.168.1.47:8000/api/expenses/last7days"),
            headers: {"Authorization": "Bearer $token"},
        );

        if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            setState(() {
                _last7DaysExpenses = List<Map<String, dynamic>>.from(data);
                _isLoading = false;
            });
        } else if (response.statusCode == 401) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Session expired, please log in again")),
            );
        } else {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Failed to fetch expenses: ${response.statusCode}")),
            );
        }
    } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error fetching expenses: $e")),
        );
    }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E2C),
      appBar: AppBar(
        title: Text("Expense Analytics"),
        backgroundColor: Colors.greenAccent,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    "Last 7 Days Expenses",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        barGroups: _getBarGroups(),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final date = DateTime.now().subtract(Duration(days: 6 - value.toInt()));
                                return Text(
                                  "${date.day}/${date.month}",
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                );
                              },
                            ),
                          ),
                        ),
                        gridData: FlGridData(show: false),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  List<BarChartGroupData> _getBarGroups() {
    return List.generate(_last7DaysExpenses.length, (index) {
      final expense = _last7DaysExpenses[index];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: expense["totalAmount"].toDouble(),
            color: Colors.greenAccent,
            width: 16,
          ),
        ],
      );
    });
  }
}