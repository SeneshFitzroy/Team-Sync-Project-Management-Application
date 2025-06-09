import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:retry/retry.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Error detection helpers
  static bool _isNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') || 
           errorString.contains('timeout') || 
           errorString.contains('connection') ||
           errorString.contains('unavailable');
  }

  static bool _isPermissionError(dynamic error) {
    return error.toString().contains('permission-denied');
  }

  // Enhanced retry method using retry package
  static Future<T> _retryFirestoreOperation<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    return await retry(
      operation,
      maxAttempts: maxAttempts,
      delayFactor: delay,
      retryIf: (e) => _isNetworkError(e) && !_isPermissionError(e),
    );
  }

  // Get current user ID
  static String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  // Get current user email
  static String? getCurrentUserEmail() {
    return _auth.currentUser?.email;
  }

  // User Management with retry logic and auth checks
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    // Check if user is authenticated before attempting Firestore operations
    if (_auth.currentUser == null) {
      print('⚠️ User not authenticated - skipping Firestore write');
      return;
    }

    int retries = 3;
    for (int attempt = 1; attempt <= retries; attempt++) {
      try {
        final userId = getCurrentUserId();
        if (userId != null) {
          await _firestore.collection('users').doc(userId).set({
            ...userData,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          print('✓ User data saved successfully (attempt $attempt)');
          return; // Success - exit retry loop
        }
      } catch (e) {
        print('✗ Error saving user data (attempt $attempt): $e');
        
        if (_isPermissionError(e)) {
          print('📝 Note: Firestore permissions need to be configured for writes');
          return; // Don't retry permission errors
        }
        
        if (attempt == retries) {
          print('❌ Failed to save user data after $retries attempts');
          // Don't rethrow to allow login to continue even if Firestore write fails
        } else {
          // Wait before retrying
          await Future.delayed(Duration(milliseconds: 500 * attempt));
        }
      }
    }
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final userId = getCurrentUserId();
      if (userId != null) {
        final doc = await _firestore.collection('users').doc(userId).get();
        if (doc.exists) {
          return doc.data();
        }
      }
      return null;
    } catch (e) {
      print('✗ Error getting user data: $e');
      return null;
    }
  }

  static Future<void> updateUserProfile(Map<String, dynamic> profileData) async {
    try {
      final userId = getCurrentUserId();
      if (userId != null) {
        await _firestore.collection('users').doc(userId).update({
          ...profileData,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('✓ Profile updated successfully');
      }
    } catch (e) {
      print('✗ Error updating profile: $e');
      rethrow;
    }
  }

  // Project Management - REMOVED DUPLICATE METHOD
  // Use the user-specific createProject method below

  // Project Management - User-specific collections
  static Stream<QuerySnapshot> getUserProjects({String? userId}) {
    final uid = userId ?? getCurrentUserId();
    if (uid == null) {
      return const Stream.empty();
    }
    
    // Use user-specific subcollection to avoid index requirements
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('projects')
        .snapshots();
  }

  static Future<String> createProject(Map<String, dynamic> projectData, {required String userId}) async {
    try {
      if (_auth.currentUser == null) throw Exception('User not authenticated');
      
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('projects')
          .add({
        ...projectData,
        'ownerId': userId,
        'createdBy': getCurrentUserEmail(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'members': [userId], // Owner is always a member
      });
      
      print('✓ Project created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('✗ Error creating project: $e');
      rethrow;
    }
  }

  static Future<void> updateProject(String projectId, Map<String, dynamic> updates, {required String userId}) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('projects')
          .doc(projectId)
          .update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✓ Project updated successfully');
    } catch (e) {
      print('✗ Error updating project: $e');
      rethrow;
    }
  }

  static Future<void> deleteProject(String projectId) async {
    try {
      // Delete all tasks in the project first
      final tasks = await _firestore
          .collection('tasks')
          .where('projectId', isEqualTo: projectId)
          .get();
      
      for (var task in tasks.docs) {
        await task.reference.delete();
      }
      
      // Delete the project
      await _firestore.collection('projects').doc(projectId).delete();
      print('✓ Project deleted successfully');
    } catch (e) {
      print('✗ Error deleting project: $e');
      rethrow;
    }
  }

  // Task Management
  static Future<String> createTask(Map<String, dynamic> taskData) async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) throw Exception('User not authenticated');
      
      final docRef = await _firestore.collection('tasks').add({
        ...taskData,
        'createdBy': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      print('✓ Task created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('✗ Error creating task: $e');
      rethrow;
    }
  }

  static Stream<QuerySnapshot> getProjectTasks(String projectId) {
    return _firestore
        .collection('tasks')
        .where('projectId', isEqualTo: projectId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot> getUserTasks() {
    final userId = getCurrentUserId();
    if (userId == null) {
      return const Stream.empty();
    }
    
    return _firestore
        .collection('tasks')
        .where('assignedTo', arrayContains: userId)
        .orderBy('dueDate', descending: false)
        .snapshots();
  }

  static Future<void> updateTask(String taskId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✓ Task updated successfully');
    } catch (e) {
      print('✗ Error updating task: $e');
      rethrow;
    }
  }

  static Future<void> deleteTask(String taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).delete();
      print('✓ Task deleted successfully');
    } catch (e) {
      print('✗ Error deleting task: $e');
      rethrow;
    }
  }

  // Chat/Messages
  static Future<void> sendMessage(String projectId, String message) async {
    try {
      final userId = getCurrentUserId();
      final userEmail = getCurrentUserEmail();
      if (userId == null) throw Exception('User not authenticated');
      
      await _firestore.collection('projects').doc(projectId).collection('messages').add({
        'message': message,
        'senderId': userId,
        'senderEmail': userEmail,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      print('✓ Message sent successfully');
    } catch (e) {
      print('✗ Error sending message: $e');
      rethrow;
    }
  }

  static Stream<QuerySnapshot> getProjectMessages(String projectId) {
    return _firestore
        .collection('projects')
        .doc(projectId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Notifications
  static Future<void> createNotification(String userId, Map<String, dynamic> notificationData) async {
    try {
      await _firestore.collection('users').doc(userId).collection('notifications').add({
        ...notificationData,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('✓ Notification created successfully');
    } catch (e) {
      print('✗ Error creating notification: $e');
      rethrow;
    }
  }

  static Stream<QuerySnapshot> getUserNotifications() {
    final userId = getCurrentUserId();
    if (userId == null) {
      return const Stream.empty();
    }
    
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      final userId = getCurrentUserId();
      if (userId != null) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .doc(notificationId)
            .update({'read': true});
        print('✓ Notification marked as read');
      }
    } catch (e) {
      print('✗ Error marking notification as read: $e');
      rethrow;
    }
  }

  // Team Management
  static Future<void> addTeamMember(String projectId, String memberEmail) async {
    try {
      // Find user by email
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: memberEmail)
          .get();
      
      if (userQuery.docs.isEmpty) {
        throw Exception('User not found with email: $memberEmail');
      }
      
      final memberId = userQuery.docs.first.id;
      
      // Add member to project
      await _firestore.collection('projects').doc(projectId).update({
        'members': FieldValue.arrayUnion([memberId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Create notification for new member
      await createNotification(memberId, {
        'type': 'project_invitation',
        'title': 'Added to Project',
        'message': 'You have been added to a new project',
        'projectId': projectId,
      });
      
      print('✓ Team member added successfully');
    } catch (e) {
      print('✗ Error adding team member: $e');
      rethrow;
    }
  }

  // Authentication state changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Password reset
  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('✓ Password reset email sent');
    } catch (e) {
      print('✗ Error sending password reset email: $e');
      rethrow;
    }
  }

  // Analytics and logging with retry logic and auth checks
  static Future<void> logActivity(String activity, Map<String, dynamic> data) async {
    // Check if user is authenticated before attempting Firestore operations
    if (_auth.currentUser == null) {
      print('⚠️ User not authenticated - skipping activity log');
      return;
    }

    int retries = 2; // Fewer retries for logging
    for (int attempt = 1; attempt <= retries; attempt++) {
      try {
        final userId = getCurrentUserId();
        if (userId != null) {
          // Store activities in user-specific subcollection to avoid permission issues
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('activities')
              .add({
            'userId': userId,
            'activity': activity,
            'data': data,
            'timestamp': FieldValue.serverTimestamp(),
          });
          print('✓ Activity logged: $activity (attempt $attempt)');
          return; // Success - exit retry loop
        }
      } catch (e) {
        print('✗ Error logging activity (attempt $attempt): $e');
        
        if (e.toString().contains('permission-denied')) {
          print('📝 Note: Firestore permissions need to be configured for activity logs');
          return; // Don't retry permission errors
        }
        
        if (attempt == retries) {
          print('❌ Failed to log activity after $retries attempts');
          // Don't throw - logging shouldn't break the app
        } else {
          // Wait before retrying
          await Future.delayed(Duration(milliseconds: 300 * attempt));
        }
      }
    }
  }
}
