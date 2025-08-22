import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get current user
  static User? get currentUser => _auth.currentUser;
  
  // Stream of auth changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Sign in with email and password
  static Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update last login time
      if (result.user != null) {
        await _updateUserLastLogin(result.user!.uid);
      }
      
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred during sign in: $e');
    }
  }
  
  // Create user with email and password
  static Future<UserCredential?> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user != null) {
        // Update display name
        await result.user!.updateDisplayName(fullName);
        
        // Create user document in Firestore
        await _createUserDocument(
          result.user!.uid,
          email,
          fullName,
          phoneNumber,
        );
      }
      
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred during registration: $e');
    }
  }
  
  // Sign out
  static Future<void> signOut() async {
    try {
      // Get current user info for logging
      final user = _auth.currentUser;
      print('🚪 Signing out user: ${user?.email ?? "Unknown"}');
      
      // Sign out from Firebase
      await _auth.signOut();
      
      // Verify sign out was successful
      if (_auth.currentUser == null) {
        print('✅ User successfully signed out');
      } else {
        print('⚠️ Warning: User may not have signed out completely');
      }
      
    } catch (e) {
      print('❌ Error during sign out: $e');
      throw Exception('Error signing out: $e');
    }
  }
  
  // Reset password
  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error sending password reset email: $e');
    }
  }
  
  // Update user profile
  static Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        if (displayName != null) {
          await user.updateDisplayName(displayName);
        }
        if (photoURL != null) {
          await user.updatePhotoURL(photoURL);
        }
        
        // Update Firestore document
        await _firestore.collection('users').doc(user.uid).update({
          if (displayName != null) 'fullName': displayName,
          if (photoURL != null) 'photoURL': photoURL,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }
  
  // Get user data from Firestore
  static Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Error getting user data: $e');
    }
  }
  
  // Stream of current user data
  static Stream<UserModel?> get currentUserData {
    User? user = _auth.currentUser;
    if (user != null) {
      return _firestore
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .map((doc) {
        if (doc.exists) {
          return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }
        return null;
      });
    }
    return Stream.value(null);
  }
  
  // Check if user is authenticated
  static bool get isAuthenticated => _auth.currentUser != null;
  
  // Get current user ID
  static String? get currentUserId => _auth.currentUser?.uid;
  
  // Private helper methods
  static Future<void> _createUserDocument(
    String uid,
    String email,
    String fullName,
    String? phoneNumber,
  ) async {
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'photoURL': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
      'isActive': true,
      'role': 'user', // Default role
    });
  }
  
  static Future<void> _updateUserLastLogin(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'lastLoginAt': FieldValue.serverTimestamp(),
    });
  }
  
  static String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'requires-recent-login':
        return 'This operation requires recent authentication. Please log in again.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}
