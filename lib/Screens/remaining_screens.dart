// Create Project Screen
import 'package:flutter/material.dart';

class CreateProjectScreen extends StatelessWidget {
  const CreateProjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Project')),
      body: const Center(child: Text('Create Project - Under Construction')),
    );
  }
}

// Add Team Members Screen
class AddTeamMembersScreen extends StatelessWidget {
  final String projectId;
  const AddTeamMembersScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Team Members')),
      body: const Center(child: Text('Add Team Members - Under Construction')),
    );
  }
}

// Kanban Board Screen
class KanbanBoardScreen extends StatelessWidget {
  final String projectId;
  const KanbanBoardScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kanban Board')),
      body: const Center(child: Text('Kanban Board - Under Construction')),
    );
  }
}

// Add Task Screen
class AddTaskScreen extends StatelessWidget {
  final String projectId;
  const AddTaskScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Task')),
      body: const Center(child: Text('Add Task - Under Construction')),
    );
  }
}

// Chat Screen
class ChatScreen extends StatelessWidget {
  final String recipientName;
  const ChatScreen({super.key, required this.recipientName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(recipientName)),
      body: const Center(child: Text('Chat - Under Construction')),
    );
  }
}

// Schedule Screen
class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),
      body: const Center(child: Text('Schedule - Under Construction')),
    );
  }
}

// Notification Settings Screen
class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      body: const Center(child: Text('Notification Settings - Under Construction')),
    );
  }
}

// About TaskSync Screen
class AboutTaskSyncScreen extends StatelessWidget {
  const AboutTaskSyncScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About TaskSync')),
      body: const Center(child: Text('About TaskSync - Under Construction')),
    );
  }
}

// Contact Support Screen
class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Support')),
      body: const Center(child: Text('Contact Support - Under Construction')),
    );
  }
}
