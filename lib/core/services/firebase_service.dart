import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get userId => _auth.currentUser?.uid ?? "";

  DocumentReference get _bankBalanceDoc => _firestore.collection('users').doc(userId);
  CollectionReference get _expensesCollection => _firestore.collection('expenses');

  Stream<DocumentSnapshot> get bankBalanceStream {
    return _bankBalanceDoc.snapshots();
  }

  Future<double> getBankBalance() async {
    DocumentSnapshot doc = await _bankBalanceDoc.get();
    if (doc.exists && doc.data() != null) {
      return (doc['bankBalance'] as num).toDouble();
    } else {
      await _bankBalanceDoc.set({'bankBalance': 0.0});
      return 0.0;
    }
  }

  Future<void> updateBankBalance(double newBalance) async {
    await _bankBalanceDoc.set({'bankBalance': newBalance}, SetOptions(merge: true));
  }

  Future<void> addExpense(String title, double amount) async {
    double currentBalance = await getBankBalance();
    double newBalance = currentBalance - amount;

    if (newBalance < 0) {
      throw Exception("Insufficient Balance!");
    }

    await _expensesCollection.add({
      'title': title,
      'amount': amount,
      'userId': userId,
      'date': Timestamp.now(),
    });

    await updateBankBalance(newBalance);
  }

  Stream<QuerySnapshot> get recentExpensesStream {
    return _expensesCollection
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .limit(10)
        .snapshots();
  }

  Stream<QuerySnapshot> get last7DaysExpensesStream {
    DateTime sevenDaysAgo = DateTime.now().subtract(Duration(days: 7));
    return _expensesCollection
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThan: Timestamp.fromDate(sevenDaysAgo))
        .orderBy('date', descending: true)
        .snapshots();
  }
}
