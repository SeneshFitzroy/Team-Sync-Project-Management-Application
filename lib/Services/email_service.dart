import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {
  // EmailJS Configuration
  // Replace these with your actual EmailJS credentials
  static const String _serviceId = 'YOUR_SERVICE_ID'; // Replace with your EmailJS service ID
  static const String _templateId = 'YOUR_TEMPLATE_ID'; // Replace with your EmailJS template ID
  static const String _userId = 'YOUR_USER_ID'; // Replace with your EmailJS user ID
  static const String _accessToken = 'YOUR_ACCESS_TOKEN'; // Replace with your EmailJS access token

  /// Send welcome email to new user
  static Future<bool> sendWelcomeEmail({
    required String toEmail,
    required String firstName,
    required String lastName,
  }) async {
    try {
      // EmailJS API endpoint
      const String url = 'https://api.emailjs.com/api/v1.0/email/send';

      // Email template parameters
      Map<String, dynamic> templateParams = {
        'to_email': toEmail,
        'to_name': '$firstName $lastName',
        'first_name': firstName,
        'last_name': lastName,
        'subject': 'Welcome to TaskSync - Your Account is Ready! 🎉',
        'message': '''
Hello $firstName,

Welcome to TaskSync! 🎉

We're thrilled to have you join our community of productive professionals and teams.

Your account has been successfully created with the following details:
• Name: $firstName $lastName
• Email: $toEmail
• Account Status: Active ✅

What's next?
1. ✅ Verify your email address (check your inbox)
2. 🚀 Complete your profile setup
3. 📋 Create your first project
4. 👥 Invite team members to collaborate

Key Features Waiting for You:
• 📊 Project Management Dashboard
• ⏰ Task Scheduling & Deadlines
• 👥 Team Collaboration Tools
• 📈 Progress Tracking & Reports
• 🔔 Smart Notifications
• 📱 Cross-platform Access

Need Help Getting Started?
• 📚 Check our Quick Start Guide
• 💬 Join our Community Forum
• 📧 Contact Support: support@tasksync.com
• 📞 Call us: +1-800-TASKSYNC

Thank you for choosing TaskSync to power your productivity!

Best regards,
The TaskSync Team

---
Follow us on social media:
🐦 Twitter: @TaskSyncApp
📘 Facebook: TaskSync Official
💼 LinkedIn: TaskSync

This email was sent because you recently created a TaskSync account.
If you didn't create this account, please contact our support team immediately.
        ''',
      };

      // Request body
      Map<String, dynamic> body = {
        'service_id': _serviceId,
        'template_id': _templateId,
        'user_id': _userId,
        'accessToken': _accessToken,
        'template_params': templateParams,
      };

      // Send HTTP POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('Welcome email sent successfully to $toEmail');
        return true;
      } else {
        print('Failed to send email: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending welcome email: $e');
      return false;
    }
  }

  /// Send password reset email
  static Future<bool> sendPasswordResetEmail({
    required String toEmail,
    required String resetLink,
    required String firstName,
  }) async {
    try {
      const String url = 'https://api.emailjs.com/api/v1.0/email/send';

      Map<String, dynamic> templateParams = {
        'to_email': toEmail,
        'to_name': firstName,
        'first_name': firstName,
        'reset_link': resetLink,
        'subject': 'Reset Your TaskSync Password 🔐',
        'message': '''
Hello $firstName,

We received a request to reset your password for your TaskSync account.

If you requested this password reset, please click the link below to create a new password:

🔗 Reset Password: $resetLink

This link will expire in 1 hour for security reasons.

If you didn't request this password reset:
• You can safely ignore this email
• Your password will remain unchanged
• Consider updating your account security

For your security:
• Never share your password with anyone
• Use a strong, unique password
• Enable two-factor authentication

Need help? Contact our support team:
📧 support@tasksync.com
📞 +1-800-TASKSYNC

Best regards,
The TaskSync Security Team

---
This is an automated security email from TaskSync.
        ''',
      };

      Map<String, dynamic> body = {
        'service_id': _serviceId,
        'template_id': _templateId,
        'user_id': _userId,
        'accessToken': _accessToken,
        'template_params': templateParams,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error sending password reset email: $e');
      return false;
    }
  }
}
