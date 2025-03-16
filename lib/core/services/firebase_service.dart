import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/core/models/expense_model.dart';

class FirebaseService {
  final CollectionReference _expenses = FirebaseFirestore.instance.collection('expenses');

  Future<void> addExpense(Expense expense) async {
    await _expenses.doc(expense.id).set(expense.toJson());
  }

  Stream<List<Expense>> getExpenses() {
    return _expenses.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Expense.fromJson(doc.data() as Map<String, dynamic>)).toList());
  }
}
