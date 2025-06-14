import 'package:flutter/material.dart';

// Simple TaskManager for testing
class TaskManager extends StatefulWidget {
  final String? selectedProject;
  final Color? projectColor;
  final double? projectProgress;
  final String? projectMembers;
  final String? projectStatus;

  const TaskManager({
    super.key,
    this.selectedProject,
    this.projectColor,
    this.projectProgress,
    this.projectMembers,
    this.projectStatus,
  });

  @override
  State<TaskManager> createState() => _TaskManagerState();
}

class _TaskManagerState extends State<TaskManager> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        backgroundColor: const Color(0xFF192F5D),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 64, color: Color(0xFF192F5D)),
            SizedBox(height: 16),
            Text(
              'Task Manager',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF192F5D),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Loading full task management functionality...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
