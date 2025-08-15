import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  User? get currentUser => _auth.currentUser;
  
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Check if user is already logged in
  Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('rememberMe') ?? false;
    
    // If remember me is false, we should sign out any existing user
    if (!rememberMe) {
      await _auth.signOut();
      return false;
    }
    
    // Otherwise check for current user
    return _auth.currentUser != null;
  }
  
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }
  
  Future<User?> createUserWithEmailAndPassword(String email, String password, String name) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user != null) {
        await result.user!.updateDisplayName(name);
        await result.user!.reload();
      }
      
      return result.user;
    } catch (e) {
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }
  
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }
  
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      
      // Clear the remember me preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('rememberMe', false);
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }
  
  Future<bool> verifyOTP(String verificationId, String otp) async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      
      final UserCredential result = await _auth.signInWithCredential(credential);
      return result.user != null;
    } catch (e) {
      return false;
    }
  }
}
