import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_data.dart';

/// Helper class for safer Firebase operations
class FirebaseHelpers {
  
  /// Get a user document safely without type casting issues
  static Future<Map<String, dynamic>?> getUserDataSafely(String userId) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
          
      if (docSnapshot.exists) {
        // Return the data as a simple Map - no complex casting
        return docSnapshot.data();
      }
      return null;
    } catch (e) {
      print("Error getting user data: $e");
      return null;
    }
  }
  
  /// Save user data safely to Firestore
  static Future<bool> saveUserData(String userId, Map<String, dynamic> userData) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set(userData, SetOptions(merge: true));
      return true;
    } catch (e) {
      print("Error saving user data: $e");
      return false;
    }
  }
  
  /// Convert Firestore data to UserData model safely
  static UserData? convertToUserData(Map<String, dynamic>? data) {
    if (data == null) return null;
    
    try {
      return UserData.fromMap(data);
    } catch (e) {
      print("Error converting to UserData: $e");
      return null;
    }
  }
  
  /// Get current user data including Firestore profile
  static Future<Map<String, dynamic>> getCurrentUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return {};
    }
    
    try {
      final userData = await getUserDataSafely(user.uid);
      return {
        'uid': user.uid,
        'email': user.email,
        'emailVerified': user.emailVerified,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'profile': userData,
      };
    } catch (e) {
      print("Error getting current user data: $e");
      return {
        'uid': user.uid,
        'email': user.email,
      };
    }
  }
  
  /// Get all projects
  static Future<List<Map<String, dynamic>>> getAllProjects() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('projects').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print("Error getting projects: $e");
      return [];
    }
  }
  
  /// Create a new project
  static Future<String?> createProject(Map<String, dynamic> projectData) async {
    try {
      final docRef = await FirebaseFirestore.instance.collection('projects').add({
        ...projectData,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
      
      return docRef.id;
    } catch (e) {
      print("Error creating project: $e");
      return null;
    }
  }
  
  /// Update a project
  static Future<bool> updateProject(String projectId, Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance.collection('projects').doc(projectId).update({
        ...data,
        'updated_at': FieldValue.serverTimestamp(),
      });
      
      return true;
    } catch (e) {
      print("Error updating project: $e");
      return false;
    }
  }
  
  /// Delete a project
  static Future<bool> deleteProject(String projectId) async {
    try {
      await FirebaseFirestore.instance.collection('projects').doc(projectId).delete();
      return true;
    } catch (e) {
      print("Error deleting project: $e");
      return false;
    }
  }
  
  /// Get project by ID
  static Future<Map<String, dynamic>?> getProjectById(String projectId) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('projects')
          .doc(projectId)
          .get();
      
      if (docSnapshot.exists) {
        return {
          'id': docSnapshot.id,
          ...docSnapshot.data()!,
        };
      }
      return null;
    } catch (e) {
      print("Error getting project by ID: $e");
      return null;
    }
  }
}
