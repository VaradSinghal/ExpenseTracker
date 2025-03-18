import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Stream for authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get currently signed-in user
  User? get currentUser => _auth.currentUser;

  /// 🔹 Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User canceled sign-in

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      notifyListeners();
      return userCredential.user;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  /// 🔹 Sign in with Email & Password
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
      return userCredential.user;
    } catch (e) {
      print("Email Sign-In Error: $e");
      return null;
    }
  }

  /// 🔹 Register (Sign Up) with Email & Password
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await sendEmailVerification(); // Send email verification
      notifyListeners();
      return userCredential.user;
    } catch (e) {
      print("Sign-Up Error: $e");
      return null;
    }
  }

  /// 🔹 Send Email Verification
  Future<void> sendEmailVerification() async {
    try {
      if (_auth.currentUser != null && !_auth.currentUser!.emailVerified) {
        await _auth.currentUser!.sendEmailVerification();
      }
    } catch (e) {
      print("Email Verification Error: $e");
    }
  }

  /// 🔹 Check if Email is Verified
  Future<bool> isEmailVerified() async {
    try {
      await _auth.currentUser?.reload();
      return _auth.currentUser?.emailVerified ?? false;
    } catch (e) {
      print("Email Verification Check Error: $e");
      return false;
    }
  }

  /// 🔹 Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      notifyListeners();
    } catch (e) {
      print("Sign Out Error: $e");
    }
  }
}
