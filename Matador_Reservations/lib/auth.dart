/// Allows for the authentication when signing in/out 

import 'package:firebase_auth/firebase_auth.dart';

/// Acceses the firebase to authenitcate accounts
/// 
/// user enters their email as passoword
/// what this Class will do: 
///  - check if the given email and passoword allready has been created
///  - if not it createsnthe users account
///  - if already created and its the right email as password it lets the user account connect to the app
class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
/// creates the account
  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
/// signs the user out of their account
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
