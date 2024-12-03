import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Sign Up with Email and Password
  Future<User?> signUpWithEmailAndPassword(final String email,
      final String password) async {
    try {
      final UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Sign up failed: $e");
      return null;
    }
  }

  // Sign In with Email and Password
  Future<User?> signInWithEmailAndPassword(final String email,
      final String password) async {
    try {
      final UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Sign in failed: $e");
      return null;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await auth.signOut();
    } catch (e) {
      print("Sign out failed: $e");
    }
  }

  // Get Current User
  User? get currentUser => auth.currentUser;

  // Get User ID
  String? getUserId() {
    return auth.currentUser?.uid;
  }

  // Listen to Auth Changes
  Stream<User?> get authStateChanges => auth.authStateChanges();
}
