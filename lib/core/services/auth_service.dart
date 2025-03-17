import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
    
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      notifyListeners();
      return userCredential.user;
    } catch (e) {
   
      return null;
    }
  }

  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      notifyListeners();
      return userCredential.user;
    } catch (e) {
  
      return null;
    }
  }

  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await userCredential.user?.sendEmailVerification();
      notifyListeners();
      return userCredential.user;
    } catch (e) {
 
      return null;
    }
  }

  Future<bool> isEmailVerified() async {
    User? user = _auth.currentUser;
    await user?.reload();
    return user?.emailVerified ?? false;
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      notifyListeners();
    } catch (e) {
    
    }
  }
}
