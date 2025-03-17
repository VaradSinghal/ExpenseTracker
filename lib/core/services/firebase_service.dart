import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final CollectionReference expensesCollection =
      FirebaseFirestore.instance.collection('expenses');

  /// 🔹 Add Expense
  Future<void> addExpense(String title, double amount) async {
    await expensesCollection.add({
      'title': title,
      'amount': amount,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// 🔹 Update Expense
  Future<void> updateExpense(String docId, String title, double amount) async {
    await expensesCollection.doc(docId).update({
      'title': title,
      'amount': amount,
    });
  }

  /// 🔹 Delete Expense
  Future<void> deleteExpense(String docId) async {
    await expensesCollection.doc(docId).delete();
  }

  /// 🔹 Get Expenses Stream
  Stream<QuerySnapshot> getExpenses() {
    return expensesCollection.orderBy('timestamp', descending: true).snapshots();
  }
}
