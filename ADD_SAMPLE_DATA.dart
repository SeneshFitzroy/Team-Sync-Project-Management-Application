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
  print('🔄 Adding comprehensive sample data...');
  
  await addComprehensiveSampleData(user.uid);
  
  print('🎉 Sample data added successfully!');
  print('Refresh your app to see the sample projects, tasks, and team members.');
}

Future<void> addComprehensiveSampleData(String userId) async {
  final firestore = FirebaseFirestore.instance;
  
  // Add sample users for team collaboration
  await addSampleUsers(firestore);
  
  // Add projects with comprehensive data
  await addSampleProjects(firestore, userId);
  
  // Add tasks across different projects
  await addSampleTasks(firestore, userId);
  
  // Add activity logs
  await addSampleActivities(firestore, userId);
}

Future<void> addSampleUsers(FirebaseFirestore firestore) async {
  final sampleUsers = [
    {
      'uid': 'user_sarah_chen',
      'email': 'sarah.chen@example.com',
      'displayName': 'Sarah Chen',
      'role': 'UI/UX Designer',
      'department': 'Design',
      'avatarUrl': '',
      'isActive': true,
      'joinedAt': FieldValue.serverTimestamp(),
    },
    {
      'uid': 'user_mike_peters',
      'email': 'mike.peters@example.com',
      'displayName': 'Mike Peters',
      'role': 'Product Manager',
      'department': 'Product',
      'avatarUrl': '',
      'isActive': true,
      'joinedAt': FieldValue.serverTimestamp(),
    },
    {
      'uid': 'user_anna_smith',
      'email': 'anna.smith@example.com',
      'displayName': 'Anna Smith',
      'role': 'Full Stack Developer',
      'department': 'Engineering',
      'avatarUrl': '',
      'isActive': true,
      'joinedAt': FieldValue.serverTimestamp(),
    },
    {
      'uid': 'user_james_wilson',
      'email': 'james.wilson@example.com',
      'displayName': 'James Wilson',
      'role': 'Marketing Lead',
      'department': 'Marketing',
      'avatarUrl': '',
      'isActive': true,
      'joinedAt': FieldValue.serverTimestamp(),
    },
    {
      'uid': 'user_elena_rodriguez',
      'email': 'elena.rodriguez@example.com',
      'displayName': 'Elena Rodriguez',
      'role': 'Data Analyst',
      'department': 'Analytics',
      'avatarUrl': '',
      'isActive': true,
      'joinedAt': FieldValue.serverTimestamp(),
    },
  ];
  
  for (var userData in sampleUsers) {
    await firestore.collection('users').doc(userData['uid'] as String).set(userData);
    print('✅ Added user: ${userData['displayName']}');
  }
}

Future<void> addSampleProjects(FirebaseFirestore firestore, String userId) async {
  // Sample projects data with comprehensive information
  final projects = [
    {
      'title': 'Team Sync Mobile App',
      'description': 'A comprehensive project management application for teams with real-time collaboration features',
      'status': 'active',
      'progress': 0.75,
      'priority': 'high',
      'budget': 50000.0,
      'startDate': '2025-05-01',
      'endDate': '2025-08-15',
      'members': [userId, 'user_sarah_chen', 'user_anna_smith'],
      'tags': ['mobile', 'flutter', 'firebase'],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'ownerId': userId,
    },
    {
      'title': 'E-Commerce Platform',
      'description': 'Building a modern e-commerce platform with React frontend and Node.js backend',
      'status': 'active',
      'progress': 0.45,
      'priority': 'high',
      'budget': 75000.0,
      'startDate': '2025-04-15',
      'endDate': '2025-10-30',
      'members': [userId, 'user_anna_smith', 'user_mike_peters'],
      'tags': ['web', 'react', 'nodejs', 'ecommerce'],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'ownerId': userId,
    },
    {
      'title': 'Marketing Campaign Q3',
      'description': 'Comprehensive social media marketing campaign for Q3 product launch across multiple platforms',
      'status': 'at-risk',
      'progress': 0.30,
      'priority': 'medium',
      'budget': 25000.0,
      'startDate': '2025-06-01',
      'endDate': '2025-09-30',
      'members': [userId, 'user_james_wilson', 'user_elena_rodriguez'],
      'tags': ['marketing', 'social-media', 'campaign'],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'ownerId': userId,
    },
    {
      'title': 'Database Migration',
      'description': 'Migrating legacy database infrastructure to modern cloud-based solutions',
      'status': 'completed',
      'progress': 1.0,
      'priority': 'low',
      'budget': 30000.0,
      'startDate': '2025-02-01',
      'endDate': '2025-05-15',
      'members': [userId, 'user_anna_smith'],
      'tags': ['database', 'migration', 'cloud'],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'ownerId': userId,
    },
  ];
  
  // Add projects to both user's collection and global collection for flexibility
  final projectIds = <String>[];
  for (var projectData in projects) {
    // Add to user's collection
    final userDocRef = await firestore
        .collection('users')
        .doc(userId)
        .collection('projects')
        .add(projectData);
    
    // Also add to global projects collection for team access
    final globalDocRef = await firestore
        .collection('projects')
        .add({...projectData, 'userProjectId': userDocRef.id});
    
    projectIds.add(userDocRef.id);
    print('✅ Added project: ${projectData['title']}');
  }
}

Future<void> addSampleTasks(FirebaseFirestore firestore, String userId) async {
  // Get project IDs for task assignment
  final userProjects = await firestore
      .collection('users')
      .doc(userId)
      .collection('projects')
      .get();
  
  if (userProjects.docs.isEmpty) {
    print('⚠️ No projects found for task creation');
    return;
  }
  
  final projectIds = userProjects.docs.map((doc) => doc.id).toList();
  final projectTitles = userProjects.docs.map((doc) => doc.data()['title'] as String).toList();
  
  // Sample tasks data
  final tasks = [
    {
      'taskName': 'Design User Interface Mockups',
      'projectName': projectTitles.isNotEmpty ? projectTitles[0] : 'Team Sync Mobile App',
      'projectId': projectIds.isNotEmpty ? projectIds[0] : '',
      'status': 'In Progress',
      'priority': 'High',
      'assignee': 'Sarah Chen',
      'assigneeEmail': 'sarah.chen@example.com',
      'dueDate': '2025-06-20',
      'estimatedHours': 24,
      'actualHours': 16,
      'description': 'Create comprehensive UI mockups for the mobile application including all main screens',
      'tags': ['design', 'ui', 'mockups'],
      'createdBy': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'taskName': 'Implement Firebase Authentication',
      'projectName': projectTitles.isNotEmpty ? projectTitles[0] : 'Team Sync Mobile App',
      'projectId': projectIds.isNotEmpty ? projectIds[0] : '',
      'status': 'Completed',
      'priority': 'High',
      'assignee': 'Anna Smith',
      'assigneeEmail': 'anna.smith@example.com',
      'dueDate': '2025-06-12',
      'estimatedHours': 16,
      'actualHours': 18,
      'description': 'Set up secure user authentication using Firebase Auth with email/password',
      'tags': ['backend', 'authentication', 'firebase'],
      'createdBy': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'taskName': 'Setup Database Schema',
      'projectName': projectTitles.length > 1 ? projectTitles[1] : 'E-Commerce Platform',
      'projectId': projectIds.length > 1 ? projectIds[1] : '',
      'status': 'To Do',
      'priority': 'Medium',
      'assignee': 'Anna Smith',
      'assigneeEmail': 'anna.smith@example.com',
      'dueDate': '2025-06-25',
      'estimatedHours': 20,
      'actualHours': 0,
      'description': 'Design and implement the database schema for the e-commerce platform',
      'tags': ['database', 'schema', 'backend'],
      'createdBy': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'taskName': 'Create Product Catalog API',
      'projectName': projectTitles.length > 1 ? projectTitles[1] : 'E-Commerce Platform',
      'projectId': projectIds.length > 1 ? projectIds[1] : '',
      'status': 'In Progress',
      'priority': 'Medium',
      'assignee': 'Mike Peters',
      'assigneeEmail': 'mike.peters@example.com',
      'dueDate': '2025-06-22',
      'estimatedHours': 32,
      'actualHours': 12,
      'description': 'Develop RESTful API endpoints for product catalog management',
      'tags': ['api', 'backend', 'products'],
      'createdBy': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'taskName': 'Plan Social Media Content',
      'projectName': projectTitles.length > 2 ? projectTitles[2] : 'Marketing Campaign Q3',
      'projectId': projectIds.length > 2 ? projectIds[2] : '',
      'status': 'To Do',
      'priority': 'Low',
      'assignee': 'James Wilson',
      'assigneeEmail': 'james.wilson@example.com',
      'dueDate': '2025-06-30',
      'estimatedHours': 40,
      'actualHours': 0,
      'description': 'Create content calendar and plan social media posts for Q3 campaign',
      'tags': ['marketing', 'content', 'social-media'],
      'createdBy': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    // Personal tasks
    {
      'taskName': 'Review Personal Development Goals',
      'projectName': 'Personal',
      'status': 'To Do',
      'priority': 'Low',
      'assignee': 'Me',
      'assigneeEmail': FirebaseAuth.instance.currentUser?.email ?? '',
      'dueDate': '2025-06-18',
      'estimatedHours': 2,
      'actualHours': 0,
      'category': 'personal',
      'description': 'Review and update personal development goals for Q3',
      'tags': ['personal', 'goals', 'development'],
      'createdBy': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'taskName': 'Weekly Exercise Routine',
      'projectName': 'Personal',
      'status': 'In Progress',
      'priority': 'Medium',
      'assignee': 'Me',
      'assigneeEmail': FirebaseAuth.instance.currentUser?.email ?? '',
      'dueDate': '2025-06-15',
      'estimatedHours': 5,
      'actualHours': 3,
      'category': 'health',
      'description': 'Maintain consistent weekly exercise routine',
      'tags': ['personal', 'health', 'exercise'],
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
}

Future<void> addSampleActivities(FirebaseFirestore firestore, String userId) async {
  final activities = [
    {
      'type': 'project_created',
      'description': 'Created project "Team Sync Mobile App"',
      'details': 'New project initialized with team members and timeline',
      'timestamp': FieldValue.serverTimestamp(),
      'userId': userId,
    },
    {
      'type': 'task_completed',
      'description': 'Completed task "Implement Firebase Authentication"',
      'details': 'Authentication system is now fully functional',
      'timestamp': FieldValue.serverTimestamp(),
      'userId': userId,
    },
    {
      'type': 'team_member_added',
      'description': 'Added Sarah Chen to Team Sync Mobile App',
      'details': 'New team member joined with UI Designer role',
      'timestamp': FieldValue.serverTimestamp(),
      'userId': userId,
    },
    {
      'type': 'project_progress_updated',
      'description': 'Updated Team Sync Mobile App progress to 75%',
      'details': 'Significant milestone reached in development',
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
