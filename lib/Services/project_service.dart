import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project.dart';
import 'chat_service.dart';

class ProjectService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'projects';

  // Create a new project
  static Future<String> createProject(Project project) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_collection)
          .add(project.toMap());
      
      // Create project chat room automatically
      try {
        final projectWithId = Project(
          id: docRef.id,
          name: project.name,
          description: project.description,
          startDate: project.startDate,
          endDate: project.endDate,
          status: project.status,
          priority: project.priority,
          teamMembers: project.teamMembers,
          createdBy: project.createdBy,
          createdAt: project.createdAt,
          progress: project.progress,
        );
        await ChatService.createProjectChatRoom(projectWithId);
      } catch (chatError) {
        // Log the error but don't fail the project creation
        print('Warning: Failed to create project chat room: $chatError');
      }
      
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create project: $e');
    }
  }

  // Get all projects
  static Stream<List<Project>> getAllProjects() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Project.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get projects by status
  static Stream<List<Project>> getProjectsByStatus(String status) {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Project.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get project by ID
  static Future<Project?> getProjectById(String projectId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(projectId)
          .get();
      
      if (doc.exists) {
        return Project.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get project: $e');
    }
  }

  // Update project
  static Future<void> updateProject(String projectId, Project project) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(projectId)
          .update(project.toMap());
    } catch (e) {
      throw Exception('Failed to update project: $e');
    }
  }

  // Update project progress
  static Future<void> updateProjectProgress(String projectId, double progress) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(projectId)
          .update({'progress': progress});
    } catch (e) {
      throw Exception('Failed to update project progress: $e');
    }
  }

  // Delete project
  static Future<void> deleteProject(String projectId) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(projectId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete project: $e');
    }
  }

  // Add team member to project
  static Future<void> addTeamMember(String projectId, String memberId) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(projectId)
          .update({
        'teamMembers': FieldValue.arrayUnion([memberId])
      });
    } catch (e) {
      throw Exception('Failed to add team member: $e');
    }
  }

  // Remove team member from project
  static Future<void> removeTeamMember(String projectId, String memberId) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(projectId)
          .update({
        'teamMembers': FieldValue.arrayRemove([memberId])
      });
    } catch (e) {
      throw Exception('Failed to remove team member: $e');
    }
  }

  // Get recent projects (last 5)
  static Stream<List<Project>> getRecentProjects() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .limit(5)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Project.fromMap(doc.data(), doc.id))
            .toList());
  }
}
