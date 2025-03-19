// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// class AuthService extends ChangeNotifier {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final GoogleSignIn _googleSignIn = GoogleSignIn();

 
//   Stream<User?> get authStateChanges => _auth.authStateChanges();

//   User? get currentUser => _auth.currentUser;


//   Future<User?> signInWithGoogle() async {
//     try {
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//       if (googleUser == null) return null; // User canceled sign-in

//       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//       final OAuthCredential credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       UserCredential userCredential = await _auth.signInWithCredential(credential);
//       notifyListeners();
//       return userCredential.user;
//     } catch (e) {
//       return null;
//     }
//   }

 
//   Future<User?> signIn(String email, String password) async {
//     try {
//       UserCredential userCredential = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       notifyListeners();
//       return userCredential.user;
//     } catch (e) {

//       return null;
//     }
//   }

//   Future<User?> signUp(String email, String password) async {
//     try {
//       UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       await sendEmailVerification(); // Send email verification
//       notifyListeners();
//       return userCredential.user;
//     } catch (e) {
   
//       return null;
//     }
//   }

//   Future<void> sendEmailVerification() async {
//     try {
//       if (_auth.currentUser != null && !_auth.currentUser!.emailVerified) {
//         await _auth.currentUser!.sendEmailVerification();
//       }
//     } catch (e) {
   
//     }
//   }

//   Future<bool> isEmailVerified() async {
//     try {
//       await _auth.currentUser?.reload();
//       return _auth.currentUser?.emailVerified ?? false;
//     } catch (e) {
  
//       return false;
//     }
//   }


//   Future<void> signOut() async {
//     try {
//       await _auth.signOut();
//       await _googleSignIn.signOut();
//       notifyListeners();
//     } catch (e) {
      
//     }
//   }
// }
