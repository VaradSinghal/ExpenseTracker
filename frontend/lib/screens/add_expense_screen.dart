// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../core/services/firebase_service.dart';

// class AddExpenseScreen extends StatefulWidget {
//   @override
//   _AddExpenseScreenState createState() => _AddExpenseScreenState();
// }

// class _AddExpenseScreenState extends State<AddExpenseScreen> {
//   final TextEditingController _titleController = TextEditingController();
//   final TextEditingController _amountController = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   bool _isSaving = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         title: Text('Add Expense'),
//         backgroundColor: Colors.black,
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           autovalidateMode: AutovalidateMode.onUserInteraction, // Real-time validation
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               /// **Title Input Field**
//               TextFormField(
//                 controller: _titleController,
//                 decoration: InputDecoration(
//                   labelText: 'Title',
//                   filled: true,
//                   fillColor: Colors.grey[900],
//                   border: OutlineInputBorder(),
//                   labelStyle: TextStyle(color: Colors.white),
//                 ),
//                 style: TextStyle(color: Colors.white),
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) return 'Enter a title';
//                   return null;
//                 },
//               ),
//               SizedBox(height: 10),

//               /// **Amount Input Field**
//               TextFormField(
//                 controller: _amountController,
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(
//                   labelText: 'Amount',
//                   filled: true,
//                   fillColor: Colors.grey[900],
//                   border: OutlineInputBorder(),
//                   labelStyle: TextStyle(color: Colors.white),
//                 ),
//                 style: TextStyle(color: Colors.white),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) return 'Enter an amount';
//                   final int? amount = int.tryParse(value);
//                   if (amount == null || amount <= 0) return 'Enter a valid amount';
//                   return null;
//                 },
//               ),
//               SizedBox(height: 20),

//               /// **Save Expense Button**
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.redAccent,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   onPressed: _isSaving ? null : _saveExpense, // Disable button when saving
//                   child: _isSaving
//                       ? CircularProgressIndicator(color: Colors.white) // Loading indicator
//                       : Text('Save Expense', style: TextStyle(fontSize: 16)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   /// **Save Expense Function**
//   Future<void> _saveExpense() async {
//     if (!_formKey.currentState!.validate()) return; // Validate form before saving

//     setState(() => _isSaving = true);

//     try {
//       int amount = int.parse(_amountController.text.trim()); // Parse amount
//       String title = _titleController.text.trim();

//       // Add expense using FirebaseService
//       await Provider.of<FirebaseService>(context, listen: false).addExpense(title, amount);

//       // Show success message
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("✅ Expense Added!", style: TextStyle(color: Colors.white)),
//           backgroundColor: Colors.green,
//         ),
//       );

//       // Navigate back to the previous screen
//       Navigator.pop(context);
//     } catch (e) {
//       // Show error message
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("❌ Error: ${e.toString()}", style: TextStyle(color: Colors.white)),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() => _isSaving = false); // Reset saving state
//     }
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _amountController.dispose();
//     super.dispose();
//   }
// }