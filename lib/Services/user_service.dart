import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  static const String _usersCollection = 'users';

  // Create user profile in Firestore
  static Future<bool> createUserProfile(UserModel user) async {
    try {
      await _firestore.collection(_usersCollection).doc(user.uid).set(user.toMap());
      return true;
    } catch (e) {
      print('Error creating user profile: $e');
      return false;
    }
  }

  // Get current user profile
  static Future<UserModel?> getCurrentUserProfile() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      final doc = await _firestore.collection(_usersCollection).doc(currentUser.uid).get();
      
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      } else {
        // Create a new profile if it doesn't exist
        final newUser = UserModel(
          uid: currentUser.uid,
          email: currentUser.email ?? '',
          fullName: currentUser.displayName ?? 'Unknown User',
          phoneNumber: currentUser.phoneNumber,
          photoURL: currentUser.photoURL,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await createUserProfile(newUser);
        return newUser;
      }
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Update user profile
  static Future<bool> updateUserProfile(UserModel user) async {
    try {
      await _firestore.collection(_usersCollection).doc(user.uid).update({
        ...user.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  // Update specific user fields
  static Future<bool> updateUserFields(String uid, Map<String, dynamic> fields) async {
    try {
      fields['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection(_usersCollection).doc(uid).update(fields);
      return true;
    } catch (e) {
      print('Error updating user fields: $e');
      return false;
    }
  }

  // Delete user profile
  static Future<bool> deleteUserProfile(String uid) async {
    try {
      await _firestore.collection(_usersCollection).doc(uid).delete();
      return true;
    } catch (e) {
      print('Error deleting user profile: $e');
      return false;
    }
  }

  // Get user by ID
  static Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection(_usersCollection).doc(uid).get();
      
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting user by ID: $e');
      return null;
    }
  }

  // Search users by name or email
  static Future<List<UserModel>> searchUsers(String query) async {
    try {
      final queryLower = query.toLowerCase();
      
      final nameQuery = await _firestore
          .collection(_usersCollection)
          .where('fullName', isGreaterThanOrEqualTo: queryLower)
          .where('fullName', isLessThanOrEqualTo: queryLower + '\uf8ff')
          .get();
      
      final emailQuery = await _firestore
          .collection(_usersCollection)
          .where('email', isGreaterThanOrEqualTo: queryLower)
          .where('email', isLessThanOrEqualTo: queryLower + '\uf8ff')
          .get();
      
      final Set<String> userIds = {};
      final List<UserModel> users = [];
      
      for (var doc in nameQuery.docs) {
        if (!userIds.contains(doc.id)) {
          userIds.add(doc.id);
          users.add(UserModel.fromMap(doc.data(), doc.id));
        }
      }
      
      for (var doc in emailQuery.docs) {
        if (!userIds.contains(doc.id)) {
          userIds.add(doc.id);
          users.add(UserModel.fromMap(doc.data(), doc.id));
        }
      }
      
      return users;
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  // Update user last login
  static Future<void> updateLastLogin(String uid) async {
    try {
      await _firestore.collection(_usersCollection).doc(uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating last login: $e');
    }
  }

  // Update password (Firebase Auth)
  static Future<bool> updatePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating password: $e');
      return false;
    }
  }

  // Send password reset email
  static Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print('Error sending password reset email: $e');
      return false;
    }
  }

  // Reauthenticate user
  static Future<bool> reauthenticateUser(String email, String password) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final credential = EmailAuthProvider.credential(email: email, password: password);
        await user.reauthenticateWithCredential(credential);
        return true;
      }
      return false;
    } catch (e) {
      print('Error reauthenticating user: $e');
      return false;
    }
  }

  // Update email
  static Future<bool> updateEmail(String newEmail, String currentPassword) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Reauthenticate first
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);
        
        // Update email in Firebase Auth
        await user.updateEmail(newEmail);
        
        // Update email in Firestore
        await updateUserFields(user.uid, {'email': newEmail});
        
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating email: $e');
      return false;
    }
  }

  // Stream user profile changes
  static Stream<UserModel?> streamUserProfile(String uid) {
    return _firestore.collection(_usersCollection).doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }
}
