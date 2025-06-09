import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    print('❌ ERROR: Please login to your app first!');
    return;
  }
  
  print('✅ User authenticated: ${user.email}');
  print('🔄 Adding comprehensive sample data with real team members...');
  
  await addRealTeamData(user.uid);
  
  print('🎉 Sample data with real team members added successfully!');
  print('Refresh your app to see the enhanced data!');
}

Future<void> addRealTeamData(String userId) async {
  final firestore = FirebaseFirestore.instance;
  
  // Add real team members to the users collection
  final realTeamMembers = [
    {
      'email': 'sarah.chen@company.com',
      'displayName': 'Sarah Chen',
      'role': 'Senior UI/UX Designer',
      'department': 'Design Team',
      'profileImageUrl': '',
      'jobTitle': 'Senior UI/UX Designer',
      'isActive': true,
      'skills': ['UI Design', 'UX Research', 'Figma', 'Prototyping'],
      'joinedAt': FieldValue.serverTimestamp(),
      'lastActive': FieldValue.serverTimestamp(),
    },
    {
      'email': 'mike.peters@company.com',
      'displayName': 'Mike Peters',
      'role': 'Product Manager',
      'department': 'Product Team',
      'profileImageUrl': '',
      'jobTitle': 'Senior Product Manager',
      'isActive': true,
      'skills': ['Product Strategy', 'Agile', 'Analytics', 'Leadership'],
      'joinedAt': FieldValue.serverTimestamp(),
      'lastActive': FieldValue.serverTimestamp(),
    },
    {
      'email': 'anna.smith@company.com',
      'displayName': 'Anna Smith',
      'role': 'Full Stack Developer',
      'department': 'Engineering',
      'profileImageUrl': '',
      'jobTitle': 'Senior Full Stack Developer',
      'isActive': true,
      'skills': ['Flutter', 'Firebase', 'Node.js', 'React'],
      'joinedAt': FieldValue.serverTimestamp(),
      'lastActive': FieldValue.serverTimestamp(),
    },
    {
      'email': 'james.wilson@company.com',
      'displayName': 'James Wilson',
      'role': 'Marketing Lead',
      'department': 'Marketing',
      'profileImageUrl': '',
      'jobTitle': 'Digital Marketing Manager',
      'isActive': true,
      'skills': ['Digital Marketing', 'SEO', 'Content Strategy', 'Analytics'],
      'joinedAt': FieldValue.serverTimestamp(),
      'lastActive': FieldValue.serverTimestamp(),
    },
    {
      'email': 'elena.rodriguez@company.com',
      'displayName': 'Elena Rodriguez',
      'role': 'Data Analyst',
      'department': 'Data Science',
      'profileImageUrl': '',
      'jobTitle': 'Senior Data Analyst',
      'isActive': true,
      'skills': ['Data Analysis', 'SQL', 'Python', 'Tableau'],
      'joinedAt': FieldValue.serverTimestamp(),
      'lastActive': FieldValue.serverTimestamp(),
    },
    {
      'email': 'david.kim@company.com',
      'displayName': 'David Kim',
      'role': 'DevOps Engineer',
      'department': 'Engineering',
      'profileImageUrl': '',
      'jobTitle': 'Senior DevOps Engineer',
      'isActive': true,
      'skills': ['AWS', 'Docker', 'Kubernetes', 'CI/CD'],
      'joinedAt': FieldValue.serverTimestamp(),
      'lastActive': FieldValue.serverTimestamp(),
    },
  ];
  
  // Add team members to users collection
  for (var member in realTeamMembers) {
    final memberDoc = firestore.collection('users').doc();
    await memberDoc.set({
      ...member,
      'uid': memberDoc.id,
    });
    print('✅ Added team member: ${member['displayName']}');
  }
  
  // Create comprehensive projects with team assignments
  final projects = [
    {
      'title': 'Team Sync Mobile App',
      'description': 'A comprehensive project management application for teams with real-time collaboration, task tracking, and team communication features.',
      'status': 'active',
      'progress': 0.75,
      'priority': 'high',
      'budget': 75000.0,
      'startDate': '2025-05-01',
      'endDate': '2025-08-30',
      'color': 'blue',
      'tags': ['mobile', 'flutter', 'firebase', 'collaboration'],
      'members': [
        {'email': 'sarah.chen@company.com', 'role': 'UI/UX Designer'},
        {'email': 'anna.smith@company.com', 'role': 'Lead Developer'},
        {'email': 'mike.peters@company.com', 'role': 'Product Manager'},
      ],
      'milestones': [
        {'name': 'UI Design Complete', 'date': '2025-06-15', 'completed': true},
        {'name': 'Backend Integration', 'date': '2025-07-15', 'completed': false},
        {'name': 'Testing & Launch', 'date': '2025-08-30', 'completed': false},
      ],
      'ownerId': userId,
      'createdBy': FirebaseAuth.instance.currentUser?.email ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'title': 'E-Commerce Platform Redesign',
      'description': 'Complete redesign and development of the company e-commerce platform with modern UI, improved performance, and enhanced user experience.',
      'status': 'active',
      'progress': 0.45,
      'priority': 'high',
      'budget': 120000.0,
      'startDate': '2025-04-01',
      'endDate': '2025-10-31',
      'color': 'green',
      'tags': ['web', 'ecommerce', 'react', 'node.js'],
      'members': [
        {'email': 'anna.smith@company.com', 'role': 'Full Stack Developer'},
        {'email': 'sarah.chen@company.com', 'role': 'UI/UX Designer'},
        {'email': 'david.kim@company.com', 'role': 'DevOps Engineer'},
        {'email': 'elena.rodriguez@company.com', 'role': 'Data Analyst'},
      ],
      'milestones': [
        {'name': 'Design System', 'date': '2025-05-15', 'completed': true},
        {'name': 'Frontend Development', 'date': '2025-07-30', 'completed': false},
        {'name': 'Backend API', 'date': '2025-08-30', 'completed': false},
        {'name': 'Launch', 'date': '2025-10-31', 'completed': false},
      ],
      'ownerId': userId,
      'createdBy': FirebaseAuth.instance.currentUser?.email ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'title': 'Q3 Marketing Campaign',
      'description': 'Comprehensive digital marketing campaign for Q3 product launches across social media, email, and content marketing channels.',
      'status': 'at-risk',
      'progress': 0.30,
      'priority': 'medium',
      'budget': 45000.0,
      'startDate': '2025-06-01',
      'endDate': '2025-09-30',
      'color': 'orange',
      'tags': ['marketing', 'social-media', 'content', 'campaign'],
      'members': [
        {'email': 'james.wilson@company.com', 'role': 'Marketing Lead'},
        {'email': 'elena.rodriguez@company.com', 'role': 'Data Analyst'},
        {'email': 'sarah.chen@company.com', 'role': 'Creative Designer'},
      ],
      'milestones': [
        {'name': 'Campaign Strategy', 'date': '2025-06-15', 'completed': true},
        {'name': 'Content Creation', 'date': '2025-07-15', 'completed': false},
        {'name': 'Launch Phase 1', 'date': '2025-08-01', 'completed': false},
        {'name': 'Campaign Complete', 'date': '2025-09-30', 'completed': false},
      ],
      'ownerId': userId,
      'createdBy': FirebaseAuth.instance.currentUser?.email ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'title': 'Cloud Infrastructure Migration',
      'description': 'Migration of legacy systems to modern cloud infrastructure with improved security, scalability, and performance.',
      'status': 'completed',
      'progress': 1.0,
      'priority': 'high',
      'budget': 85000.0,
      'startDate': '2025-02-01',
      'endDate': '2025-05-31',
      'color': 'purple',
      'tags': ['infrastructure', 'cloud', 'migration', 'aws'],
      'members': [
        {'email': 'david.kim@company.com', 'role': 'Lead DevOps Engineer'},
        {'email': 'anna.smith@company.com', 'role': 'Backend Developer'},
        {'email': 'mike.peters@company.com', 'role': 'Technical PM'},
      ],
      'milestones': [
        {'name': 'Migration Plan', 'date': '2025-02-15', 'completed': true},
        {'name': 'Database Migration', 'date': '2025-03-31', 'completed': true},
        {'name': 'Application Migration', 'date': '2025-04-30', 'completed': true},
        {'name': 'Go Live', 'date': '2025-05-31', 'completed': true},
      ],
      'ownerId': userId,
      'createdBy': FirebaseAuth.instance.currentUser?.email ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
  ];
  
  // Add projects to both user collection and global collection
  for (var project in projects) {
    // Add to user's projects collection
    final userProjectRef = await firestore
        .collection('users')
        .doc(userId)
        .collection('projects')
        .add(project);
    
    // Add to global projects collection for team access
    await firestore
        .collection('projects')
        .doc(userProjectRef.id)
        .set({
      ...project,
      'projectId': userProjectRef.id,
      'teamAccess': true,
    });
    
    print('✅ Added project: ${project['title']}');
  }
  
  print('🎉 Added ${realTeamMembers.length} team members and ${projects.length} projects!');
  print('Your app now has realistic team collaboration data!');
}
