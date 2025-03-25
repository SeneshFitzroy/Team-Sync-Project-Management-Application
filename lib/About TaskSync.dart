import 'package:flutter/material.dart';

void main() {
  runApp(const TaskSyncApp());
}

class TaskSyncApp extends StatelessWidget {
  const TaskSyncApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskSync',
      theme: ThemeData(
        primaryColor: const Color(0xFF1A365D),
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const AboutTaskSyncPage(),
    );
  }
}

class AboutTaskSyncPage extends StatelessWidget {
  const AboutTaskSyncPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'About TaskSync',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              title: 'Our Mission',
              content:
                  'TaskSync is dedicated to transforming the way teams collaborate and manage projects. We provide an intuitive platform that brings together task management, team communication, and project planning in one seamless experience.',
            ),
            const SizedBox(height: 16),
            _buildFeaturesSection(),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Version',
              content: 'TaskSync v2.0.1\nReleased: October 2023',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String content}) {
    return Card(
      elevation: 0,
      color: Colors.white, // Ensure the background is white
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A365D),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Card(
      elevation: 0,
      color: Colors.white, // Ensure the background is white
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Key Features',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A365D),
              ),
            ),
            const SizedBox(height: 16),
            const FeatureItem(
              icon: Icons.check_circle_outline,
              title: 'Task Management',
              description:
                  'Create, assign, and track tasks with ease. Set priorities and deadlines.',
            ),
            const SizedBox(height: 16),
            const FeatureItem(
              icon: Icons.chat_bubble_outline,
              title: 'Team Communication',
              description:
                  'Built-in messaging and collaboration tools keep your team connected.',
            ),
            const SizedBox(height: 16),
            const FeatureItem(
              icon: Icons.calendar_today,
              title: 'Project Planning',
              description:
                  'Powerful planning tools help you organize projects and set milestones.',
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const FeatureItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1A365D),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
