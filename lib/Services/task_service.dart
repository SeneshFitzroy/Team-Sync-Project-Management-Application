import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class TaskService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'tasks';

  // Create a new task
  static Future<String> createTask(Task task) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_collection)
          .add(task.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }

  // Get all tasks
  static Stream<List<Task>> getAllTasks() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Task.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get tasks by status
  static Stream<List<Task>> getTasksByStatus(String status) {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Task.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get tasks by priority
  static Stream<List<Task>> getTasksByPriority(String priority) {
    return _firestore
        .collection(_collection)
        .where('priority', isEqualTo: priority)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Task.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get tasks by project
  static Stream<List<Task>> getTasksByProject(String projectId) {
    return _firestore
        .collection(_collection)
        .where('projectId', isEqualTo: projectId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Task.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Update task
  static Future<void> updateTask(String taskId, Task task) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(taskId)
          .update(task.toMap());
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  // Update task status
  static Future<void> updateTaskStatus(String taskId, String status) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(taskId)
          .update({'status': status});
    } catch (e) {
      throw Exception('Failed to update task status: $e');
    }
  }

  // Delete task
  static Future<void> deleteTask(String taskId) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(taskId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  // Get task statistics
  static Future<Map<String, int>> getTaskStatistics() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection(_collection).get();
      
      Map<String, int> stats = {
        'total': 0,
        'completed': 0,
        'in_progress': 0,
        'pending': 0,
        'urgent': 0,
        'high': 0,
        'medium': 0,
        'low': 0,
      };

      for (QueryDocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        stats['total'] = (stats['total'] ?? 0) + 1;
        
        String status = data['status'] ?? 'pending';
        String priority = data['priority'] ?? 'medium';
        
        // Count by status
        if (status == 'completed') {
          stats['completed'] = (stats['completed'] ?? 0) + 1;
        } else if (status == 'in_progress') {
          stats['in_progress'] = (stats['in_progress'] ?? 0) + 1;
        } else {
          stats['pending'] = (stats['pending'] ?? 0) + 1;
        }
        
        // Count by priority
        stats[priority] = (stats[priority] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      throw Exception('Failed to get task statistics: $e');
    }
  }

  // Get tasks for a specific date
  static Stream<List<Task>> getTasksForDate(DateTime date) {
    DateTime startDate = DateTime(date.year, date.month, date.day);
    DateTime endDate = DateTime(date.year, date.month, date.day, 23, 59, 59);
    
    return _firestore
        .collection(_collection)
        .where('dueDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('dueDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('dueDate')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Task.fromMap(doc.data(), doc.id))
            .toList());
  }
}
