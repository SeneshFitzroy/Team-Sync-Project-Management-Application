import 'package:flutter/material.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _taskReminders = true;
  bool _projectUpdates = true;
  bool _chatMessages = true;
  bool _weeklyReports = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

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
          'Notification Settings',
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
              'Configure your notification preferences',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 30),

            // General Notifications Section
            _buildSectionHeader('General Notifications'),
            const SizedBox(height: 15),
            
            _buildToggleOption(
              icon: Icons.notifications,
              title: 'Push Notifications',
              subtitle: 'Receive notifications on this device',
              value: _pushNotifications,
              onChanged: (value) {
                setState(() {
                  _pushNotifications = value;
                });
              },
            ),
            const SizedBox(height: 15),

            _buildToggleOption(
              icon: Icons.email,
              title: 'Email Notifications',
              subtitle: 'Receive notifications via email',
              value: _emailNotifications,
              onChanged: (value) {
                setState(() {
                  _emailNotifications = value;
                });
              },
            ),
            const SizedBox(height: 30),

            // Content Notifications Section
            _buildSectionHeader('Content Notifications'),
            const SizedBox(height: 15),

            _buildToggleOption(
              icon: Icons.task,
              title: 'Task Reminders',
              subtitle: 'Get notified about upcoming deadlines',
              value: _taskReminders,
              onChanged: (value) {
                setState(() {
                  _taskReminders = value;
                });
              },
            ),
            const SizedBox(height: 15),

            _buildToggleOption(
              icon: Icons.update,
              title: 'Project Updates',
              subtitle: 'Notifications when projects are updated',
              value: _projectUpdates,
              onChanged: (value) {
                setState(() {
                  _projectUpdates = value;
                });
              },
            ),
            const SizedBox(height: 15),

            _buildToggleOption(
              icon: Icons.chat,
              title: 'Chat Messages',
              subtitle: 'New messages from team members',
              value: _chatMessages,
              onChanged: (value) {
                setState(() {
                  _chatMessages = value;
                });
              },
            ),
            const SizedBox(height: 15),

            _buildToggleOption(
              icon: Icons.analytics,
              title: 'Weekly Reports',
              subtitle: 'Weekly summary of your activities',
              value: _weeklyReports,
              onChanged: (value) {
                setState(() {
                  _weeklyReports = value;
                });
              },
            ),
            const SizedBox(height: 30),

            // Sound & Vibration Section
            _buildSectionHeader('Sound & Vibration'),
            const SizedBox(height: 15),

            _buildToggleOption(
              icon: Icons.volume_up,
              title: 'Sound',
              subtitle: 'Play sound for notifications',
              value: _soundEnabled,
              onChanged: (value) {
                setState(() {
                  _soundEnabled = value;
                });
              },
            ),
            const SizedBox(height: 15),

            _buildToggleOption(
              icon: Icons.vibration,
              title: 'Vibration',
              subtitle: 'Vibrate for notifications',
              value: _vibrationEnabled,
              onChanged: (value) {
                setState(() {
                  _vibrationEnabled = value;
                });
              },
            ),
            const SizedBox(height: 30),

            // Do Not Disturb Section
            _buildSectionHeader('Do Not Disturb'),
            const SizedBox(height: 15),

            _buildActionOption(
              icon: Icons.schedule,
              title: 'Quiet Hours',
              subtitle: 'Set times when notifications are muted',
              onTap: () => _showQuietHoursDialog(),
            ),
            const SizedBox(height: 15),

            _buildActionOption(
              icon: Icons.notifications_off,
              title: 'Mute All Notifications',
              subtitle: 'Temporarily disable all notifications',
              onTap: () => _showMuteDialog(),
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

  Widget _buildToggleOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF2D62ED),
          ),
        ],
      ),
    );
  }

  Widget _buildActionOption({
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

  void _showQuietHoursDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quiet Hours'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Set the hours when you don\'t want to receive notifications.'),
            SizedBox(height: 16),
            Row(
              children: [
                Text('From: 10:00 PM'),
                Spacer(),
                Text('To: 8:00 AM'),
              ],
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
                  content: Text('Quiet hours feature coming soon!'),
                  backgroundColor: Color(0xFF2D62ED),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D62ED),
            ),
            child: const Text('Set Hours', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showMuteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mute All Notifications'),
        content: const Text('How long would you like to mute notifications?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications muted for 1 hour'),
                  backgroundColor: Color(0xFF2D62ED),
                ),
              );
            },
            child: const Text('1 Hour'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications muted for 8 hours'),
                  backgroundColor: Color(0xFF2D62ED),
                ),
              );
            },
            child: const Text('8 Hours'),
          ),
        ],
      ),
    );
  }
}
