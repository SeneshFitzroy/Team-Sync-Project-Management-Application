import '../models/task.dart';
import '../models/project.dart';
import '../Services/task_service.dart';
import '../Services/project_service.dart';

class DataSeeder {
  static Future<void> seedSampleData() async {
    try {
      // Create sample projects
      await _createSampleProjects();
      
      // Create sample tasks
      await _createSampleTasks();
      
      print('Sample data seeded successfully!');
    } catch (e) {
      print('Error seeding sample data: $e');
    }
  }

  static Future<void> _createSampleProjects() async {
    final projects = [
      Project(
        name: 'Mobile App Development',
        description: 'TaskSync mobile application development with Flutter',
        status: 'in_progress',
        progress: 0.75,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        dueDate: DateTime.now().add(const Duration(days: 30)),
        teamMembers: ['user1', 'user2', 'user3'],
        ownerId: 'current_user',
      ),
      Project(
        name: 'Website Redesign',
        description: 'Complete redesign of the company website with modern UI/UX',
        status: 'in_progress',
        progress: 0.45,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        dueDate: DateTime.now().add(const Duration(days: 45)),
        teamMembers: ['user2', 'user4'],
        ownerId: 'current_user',
      ),
      Project(
        name: 'Marketing Campaign',
        description: 'Q4 marketing campaign for product launch',
        status: 'active',
        progress: 0.30,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        dueDate: DateTime.now().add(const Duration(days: 60)),
        teamMembers: ['user3', 'user5'],
        ownerId: 'current_user',
      ),
      Project(
        name: 'Database Migration',
        description: 'Migrate legacy database to cloud infrastructure',
        status: 'completed',
        progress: 1.0,
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        dueDate: DateTime.now().subtract(const Duration(days: 10)),
        teamMembers: ['user1', 'user4'],
        ownerId: 'current_user',
      ),
    ];

    for (final project in projects) {
      await ProjectService.createProject(project);
    }
  }

  static Future<void> _createSampleTasks() async {
    final tasks = [
      Task(
        title: 'Design Login Screen',
        description: 'Create the login screen UI with modern design patterns',
        priority: 'high',
        status: 'completed',
        dueDate: DateTime.now().subtract(const Duration(days: 2)),
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        assignedTo: 'user1',
      ),
      Task(
        title: 'Implement Authentication',
        description: 'Set up Firebase authentication for user login/signup',
        priority: 'urgent',
        status: 'in_progress',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        assignedTo: 'user2',
      ),
      Task(
        title: 'Create Task Dashboard',
        description: 'Build the main dashboard for task management',
        priority: 'high',
        status: 'in_progress',
        dueDate: DateTime.now().add(const Duration(days: 3)),
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        assignedTo: 'user1',
      ),
      Task(
        title: 'Database Schema Design',
        description: 'Design the database schema for tasks and projects',
        priority: 'medium',
        status: 'completed',
        dueDate: DateTime.now().subtract(const Duration(days: 5)),
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        assignedTo: 'user3',
      ),
      Task(
        title: 'API Integration',
        description: 'Integrate with third-party APIs for notifications',
        priority: 'medium',
        status: 'pending',
        dueDate: DateTime.now().add(const Duration(days: 7)),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        assignedTo: 'user2',
      ),
      Task(
        title: 'User Testing',
        description: 'Conduct user testing sessions and gather feedback',
        priority: 'low',
        status: 'pending',
        dueDate: DateTime.now().add(const Duration(days: 14)),
        createdAt: DateTime.now(),
        assignedTo: 'user4',
      ),
      Task(
        title: 'Performance Optimization',
        description: 'Optimize app performance and reduce loading times',
        priority: 'medium',
        status: 'pending',
        dueDate: DateTime.now().add(const Duration(days: 10)),
        createdAt: DateTime.now(),
        assignedTo: 'user1',
      ),
      Task(
        title: 'Security Audit',
        description: 'Perform comprehensive security audit of the application',
        priority: 'high',
        status: 'pending',
        dueDate: DateTime.now().add(const Duration(days: 5)),
        createdAt: DateTime.now(),
        assignedTo: 'user3',
      ),
      Task(
        title: 'Documentation',
        description: 'Create comprehensive documentation for the API',
        priority: 'low',
        status: 'pending',
        dueDate: DateTime.now().add(const Duration(days: 21)),
        createdAt: DateTime.now(),
        assignedTo: 'user4',
      ),
      Task(
        title: 'Code Review',
        description: 'Review and refactor critical code sections',
        priority: 'medium',
        status: 'in_progress',
        dueDate: DateTime.now().add(const Duration(days: 2)),
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        assignedTo: 'user2',
      ),
    ];

    for (final task in tasks) {
      await TaskService.createTask(task);
    }
  }
}
