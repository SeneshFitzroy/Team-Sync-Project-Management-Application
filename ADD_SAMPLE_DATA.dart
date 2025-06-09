import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Check if user is authenticated
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    print('❌ ERROR: No user is currently logged in.');
    print('Please login to your app first, then run this script.');
    return;
  }
  
  print('✅ User authenticated: ${user.email}');
  print('🔄 Adding sample data...');
  
  await addSampleData(user.uid);
  
  print('🎉 Sample data added successfully!');
  print('You can now refresh your app to see the sample projects and tasks.');
}

Future<void> addSampleData(String userId) async {
  final firestore = FirebaseFirestore.instance;
  
  // Sample projects data
  final projects = [
    {
      'title': 'Team Sync Mobile App',
      'description': 'A comprehensive project management application for teams',
      'status': 'active',
      'progress': 0.75,
      'members': [userId],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'ownerId': userId,
    },
    {
      'title': 'E-Commerce Website',
      'description': 'Building a modern e-commerce platform with React and Node.js',
      'status': 'active',
      'progress': 0.45,
      'members': [userId],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'ownerId': userId,
    },
    {
      'title': 'Marketing Campaign Q2',
      'description': 'Social media marketing campaign for Q2 product launch',
      'status': 'at-risk',
      'progress': 0.30,
      'members': [userId],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'ownerId': userId,
    },
    {
      'title': 'Database Migration',
      'description': 'Migrating legacy database to cloud infrastructure',
      'status': 'completed',
      'progress': 1.0,
      'members': [userId],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'ownerId': userId,
    },
  ];
  
  // Add projects to user's collection
  final projectIds = <String>[];
  for (var projectData in projects) {
    final docRef = await firestore
        .collection('users')
        .doc(userId)
        .collection('projects')
        .add(projectData);
    projectIds.add(docRef.id);
    print('✅ Added project: ${projectData['title']}');
  }
  
  // Sample tasks data
  final tasks = [
    {
      'taskName': 'Design User Interface',
      'projectName': 'Team Sync Mobile App',
      'projectId': projectIds[0],
      'status': 'In Progress',
      'priority': 'High',
      'assignee': 'Me',
      'dueDate': '2025-06-15',
      'createdBy': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'taskName': 'Implement Authentication',
      'projectName': 'Team Sync Mobile App',
      'projectId': projectIds[0],
      'status': 'Completed',
      'priority': 'High',
      'assignee': 'Me',
      'dueDate': '2025-06-12',
      'createdBy': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'taskName': 'Setup Database Schema',
      'projectName': 'E-Commerce Website',
      'projectId': projectIds[1],
      'status': 'To Do',
      'priority': 'Medium',
      'assignee': 'Me',
      'dueDate': '2025-06-20',
      'createdBy': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'taskName': 'Create Product Catalog',
      'projectName': 'E-Commerce Website',
      'projectId': projectIds[1],
      'status': 'In Progress',
      'priority': 'Medium',
      'assignee': 'Me',
      'dueDate': '2025-06-18',
      'createdBy': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'taskName': 'Plan Social Media Content',
      'projectName': 'Marketing Campaign Q2',
      'projectId': projectIds[2],
      'status': 'To Do',
      'priority': 'Low',
      'assignee': 'Me',
      'dueDate': '2025-06-25',
      'createdBy': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'taskName': 'Review Personal Goals',
      'projectName': 'Personal',
      'status': 'To Do',
      'priority': 'Low',
      'assignee': 'Me',
      'dueDate': '2025-06-14',
      'category': 'personal',
      'createdBy': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'taskName': 'Exercise Routine',
      'projectName': 'Personal',
      'status': 'In Progress',
      'priority': 'Medium',
      'assignee': 'Me',
      'dueDate': '2025-06-11',
      'category': 'health',
      'createdBy': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
  ];
  
  // Add tasks to user's collection
  for (var taskData in tasks) {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .add(taskData);
    print('✅ Added task: ${taskData['taskName']}');
  }
  
  // Add some sample activities
  final activities = [
    {
      'type': 'project_created',
      'description': 'Created project "Team Sync Mobile App"',
      'projectId': projectIds[0],
      'projectTitle': 'Team Sync Mobile App',
      'timestamp': FieldValue.serverTimestamp(),
      'userId': userId,
    },
    {
      'type': 'task_completed',
      'description': 'Completed task "Implement Authentication"',
      'projectId': projectIds[0],
      'projectTitle': 'Team Sync Mobile App',
      'timestamp': FieldValue.serverTimestamp(),
      'userId': userId,
    },
    {
      'type': 'project_created',
      'description': 'Created project "E-Commerce Website"',
      'projectId': projectIds[1],
      'projectTitle': 'E-Commerce Website',
      'timestamp': FieldValue.serverTimestamp(),
      'userId': userId,
    },
  ];
  
  // Add activities to user's collection
  for (var activityData in activities) {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('activities')
        .add(activityData);
    print('✅ Added activity: ${activityData['description']}');
  }
}
