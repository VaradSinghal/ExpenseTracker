import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/firebase_service.dart';

class AddExpenseScreen extends StatefulWidget {
  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text('Add Expense'), backgroundColor: Colors.black),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title', filled: true, fillColor: Colors.grey[900]),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Amount', filled: true, fillColor: Colors.grey[900]),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: _isSaving ? null : () async {
                setState(() => _isSaving = true);
                try {
                  double amount = double.parse(_amountController.text);
                  String title = _titleController.text;

                  await Provider.of<FirebaseService>(context, listen: false).addExpense(title, amount);

               
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Expense Added!"), backgroundColor: Colors.green),
                  );

                 
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.red),
                  );
                }
                setState(() => _isSaving = false);
              },
              child: _isSaving ? CircularProgressIndicator() : Text('Save Expense'),
            ),
          ],
        ),
      ),
    );
  }
}
