import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../models/user.dart' as app_user;

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Projects
  Future<List<Project>> getProjects() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return [];
      
      final querySnapshot = await _firestore
          .collection('projects')
          .where('teamMembers', arrayContains: currentUser.uid)
          .get();
      
      return querySnapshot.docs
          .map((doc) => Project.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to load projects: $e');
    }
  }
  
  Future<void> createProject(String name, DateTime startDate, List<String> teamMembers) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');
      
      final project = Project(
        id: '',
        name: name,
        startDate: startDate,
        teamMembers: [currentUser.uid, ...teamMembers],
        progress: 0.0,
        createdAt: DateTime.now(),
        createdBy: currentUser.uid,
      );
      
      await _firestore.collection('projects').add(project.toJson());
    } catch (e) {
      throw Exception('Failed to create project: $e');
    }
  }
  
  Future<void> deleteProject(String projectId) async {
    try {
      await _firestore.collection('projects').doc(projectId).delete();
    } catch (e) {
      throw Exception('Failed to delete project: $e');
    }
  }
  
  // Tasks
  Future<List<Task>> getTasksForProject(String projectId) async {
    try {
      final querySnapshot = await _firestore
          .collection('tasks')
          .where('projectId', isEqualTo: projectId)
          .get();
      
      return querySnapshot.docs
          .map((doc) => Task.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to load tasks: $e');
    }
  }
  
  Future<List<Task>> getMyTasks() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return [];
      
      final querySnapshot = await _firestore
          .collection('tasks')
          .where('assigneeId', isEqualTo: currentUser.uid)
          .get();
      
      return querySnapshot.docs
          .map((doc) => Task.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to load my tasks: $e');
    }
  }
  
  Future<void> createTask(Task task) async {
    try {
      await _firestore.collection('tasks').add(task.toJson());
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }
  
  Future<void> updateTask(Task task) async {
    try {
      await _firestore.collection('tasks').doc(task.id).update(task.toJson());
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }
  
  Future<void> deleteTask(String taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).delete();
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }
  
  // Users
  Future<List<app_user.User>> getUsers() async {
    try {
      final querySnapshot = await _firestore.collection('users').get();
      
      return querySnapshot.docs
          .map((doc) => app_user.User.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }
  
  Future<void> createUser(app_user.User user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toJson());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }
  
  Future<app_user.User?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return app_user.User.fromJson({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }
}
