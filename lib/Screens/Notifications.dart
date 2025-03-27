import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool emailNotifications = true;
  bool mobileNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F8FF),
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD8DADC)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notifications Settings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            NotificationSection(
              title: 'Email Notification',
              subtitle: 'Received directly to your email',
              icon: Icons.email_outlined,
              isActive: emailNotifications,
              onChanged: (value) {
                setState(() {
                  emailNotifications = value;
                });
              },
            ),
            const Divider(
              color: Color(0xFFA9A9A9),
              thickness: 1,
              height: 40,
            ),
            NotificationSection(
              title: 'Mobile Notification',
              subtitle: 'Received directly to your device',
              icon: Icons.notifications_outlined,
              isActive: mobileNotifications,
              onChanged: (value) {
                setState(() {
                  mobileNotifications = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isActive;
  final Function(bool) onChanged;

  const NotificationSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isActive,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 24),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF8A8888),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: isActive,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: const Color(0xFF1449F0),
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: Colors.grey.shade300,
        ),
      ],
    );
  }
}
