import 'package:firebase_auth/firebase_auth.dart';
/// Firebase authentication
/// manages user sign-in, sign-up, sign-out
class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
///@nodoc
  User? get currentUser => _firebaseAuth.currentUser;
///@nodoc
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword({
    /// Users email and password
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
/// creates a new account with the given email and password. 
  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
/// allows user to sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// @nodoc
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
  /// @nodoc
  @override
  int get hashCode => super.hashCode;

  /// @nodoc
  @override
  bool operator ==(Object other) => identical(this, other);
}
