import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../models/member_request.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collections
  static const String usersCollection = 'users';
  static const String projectsCollection = 'projects';
  static const String tasksCollection = 'tasks';
  static const String memberRequestsCollection = 'memberRequests';

  // Get current user ID
  static String? get currentUserId => _auth.currentUser?.uid;

  // User Management
  static Future<void> createUser(UserModel user) async {
    await _firestore.collection(usersCollection).doc(user.uid).set(user.toMap());
  }

  static Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore.collection(usersCollection).doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, uid);
    }
    return null;
  }

  static Future<UserModel?> getCurrentUser() async {
    if (currentUserId == null) return null;
    return await getUser(currentUserId!);
  }

  static Future<void> updateUser(UserModel user) async {
    await _firestore.collection(usersCollection).doc(user.uid).update(user.toMap());
  }

  static Stream<UserModel?> getUserStream(String uid) {
    return _firestore.collection(usersCollection).doc(uid).snapshots().map(
      (doc) => doc.exists ? UserModel.fromMap(doc.data()!, uid) : null,
    );
  }

  // Search users by name or email
  static Future<List<UserModel>> searchUsers(String query) async {
    final querySnapshot = await _firestore
        .collection(usersCollection)
        .where('fullName', isGreaterThanOrEqualTo: query)
        .where('fullName', isLessThan: '${query}z')
        .limit(20)
        .get();

    final emailSnapshot = await _firestore
        .collection(usersCollection)
        .where('email', isGreaterThanOrEqualTo: query)
        .where('email', isLessThan: '${query}z')
        .limit(20)
        .get();

    Set<UserModel> users = {};
    
    for (var doc in querySnapshot.docs) {
      users.add(UserModel.fromMap(doc.data(), doc.id));
    }
    
    for (var doc in emailSnapshot.docs) {
      users.add(UserModel.fromMap(doc.data(), doc.id));
    }

    return users.toList();
  }

  // Get all users except current user
  static Future<List<UserModel>> getAllUsers() async {
    final querySnapshot = await _firestore
        .collection(usersCollection)
        .where(FieldPath.documentId, isNotEqualTo: currentUserId)
        .get();

    return querySnapshot.docs
        .map((doc) => UserModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Project Management
  static Future<String> createProject(Project project) async {
    final docRef = await _firestore.collection(projectsCollection).add(project.toMap());
    return docRef.id;
  }

  static Future<Project?> getProject(String projectId) async {
    final doc = await _firestore.collection(projectsCollection).doc(projectId).get();
    if (doc.exists) {
      return Project.fromMap(doc.data()!, projectId);
    }
    return null;
  }

  static Future<void> updateProject(Project project) async {
    await _firestore.collection(projectsCollection).doc(project.id).update(project.toMap());
  }

  static Future<void> deleteProject(String projectId) async {
    // Delete all tasks in the project first
    final tasksSnapshot = await _firestore
        .collection(tasksCollection)
        .where('projectId', isEqualTo: projectId)
        .get();
    
    for (var doc in tasksSnapshot.docs) {
      await doc.reference.delete();
    }

    // Delete member requests related to this project
    final requestsSnapshot = await _firestore
        .collection(memberRequestsCollection)
        .where('projectId', isEqualTo: projectId)
        .get();
    
    for (var doc in requestsSnapshot.docs) {
      await doc.reference.delete();
    }

    // Delete the project
    await _firestore.collection(projectsCollection).doc(projectId).delete();
  }

  // Get projects for current user (owned or member) - simplified
  static Stream<List<Project>> getUserProjectsStream() {
    if (currentUserId == null) return Stream.value([]);
    
    return _firestore
        .collection(projectsCollection)
        .where('teamMembers', arrayContains: currentUserId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Project.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Task Management
  static Future<String> createTask(Task task) async {
    try {
      print('🔄 FirebaseService: Creating task in Firestore...');
      print('🔄 Task data: ${task.toMap()}');
      
      final docRef = await _firestore.collection(tasksCollection).add(task.toMap());
      print('✅ FirebaseService: Task created with ID: ${docRef.id}');
      
      return docRef.id;
    } catch (e) {
      print('❌ FirebaseService: Error creating task: $e');
      rethrow;
    }
  }

  static Future<Task?> getTask(String taskId) async {
    final doc = await _firestore.collection(tasksCollection).doc(taskId).get();
    if (doc.exists) {
      return Task.fromMap(doc.data()!, taskId);
    }
    return null;
  }

  static Future<void> updateTask(Task task) async {
    await _firestore.collection(tasksCollection).doc(task.id).update(task.toMap());
  }

  static Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    await _firestore.collection(tasksCollection).doc(taskId).update({
      'status': status.toString().split('.').last,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> deleteTask(String taskId) async {
    await _firestore.collection(tasksCollection).doc(taskId).delete();
  }

  // Get tasks for current user - includes both assigned and created tasks
  static Stream<List<Task>> getUserTasksStream() {
    if (currentUserId == null) return Stream.value([]);
    
    return _firestore
        .collection(tasksCollection)
        .where(Filter.or(
          Filter('assignedTo', isEqualTo: currentUserId),
          Filter('createdBy', isEqualTo: currentUserId),
        ))
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Task.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get tasks created by current user
  static Stream<List<Task>> getCreatedTasksStream() {
    if (currentUserId == null) return Stream.value([]);
    
    return _firestore
        .collection(tasksCollection)
        .where('createdBy', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Task.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get tasks for a specific project
  static Stream<List<Task>> getProjectTasksStream(String projectId) {
    return _firestore
        .collection(tasksCollection)
        .where('projectId', isEqualTo: projectId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Task.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Member Request Management
  static Future<String> createMemberRequest(MemberRequest request) async {
    final docRef = await _firestore.collection(memberRequestsCollection).add(request.toMap());
    return docRef.id;
  }

  static Future<void> updateMemberRequest(MemberRequest request) async {
    await _firestore.collection(memberRequestsCollection).doc(request.id).update(request.toMap());
  }

  // Get pending requests for current user
  static Stream<List<MemberRequest>> getPendingRequestsStream() {
    if (currentUserId == null) return Stream.value([]);
    
    return _firestore
        .collection(memberRequestsCollection)
        .where('toUserId', isEqualTo: currentUserId)
        .where('status', isEqualTo: RequestStatus.pending.name)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MemberRequest.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get sent requests by current user
  static Stream<List<MemberRequest>> getSentRequestsStream() {
    if (currentUserId == null) return Stream.value([]);
    
    return _firestore
        .collection(memberRequestsCollection)
        .where('fromUserId', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MemberRequest.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Accept member request
  static Future<void> acceptMemberRequest(String requestId) async {
    final request = await _firestore.collection(memberRequestsCollection).doc(requestId).get();
    if (!request.exists) return;

    final requestData = MemberRequest.fromMap(request.data()!, requestId);
    
    // Update request status
    await _firestore.collection(memberRequestsCollection).doc(requestId).update({
      'status': RequestStatus.accepted.name,
      'respondedAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });

    // Add user to project if it's a project invite
    if (requestData.projectId != null) {
      await _firestore.collection(projectsCollection).doc(requestData.projectId).update({
        'teamMembers': FieldValue.arrayUnion([requestData.toUserId]),
        'pendingInviteIds': FieldValue.arrayRemove([requestData.toUserId]),
        'updatedAt': Timestamp.now(),
      });
    }
  }

  // Decline member request
  static Future<void> declineMemberRequest(String requestId) async {
    await _firestore.collection(memberRequestsCollection).doc(requestId).update({
      'status': RequestStatus.declined.name,
      'respondedAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });
  }

  // Send project invitation
  static Future<void> sendProjectInvitation(String projectId, String toUserId, String message) async {
    // Check if user is already a member or has pending invite
    final project = await getProject(projectId);
    if (project == null) throw Exception('Project not found');

    if (project.isMember(toUserId) || project.hasPendingInvite(toUserId)) {
      throw Exception('User is already a member or has a pending invitation');
    }

    // Create member request
    final request = MemberRequest(
      fromUserId: currentUserId!,
      toUserId: toUserId,
      projectId: projectId,
      type: RequestType.projectInvite,
      message: message,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await createMemberRequest(request);

    // Add to pending invites in project
    await _firestore.collection(projectsCollection).doc(projectId).update({
      'pendingInviteIds': FieldValue.arrayUnion([toUserId]),
      'updatedAt': Timestamp.now(),
    });
  }

  // Remove member from project
  static Future<void> removeMemberFromProject(String projectId, String userId) async {
    await _firestore.collection(projectsCollection).doc(projectId).update({
      'teamMembers': FieldValue.arrayRemove([userId]),
      'updatedAt': Timestamp.now(),
    });

    // Unassign user from all tasks in the project
    final tasksSnapshot = await _firestore
        .collection(tasksCollection)
        .where('projectId', isEqualTo: projectId)
        .where('assignedTo', isEqualTo: userId)
        .get();

    for (var doc in tasksSnapshot.docs) {
      await doc.reference.update({
        'assignedTo': null,
        'updatedAt': Timestamp.now(),
      });
    }
  }
}
