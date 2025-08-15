import 'package:flutter/material.dart';

class TaskManagementScreen extends StatelessWidget {
  final String projectId;
  const TaskManagementScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Management')),
      body: const Center(child: Text('Task Management - Under Construction')),
    );
  }
}
