import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../models/user_model.dart';
import 'firebase_service.dart';

class DashboardService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Dashboard Statistics
  static Future<Map<String, dynamic>> getDashboardStats() async {
    final userId = FirebaseService.currentUserId;
    if (userId == null) return {};

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    // Get user's projects
    final projectsSnapshot = await _firestore
        .collection(FirebaseService.projectsCollection)
        .where('teamMembers', arrayContains: userId)
        .get();

    final projects = projectsSnapshot.docs
        .map((doc) => Project.fromMap(doc.data(), doc.id))
        .toList();

    // Get user's tasks
    final tasksSnapshot = await _firestore
        .collection(FirebaseService.tasksCollection)
        .where('assignedTo', isEqualTo: userId)
        .get();

    final tasks = tasksSnapshot.docs
        .map((doc) => Task.fromMap(doc.data(), doc.id))
        .toList();

    // Get tasks created by user
    final createdTasksSnapshot = await _firestore
        .collection(FirebaseService.tasksCollection)
        .where('createdBy', isEqualTo: userId)
        .get();

    final createdTasks = createdTasksSnapshot.docs
        .map((doc) => Task.fromMap(doc.data(), doc.id))
        .toList();

    // Calculate statistics
    final totalProjects = projects.length;
    final activeProjects = projects.where((p) => p.status == ProjectStatus.active).length;
    final completedProjects = projects.where((p) => p.status == ProjectStatus.completed).length;

    final totalTasks = tasks.length;
    final completedTasks = tasks.where((t) => t.status == TaskStatus.completed).length;
    final pendingTasks = tasks.where((t) => t.status != TaskStatus.completed).length;
    final overdueTasks = tasks.where((t) => t.isOverdue).length;

    // Tasks due today
    final tasksDueToday = tasks.where((t) => 
        t.dueDate.isAfter(todayStart) && t.dueDate.isBefore(todayEnd)
    ).length;

    // Recent activity (tasks created/updated in last 7 days)
    final weekAgo = now.subtract(const Duration(days: 7));
    final recentTasks = createdTasks.where((t) => 
        t.createdAt.isAfter(weekAgo)
    ).length;

    return {
      'totalProjects': totalProjects,
      'activeProjects': activeProjects,
      'completedProjects': completedProjects,
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'pendingTasks': pendingTasks,
      'overdueTasks': overdueTasks,
      'tasksDueToday': tasksDueToday,
      'recentTasks': recentTasks,
      'completionRate': totalTasks > 0 ? (completedTasks / totalTasks * 100).round() : 0,
    };
  }

  // Get recent activities
  static Future<List<Map<String, dynamic>>> getRecentActivities() async {
    final userId = FirebaseService.currentUserId;
    if (userId == null) return [];

    final activities = <Map<String, dynamic>>[];
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));

    // Get recent tasks
    final tasksSnapshot = await _firestore
        .collection(FirebaseService.tasksCollection)
        .where('createdBy', isEqualTo: userId)
        .where('createdAt', isGreaterThan: Timestamp.fromDate(weekAgo))
        .orderBy('createdAt', descending: true)
        .limit(10)
        .get();

    for (var doc in tasksSnapshot.docs) {
      final task = Task.fromMap(doc.data(), doc.id);
      activities.add({
        'type': 'task_created',
        'title': 'Created task: ${task.title}',
        'timestamp': task.createdAt,
        'icon': 'task',
        'color': 'blue',
      });
    }

    // Get recent projects
    final projectsSnapshot = await _firestore
        .collection(FirebaseService.projectsCollection)
        .where('ownerId', isEqualTo: userId)
        .where('createdAt', isGreaterThan: Timestamp.fromDate(weekAgo))
        .orderBy('createdAt', descending: true)
        .limit(5)
        .get();

    for (var doc in projectsSnapshot.docs) {
      final project = Project.fromMap(doc.data(), doc.id);
      activities.add({
        'type': 'project_created',
        'title': 'Created project: ${project.name}',
        'timestamp': project.createdAt,
        'icon': 'project',
        'color': 'green',
      });
    }

    // Sort by timestamp
    activities.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp']));

    return activities.take(15).toList();
  }

  // Get upcoming deadlines
  static Future<List<Task>> getUpcomingDeadlines() async {
    final userId = FirebaseService.currentUserId;
    if (userId == null) return [];

    final nextWeek = DateTime.now().add(const Duration(days: 7));

    final tasksSnapshot = await _firestore
        .collection(FirebaseService.tasksCollection)
        .where('assignedTo', isEqualTo: userId)
        .where('dueDate', isLessThan: Timestamp.fromDate(nextWeek))
        .where('status', isNotEqualTo: TaskStatus.completed.name)
        .orderBy('dueDate')
        .limit(10)
        .get();

    return tasksSnapshot.docs
        .map((doc) => Task.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Get project progress data
  static Future<List<Map<String, dynamic>>> getProjectProgress() async {
    final userId = FirebaseService.currentUserId;
    if (userId == null) return [];

    final projectsSnapshot = await _firestore
        .collection(FirebaseService.projectsCollection)
        .where('teamMembers', arrayContains: userId)
        .where('status', isNotEqualTo: ProjectStatus.completed.name)
        .get();

    final projectProgress = <Map<String, dynamic>>[];

    for (var doc in projectsSnapshot.docs) {
      final project = Project.fromMap(doc.data(), doc.id);
      
      // Get task count for this project
      final tasksSnapshot = await _firestore
          .collection(FirebaseService.tasksCollection)
          .where('projectId', isEqualTo: project.id)
          .get();

      final tasks = tasksSnapshot.docs
          .map((doc) => Task.fromMap(doc.data(), doc.id))
          .toList();

      final totalTasks = tasks.length;
      final completedTasks = tasks.where((t) => t.status == TaskStatus.completed).length;
      final progress = totalTasks > 0 ? (completedTasks / totalTasks) : 0.0;

      projectProgress.add({
        'project': project,
        'totalTasks': totalTasks,
        'completedTasks': completedTasks,
        'progress': progress,
      });
    }

    return projectProgress;
  }

  // Get team members for user's projects
  static Future<List<UserModel>> getTeamMembers() async {
    final userId = FirebaseService.currentUserId;
    if (userId == null) return [];

    final projectsSnapshot = await _firestore
        .collection(FirebaseService.projectsCollection)
        .where('teamMembers', arrayContains: userId)
        .get();

    final memberIds = <String>{};
    
    for (var doc in projectsSnapshot.docs) {
      final project = Project.fromMap(doc.data(), doc.id);
      memberIds.addAll(project.teamMembers);
    }

    memberIds.remove(userId); // Remove current user

    final members = <UserModel>[];
    for (var memberId in memberIds) {
      final user = await FirebaseService.getUser(memberId);
      if (user != null) {
        members.add(user);
      }
    }

    return members;
  }

  // Search functionality for dashboard
  static Future<List<Map<String, dynamic>>> searchContent(String query) async {
    final userId = FirebaseService.currentUserId;
    if (userId == null) return [];

    final results = <Map<String, dynamic>>[];
    
    // Search projects
    final projectsSnapshot = await _firestore
        .collection(FirebaseService.projectsCollection)
        .where('teamMembers', arrayContains: userId)
        .get();

    for (var doc in projectsSnapshot.docs) {
      final project = Project.fromMap(doc.data(), doc.id);
      if (project.name.toLowerCase().contains(query.toLowerCase()) ||
          project.description.toLowerCase().contains(query.toLowerCase())) {
        results.add({
          'type': 'project',
          'id': project.id,
          'title': project.name,
          'description': project.description,
          'data': project,
        });
      }
    }

    // Search tasks
    final tasksSnapshot = await _firestore
        .collection(FirebaseService.tasksCollection)
        .where('assignedTo', isEqualTo: userId)
        .get();

    for (var doc in tasksSnapshot.docs) {
      final task = Task.fromMap(doc.data(), doc.id);
      if (task.title.toLowerCase().contains(query.toLowerCase()) ||
          task.description.toLowerCase().contains(query.toLowerCase())) {
        results.add({
          'type': 'task',
          'id': task.id,
          'title': task.title,
          'description': task.description,
          'data': task,
        });
      }
    }

    return results;
  }
}
