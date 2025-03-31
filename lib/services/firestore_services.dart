import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Screens/TaskManager.dart'; // Import your Task model

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a task to Firestore
  Future<void> addTask(Task task) async {
    await _firestore.collection('tasks').add({
      'projectName': task.projectName,
      'taskName': task.taskName,
      'status': task.status,
      'dueDate': task.dueDate,
      'priority': task.priority,
      'priorityColor': task.priorityColor.value,
      'assignee': task.assignee,
      'statusColor': task.statusColor.value,
    });
  }

  // Fetch tasks from Firestore
  Stream<List<Task>> getTasks() {
    return _firestore.collection('tasks').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Task(
          projectName: data['projectName'] ?? '',
          taskName: data['taskName'] ?? '',
          status: data['status'] ?? '',
          dueDate: data['dueDate'] ?? '',
          priority: data['priority'] ?? '',
          priorityColor: Color(data['priorityColor'] ?? 0xFFCCCCCC),
          assignee: data['assignee'] ?? '',
          statusColor: Color(data['statusColor'] ?? 0xFFCCCCCC),
        );
      }).toList();
    });
  }

  // Update a task in Firestore
  Future<void> updateTask(String taskId, Task task) async {
    await _firestore.collection('tasks').doc(taskId).update({
      'projectName': task.projectName,
      'taskName': task.taskName,
      'status': task.status,
      'dueDate': task.dueDate,
      'priority': task.priority,
      'priorityColor': task.priorityColor.value,
      'assignee': task.assignee,
      'statusColor': task.statusColor.value,
    });
  }

  // Delete a task from Firestore
  Future<void> deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }
}