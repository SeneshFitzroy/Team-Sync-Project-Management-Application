import 'package:flutter/material.dart';
import 'package:fluttercomponenets/Services/firebase_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool emailNotifications = true;
  bool mobileNotifications = true;
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Listen to notifications from Firebase
      FirebaseService.getUserNotifications().listen((snapshot) {
        if (mounted) {
          setState(() {
            _notifications = snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return {
                'id': doc.id,
                'title': data['title'] ?? 'Notification',
                'message': data['message'] ?? '',
                'read': data['read'] ?? false,
                'createdAt': data['createdAt'],
                'type': data['type'] ?? 'info',
              };
            }).toList();
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load notifications: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      await FirebaseService.markNotificationAsRead(notificationId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to mark as read: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
      ),      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Recent Notifications Section
            const Text(
              'Recent Notifications',
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 15),
            
            // Notifications List
            Expanded(
              flex: 2,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _notifications.isEmpty
                      ? const Center(
                          child: Text(
                            'No notifications yet',
                            style: TextStyle(
                              color: Color(0xFF8A8888),
                              fontSize: 16,
                              fontFamily: 'Inter',
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _notifications.length,
                          itemBuilder: (context, index) {
                            final notification = _notifications[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: Icon(
                                  notification['read'] ? Icons.mail_outline : Icons.mail,
                                  color: notification['read'] ? Colors.grey : Colors.blue,
                                ),
                                title: Text(
                                  notification['title'],
                                  style: TextStyle(
                                    fontWeight: notification['read'] ? FontWeight.normal : FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(notification['message']),
                                onTap: () {
                                  if (!notification['read']) {
                                    _markAsRead(notification['id']);
                                  }
                                },
                              ),
                            );
                          },
                        ),
            ),
            
            const SizedBox(height: 20),
            const Divider(
              color: Color(0xFFA9A9A9),
              thickness: 1,
            ),
            const SizedBox(height: 20),
            
            // Settings Section
            const Text(
              'Notification Settings',
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 15),
            
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
            const SizedBox(height: 20),
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
