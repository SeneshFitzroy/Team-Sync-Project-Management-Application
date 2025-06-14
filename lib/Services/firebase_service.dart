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

  // Enhanced project creation with permission error handling
  static Future<String> createProject(Map<String, dynamic> projectData, {required String userId}) async {
    try {
      // Enhanced authentication check
      if (_auth.currentUser == null) {
        throw Exception('User not authenticated. Please log in again.');
      }
      
      // Verify userId matches current user
      if (userId != _auth.currentUser!.uid) {
        throw Exception('User ID mismatch. Please log in again.');
      }
      
      print('🔄 Creating project: ${projectData['title']}');
      print('👤 User ID: $userId');
      print('✉️ User Email: ${getCurrentUserEmail()}');
      
      // Enhanced project data with better structure
      final enhancedProjectData = {
        ...projectData,
        'ownerId': userId,
        'createdBy': getCurrentUserEmail(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'members': projectData['members'] ?? [userId], // Include team members
        'isActive': true,
        'version': 1,
      };
      
      // Try with retry logic for better reliability
      return await _retryFirestoreOperation(() async {
        // Add to user's collection (primary)
        final userDocRef = await _firestore
            .collection('users')
            .doc(userId)
            .collection('projects')
            .add(enhancedProjectData);
        
        // Also add to global projects collection for team collaboration
        try {
          await _firestore
              .collection('projects')
              .doc(userDocRef.id)
              .set({
            ...enhancedProjectData,
            'userProjectId': userDocRef.id,
            'teamAccess': true,
          });
          print('✓ Project added to global collection for team access');
        } catch (e) {
          print('⚠️ Could not add to global collection (continuing): $e');
          // Don't fail the entire operation if global collection fails
        }
        
        print('✅ Project created successfully with ID: ${userDocRef.id}');
        return userDocRef.id;
      });
      
    } catch (e) {
      print('❌ Error creating project: $e');
      
      // If it's a permission error, provide helpful guidance
      if (_isPermissionError(e)) {
        print('📝 PERMISSION ERROR: Please deploy Firestore rules first');
        print('📝 Run: deploy_rules_manual.bat or use Firebase Console');
        throw Exception('Permission denied. Please deploy Firestore security rules first.');
      }
      
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

  static Future<void> deleteProject(String projectId, {required String userId}) async {
    try {
      // Delete all tasks in the user's tasks collection for this project
      final currentUserId = getCurrentUserId();
      if (currentUserId != null) {
        final tasks = await _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('tasks')
            .where('projectId', isEqualTo: projectId)
            .get();
        
        for (var task in tasks.docs) {
          await task.reference.delete();
        }
      }
      
      // Delete the project from user's projects collection
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('projects')
          .doc(projectId)
          .delete();
      print('✓ Project deleted successfully');
    } catch (e) {
      print('✗ Error deleting project: $e');
      rethrow;
    }
  }

  // Enhanced Project Management Methods
  
  // Search for public projects that users can join
  static Future<List<Map<String, dynamic>>> searchPublicProjects({
    String? searchQuery,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore
          .collection('projects')
          .where('isPublic', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .limit(limit);

      if (searchQuery != null && searchQuery.isNotEmpty) {
        // Use a simple text search approach
        query = query
            .where('title', isGreaterThanOrEqualTo: searchQuery)
            .where('title', isLessThanOrEqualTo: '$searchQuery\uf8ff');
      }

      final querySnapshot = await query.get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('❌ Error searching public projects: $e');
      return [];
    }
  }

  // Join an existing project
  static Future<bool> joinProject({
    required String projectId,
    required String userId,
  }) async {
    try {
      if (_auth.currentUser == null || userId != _auth.currentUser!.uid) {
        throw Exception('User not authenticated');
      }

      return await _retryFirestoreOperation(() async {
        // Get the project from global collection
        final projectDoc = await _firestore
            .collection('projects')
            .doc(projectId)
            .get();

        if (!projectDoc.exists) {
          throw Exception('Project not found');
        }

        final projectData = projectDoc.data()!;
        final currentMembers = List<String>.from(projectData['members'] ?? []);
        
        if (currentMembers.contains(userId)) {
          throw Exception('Already a member of this project');
        }

        // Add user to project members
        await _firestore
            .collection('projects')
            .doc(projectId)
            .update({
          'members': FieldValue.arrayUnion([userId]),
          'memberCount': (currentMembers.length + 1),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Add project to user's collection
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('projects')
            .doc(projectId)
            .set({
          ...projectData,
          'joinedAt': FieldValue.serverTimestamp(),
          'role': 'member',
          'isOwner': false,
        });

        print('✅ Successfully joined project: ${projectData['title']}');
        return true;
      });
    } catch (e) {
      print('❌ Error joining project: $e');
      return false;
    }
  }

  // Get project by invite code
  static Future<Map<String, dynamic>?> getProjectByInviteCode(String inviteCode) async {
    try {
      final querySnapshot = await _firestore
          .collection('projects')
          .where('inviteCode', isEqualTo: inviteCode)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }
      return null;
    } catch (e) {
      print('❌ Error getting project by invite code: $e');
      return null;
    }
  }

  // Enhanced Calendar and Task Scheduling Methods
  
  // Create a scheduled task for future dates
  static Future<String?> createScheduledTask({
    required Map<String, dynamic> taskData,
    required DateTime scheduledDate,
    String? userId,
  }) async {
    try {
      final uid = userId ?? getCurrentUserId();
      if (uid == null || _auth.currentUser == null) {
        throw Exception('User not authenticated');
      }

      return await _retryFirestoreOperation(() async {
        final enhancedTaskData = {
          ...taskData,
          'userId': uid,
          'createdBy': getCurrentUserEmail(),
          'scheduledDate': Timestamp.fromDate(scheduledDate),
          'dueDate': Timestamp.fromDate(scheduledDate),
          'isScheduled': true,
          'type': 'scheduled',
          'status': 'To Do',
          'priority': taskData['priority'] ?? 'Medium',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        final docRef = await _firestore
            .collection('users')
            .doc(uid)
            .collection('tasks')
            .add(enhancedTaskData);

        print('✅ Scheduled task created for ${scheduledDate.toString().split(' ')[0]}');
        return docRef.id;
      });
    } catch (e) {
      print('❌ Error creating scheduled task: $e');
      return null;
    }
  }

  // Get tasks for a specific date range
  static Stream<QuerySnapshot> getTasksForDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? userId,
  }) {
    final uid = userId ?? getCurrentUserId();
    if (uid == null) {
      return const Stream.empty();
    }

    final startTimestamp = Timestamp.fromDate(startDate);
    final endTimestamp = Timestamp.fromDate(endDate);

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .where('scheduledDate', isGreaterThanOrEqualTo: startTimestamp)
        .where('scheduledDate', isLessThanOrEqualTo: endTimestamp)
        .orderBy('scheduledDate')
        .snapshots();
  }

  // Get upcoming tasks (next 7 days)
  static Stream<QuerySnapshot> getUpcomingTasks({String? userId}) {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    
    return getTasksForDateRange(
      startDate: now,
      endDate: nextWeek,
      userId: userId,
    );
  }

  // Update task schedule
  static Future<bool> rescheduleTask({
    required String taskId,
    required DateTime newDate,
    String? userId,
  }) async {
    try {
      final uid = userId ?? getCurrentUserId();
      if (uid == null || _auth.currentUser == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('tasks')
          .doc(taskId)
          .update({
        'scheduledDate': Timestamp.fromDate(newDate),
        'dueDate': Timestamp.fromDate(newDate),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Task rescheduled to ${newDate.toString().split(' ')[0]}');
      return true;
    } catch (e) {
      print('❌ Error rescheduling task: $e');
      return false;
    }
  }

  // Get tasks for a specific day
  static Future<List<Map<String, dynamic>>> getTasksForDay({
    required DateTime date,
    String? userId,
  }) async {
    try {
      final uid = userId ?? getCurrentUserId();
      if (uid == null) return [];

      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final querySnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('tasks')
          .where('scheduledDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('scheduledDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .orderBy('scheduledDate')
          .get();

      return querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
    } catch (e) {
      print('❌ Error getting tasks for day: $e');
      return [];
    }
  }

  // Chat/Messages - User-specific subcollections
  static Future<void> sendMessage(String projectId, String message) async {
    try {
      final userId = getCurrentUserId();
      final userEmail = getCurrentUserEmail();
      if (userId == null) throw Exception('User not authenticated');
      
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('projects')
          .doc(projectId)
          .collection('messages')
          .add({
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
    final userId = getCurrentUserId();
    if (userId == null) {
      return const Stream.empty();
    }
    
    return _firestore
        .collection('users')
        .doc(userId)
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
      final userId = getCurrentUserId();
      if (userId == null) throw Exception('User not authenticated');
      
      // Find user by email
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: memberEmail)
          .get();
      
      if (userQuery.docs.isEmpty) {
        throw Exception('User not found with email: $memberEmail');
      }
      
      final memberId = userQuery.docs.first.id;
      
      // Add member to project in user's collection
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('projects')
          .doc(projectId)
          .update({
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
      }    }
  }

  // Enhanced Project Management Methods
  
  // Search for public projects that users can join
  static Future<List<Map<String, dynamic>>> searchPublicProjects({
    String? searchQuery,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore
          .collection('projects')
          .where('isPublic', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .limit(limit);

      if (searchQuery != null && searchQuery.isNotEmpty) {
        // Use a simple text search approach
        query = query
            .where('title', isGreaterThanOrEqualTo: searchQuery)
            .where('title', isLessThanOrEqualTo: '$searchQuery\uf8ff');
      }

      final querySnapshot = await query.get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('❌ Error searching public projects: $e');
      return [];
    }
  }

  // Join an existing project
  static Future<bool> joinProject({
    required String projectId,
    required String userId,
  }) async {
    try {
      if (_auth.currentUser == null || userId != _auth.currentUser!.uid) {
        throw Exception('User not authenticated');
      }

      return await _retryFirestoreOperation(() async {
        // Get the project from global collection
        final projectDoc = await _firestore
            .collection('projects')
            .doc(projectId)
            .get();

        if (!projectDoc.exists) {
          throw Exception('Project not found');
        }

        final projectData = projectDoc.data()!;
        final currentMembers = List<String>.from(projectData['members'] ?? []);
        
        if (currentMembers.contains(userId)) {
          throw Exception('Already a member of this project');
        }

        // Add user to project members
        await _firestore
            .collection('projects')
            .doc(projectId)
            .update({
          'members': FieldValue.arrayUnion([userId]),
          'memberCount': (currentMembers.length + 1),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Add project to user's collection
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('projects')
            .doc(projectId)
            .set({
          ...projectData,
          'joinedAt': FieldValue.serverTimestamp(),
          'role': 'member',
          'isOwner': false,
        });

        print('✅ Successfully joined project: ${projectData['title']}');
        return true;
      });
    } catch (e) {
      print('❌ Error joining project: $e');
      return false;
    }
  }

  // Get project by invite code
  static Future<Map<String, dynamic>?> getProjectByInviteCode(String inviteCode) async {
    try {
      final querySnapshot = await _firestore
          .collection('projects')
          .where('inviteCode', isEqualTo: inviteCode)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }
      return null;
    } catch (e) {
      print('❌ Error getting project by invite code: $e');
      return null;
    }
  }

  // Enhanced Calendar and Task Scheduling Methods
  
  // Create a scheduled task for future dates
  static Future<String?> createScheduledTask({
    required Map<String, dynamic> taskData,
    required DateTime scheduledDate,
    String? userId,
  }) async {
    try {
      final uid = userId ?? getCurrentUserId();
      if (uid == null || _auth.currentUser == null) {
        throw Exception('User not authenticated');
      }

      return await _retryFirestoreOperation(() async {
        final enhancedTaskData = {
          ...taskData,
          'userId': uid,
          'createdBy': getCurrentUserEmail(),
          'scheduledDate': Timestamp.fromDate(scheduledDate),
          'dueDate': Timestamp.fromDate(scheduledDate),
          'isScheduled': true,
          'type': 'scheduled',
          'status': 'To Do',
          'priority': taskData['priority'] ?? 'Medium',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        final docRef = await _firestore
            .collection('users')
            .doc(uid)
            .collection('tasks')
            .add(enhancedTaskData);

        print('✅ Scheduled task created for ${scheduledDate.toString().split(' ')[0]}');
        return docRef.id;
      });
    } catch (e) {
      print('❌ Error creating scheduled task: $e');
      return null;
    }
  }

  // Get tasks for a specific date range
  static Stream<QuerySnapshot> getTasksForDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? userId,
  }) {
    final uid = userId ?? getCurrentUserId();
    if (uid == null) {
      return const Stream.empty();
    }

    final startTimestamp = Timestamp.fromDate(startDate);
    final endTimestamp = Timestamp.fromDate(endDate);

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .where('scheduledDate', isGreaterThanOrEqualTo: startTimestamp)
        .where('scheduledDate', isLessThanOrEqualTo: endTimestamp)
        .orderBy('scheduledDate')
        .snapshots();
  }

  // Get upcoming tasks (next 7 days)
  static Stream<QuerySnapshot> getUpcomingTasks({String? userId}) {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    
    return getTasksForDateRange(
      startDate: now,
      endDate: nextWeek,
      userId: userId,
    );
  }

  // Update task schedule
  static Future<bool> rescheduleTask({
    required String taskId,
    required DateTime newDate,
    String? userId,
  }) async {
    try {
      final uid = userId ?? getCurrentUserId();
      if (uid == null || _auth.currentUser == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('tasks')
          .doc(taskId)
          .update({
        'scheduledDate': Timestamp.fromDate(newDate),
        'dueDate': Timestamp.fromDate(newDate),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Task rescheduled to ${newDate.toString().split(' ')[0]}');
      return true;
    } catch (e) {
      print('❌ Error rescheduling task: $e');
      return false;
    }
  }

  // Get tasks for a specific day
  static Future<List<Map<String, dynamic>>> getTasksForDay({
    required DateTime date,
    String? userId,
  }) async {
    try {
      final uid = userId ?? getCurrentUserId();
      if (uid == null) return [];

      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final querySnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('tasks')
          .where('scheduledDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('scheduledDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .orderBy('scheduledDate')
          .get();

      return querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
    } catch (e) {
      print('❌ Error getting tasks for day: $e');
      return [];
    }
  }
}
