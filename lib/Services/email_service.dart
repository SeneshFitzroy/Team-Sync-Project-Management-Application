import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class EmailService {
  // EmailJS Configuration from config file
  static const String _serviceId = ApiConfig.emailJsServiceId;
  static const String _templateId = ApiConfig.emailJsTemplateId;
  static const String _userId = ApiConfig.emailJsUserId;
  static const String _accessToken = ApiConfig.emailJsAccessToken;

  /// Send welcome email to new user
  static Future<bool> sendWelcomeEmail({
    required String toEmail,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    try {
      // EmailJS API endpoint
      const String url = 'https://api.emailjs.com/api/v1.0/email/send';

      // Current date formatting
      DateTime now = DateTime.now();
      String formattedDate = '${now.day}/${now.month}/${now.year}';

      // Email template parameters matching your EmailJS template
      Map<String, dynamic> templateParams = {
        'to_name': firstName,
        'to_email': toEmail,
        'firstName': firstName,
        'lastName': lastName,
        'email': toEmail,
        'phone': phoneNumber,
        'date': formattedDate,
      };

      // Request body for EmailJS API
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
        print('✅ Welcome email sent successfully to $toEmail');
        return true;
      } else {
        print('❌ Failed to send email: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending welcome email: $e');
      return false;
    }
  }

  /// Test email service connection
  static Future<bool> testEmailService() async {
    try {
      return await sendWelcomeEmail(
        toEmail: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        phoneNumber: '+94123456789',
      );
    } catch (e) {
      print('Email service test failed: $e');
      return false;
    }
  }
}

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
