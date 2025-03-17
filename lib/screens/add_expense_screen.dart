import 'package:flutter/material.dart';
import '../core/services/firebase_service.dart';

class AddExpenseScreen extends StatefulWidget {
  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();

  void _submitExpense() {
    final title = _titleController.text;
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    if (title.isNotEmpty && amount > 0) {
      _firebaseService.addExpense(title, amount);
      Navigator.pop(context); // Close screen after adding
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Expense")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: "Expense Title"),
            ),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Amount"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitExpense,
              child: Text("Add Expense"),
            ),
          ],
        ),
      ),
    );
  }
}
