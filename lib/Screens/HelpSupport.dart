import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D62ED),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Help & Support',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Get help and support for TaskSync',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 30),

            // FAQ Section
            _buildSectionHeader('Frequently Asked Questions'),
            const SizedBox(height: 15),
            
            _buildHelpOption(
              context,
              icon: Icons.quiz,
              title: 'How do I create a new project?',
              subtitle: 'Learn how to set up and manage projects',
              onTap: () => _showFAQDialog(context, 'Creating Projects', 'To create a new project, tap the + button on the Dashboard and fill in the project details including name, description, and team members.'),
            ),
            const SizedBox(height: 15),

            _buildHelpOption(
              context,
              icon: Icons.task,
              title: 'How do I manage tasks?',
              subtitle: 'Task creation and management guide',
              onTap: () => _showFAQDialog(context, 'Managing Tasks', 'You can create, edit, and delete tasks in the Task Manager. Use the Kanban board to track progress and move tasks between different stages.'),
            ),
            const SizedBox(height: 15),

            _buildHelpOption(
              context,
              icon: Icons.chat,
              title: 'How does team chat work?',
              subtitle: 'Communication and collaboration features',
              onTap: () => _showFAQDialog(context, 'Team Chat', 'Use the Chat tab to communicate with team members and project teams. You can send messages, share files, and collaborate in real-time.'),
            ),
            const SizedBox(height: 30),

            // Contact Support Section
            _buildSectionHeader('Contact Support'),
            const SizedBox(height: 15),

            _buildHelpOption(
              context,
              icon: Icons.email,
              title: 'Email Support',
              subtitle: 'support@tasksync.com',
              onTap: () => _showContactDialog(context, 'Email Support', 'Send us an email at support@tasksync.com and we\'ll get back to you within 24 hours.'),
            ),
            const SizedBox(height: 15),

            _buildHelpOption(
              context,
              icon: Icons.phone,
              title: 'Phone Support',
              subtitle: '+1 (555) 123-TASK',
              onTap: () => _showContactDialog(context, 'Phone Support', 'Call us at +1 (555) 123-TASK for immediate assistance. Available Monday-Friday, 9 AM - 6 PM EST.'),
            ),
            const SizedBox(height: 15),

            _buildHelpOption(
              context,
              icon: Icons.chat_bubble,
              title: 'Live Chat',
              subtitle: 'Chat with our support team',
              onTap: () => _showContactDialog(context, 'Live Chat', 'Start a live chat session with our support team. Available 24/7 for urgent issues.'),
            ),
            const SizedBox(height: 30),

            // Resources Section
            _buildSectionHeader('Resources'),
            const SizedBox(height: 15),

            _buildHelpOption(
              context,
              icon: Icons.book,
              title: 'User Manual',
              subtitle: 'Complete guide to using TaskSync',
              onTap: () => _showResourceDialog(context, 'User Manual', 'Download the complete TaskSync user manual with detailed instructions and best practices.'),
            ),
            const SizedBox(height: 15),

            _buildHelpOption(
              context,
              icon: Icons.video_library,
              title: 'Video Tutorials',
              subtitle: 'Watch step-by-step tutorials',
              onTap: () => _showResourceDialog(context, 'Video Tutorials', 'Access our library of video tutorials covering all TaskSync features and workflows.'),
            ),
            const SizedBox(height: 15),

            _buildHelpOption(
              context,
              icon: Icons.forum,
              title: 'Community Forum',
              subtitle: 'Connect with other TaskSync users',
              onTap: () => _showResourceDialog(context, 'Community Forum', 'Join our community forum to ask questions, share tips, and connect with other TaskSync users.'),
            ),
            const SizedBox(height: 30),

            // Feedback Section
            _buildSectionHeader('Feedback'),
            const SizedBox(height: 15),

            _buildHelpOption(
              context,
              icon: Icons.feedback,
              title: 'Send Feedback',
              subtitle: 'Help us improve TaskSync',
              onTap: () => _showFeedbackDialog(context),
            ),
            const SizedBox(height: 15),

            _buildHelpOption(
              context,
              icon: Icons.star,
              title: 'Rate the App',
              subtitle: 'Rate TaskSync in the app store',
              onTap: () => _showRatingDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF2D62ED),
      ),
    );
  }

  Widget _buildHelpOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF2D62ED).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF2D62ED)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF666666)),
          ],
        ),
      ),
    );
  }

  void _showFAQDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showContactDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Contact feature coming soon!'),
                  backgroundColor: Color(0xFF2D62ED),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D62ED),
            ),
            child: const Text('Contact', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showResourceDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Resource feature coming soon!'),
                  backgroundColor: Color(0xFF2D62ED),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D62ED),
            ),
            child: const Text('Access', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final feedbackController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('We value your feedback! Please share your thoughts about TaskSync.'),
            const SizedBox(height: 16),
            TextField(
              controller: feedbackController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Your feedback...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thank you for your feedback!'),
                  backgroundColor: Color(0xFF2D62ED),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D62ED),
            ),
            child: const Text('Send', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rate TaskSync'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enjoying TaskSync? Please rate us in the app store!'),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: Colors.amber, size: 30),
                Icon(Icons.star, color: Colors.amber, size: 30),
                Icon(Icons.star, color: Colors.amber, size: 30),
                Icon(Icons.star, color: Colors.amber, size: 30),
                Icon(Icons.star, color: Colors.amber, size: 30),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thank you for rating TaskSync!'),
                  backgroundColor: Color(0xFF2D62ED),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D62ED),
            ),
            child: const Text('Rate Now', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
