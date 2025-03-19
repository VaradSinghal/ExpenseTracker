// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class FirebaseService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   String get userId => _auth.currentUser?.uid ?? '';

//   Future<void> initializeUser(String email) async {
//     if (userId.isEmpty) return;

//     DocumentReference userRef = _firestore.collection('users').doc(userId);
//     DocumentSnapshot userSnapshot = await userRef.get();

//     if (!userSnapshot.exists) {
//       await userRef.set({
//         'email': email,
//         'bankBalance': 1000, 
//       });
//     }
//   }

  
//   Future<int> getBankBalance() async {
//     if (userId.isEmpty) throw Exception("User not logged in");

//     final doc = await _firestore.collection('users').doc(userId).get();
//     if (doc.exists) {
//       return doc.data()?['bankBalance'] ?? 0; 
//     } else {
//       throw Exception("User document not found");
//     }
//   }

 
//   Future<void> updateBankBalance(int newBalance) async {
//     if (userId.isEmpty) return;

//     await _firestore.collection('users').doc(userId).update({
//       'bankBalance': newBalance,
//     });
//   }

//   Future<void> addExpense(String title, int amount) async {
//     if (userId.isEmpty) return;

//     CollectionReference expensesRef =
//         _firestore.collection('users').doc(userId).collection('expenses');

//     await expensesRef.add({
//       'title': title,
//       'amount': amount,
//       'timestamp': FieldValue.serverTimestamp(), 
//     });

   
//     int currentBalance = await getBankBalance();
//     await updateBankBalance(currentBalance - amount);
//   }

//   Future<void> deleteExpense(String expenseId, int amount) async {
//     if (userId.isEmpty) return;

//     await _firestore
//         .collection('users')
//         .doc(userId)
//         .collection('expenses')
//         .doc(expenseId)
//         .delete();

  
//     int currentBalance = await getBankBalance();
//     await updateBankBalance(currentBalance + amount);
//   }

  
//   Stream<List<Map<String, dynamic>>> getRecentExpensesStream() {
//     if (userId.isEmpty) return Stream.value([]);

//     return _firestore
//         .collection('users')
//         .doc(userId)
//         .collection('expenses')
//         .orderBy('timestamp', descending: true) 
//         .snapshots()
//         .map((querySnapshot) {
//       return querySnapshot.docs.map((doc) {
//         return {
//           'id': doc.id,
//           'title': doc['title'],
//           'amount': doc['amount'],
//         };
//       }).toList();
//     });
//   }
// }