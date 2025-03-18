import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String get userId => _auth.currentUser?.uid ?? '';

  // Initialize a new user with email and default bank balance
  Future<void> initializeUser(String email) async {
    if (userId.isEmpty) return;

    DocumentReference userRef = _firestore.collection('users').doc(userId);
    DocumentSnapshot userSnapshot = await userRef.get();

    if (!userSnapshot.exists) {
      await userRef.set({
        'email': email,
        'bankBalance': 1000, // Default balance
      });
    }
  }

  /// Fetch bank balance from Firestore
  Future<int> getBankBalance() async {
    if (userId.isEmpty) throw Exception("User not logged in");

    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return doc.data()?['bankBalance'] ?? 0; // Fetch 'bankBalance' field
    } else {
      throw Exception("User document not found");
    }
  }

  // Update bank balance
  Future<void> updateBankBalance(int newBalance) async {
    if (userId.isEmpty) return;

    await _firestore.collection('users').doc(userId).update({
      'bankBalance': newBalance,
    });
  }

  // Add an expense
  Future<void> addExpense(String title, int amount) async {
    if (userId.isEmpty) return;

    CollectionReference expensesRef =
        _firestore.collection('users').doc(userId).collection('expenses');

    await expensesRef.add({
      'title': title,
      'amount': amount,
      'timestamp': FieldValue.serverTimestamp(), // Optional, for sorting
    });

    // Deduct from bank balance
    int currentBalance = await getBankBalance();
    await updateBankBalance(currentBalance - amount);
  }

  // Delete an expense and update bank balance
  Future<void> deleteExpense(String expenseId, int amount) async {
    if (userId.isEmpty) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .doc(expenseId)
        .delete();

    // Add back the amount to bank balance
    int currentBalance = await getBankBalance();
    await updateBankBalance(currentBalance + amount);
  }

  // 🔥 **Real-time stream for expenses**
  Stream<List<Map<String, dynamic>>> getRecentExpensesStream() {
    if (userId.isEmpty) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .orderBy('timestamp', descending: true) // Sort by timestamp
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'title': doc['title'],
          'amount': doc['amount'],
        };
      }).toList();
    });
  }
}