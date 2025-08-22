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
      print('📧 Starting email send process...');
      print('📧 EmailJS Config: Service=$_serviceId, Template=$_templateId');
      
      // EmailJS API endpoint
      const String url = 'https://api.emailjs.com/api/v1.0/email/send';

      // Current date formatting
      DateTime now = DateTime.now();
      String formattedDate = '${now.day}/${now.month}/${now.year}';

      // Email template parameters for EmailJS template_7vgqa7h
      Map<String, dynamic> templateParams = {
        'email': toEmail, // This matches {{email}} in your template
        'user_name': '$firstName $lastName',
        'first_name': firstName,
        'last_name': lastName,
        'phone_number': phoneNumber,
        'registration_date': formattedDate,
      };

      print('📧 Template params: $templateParams');

      // Request body for EmailJS API
      Map<String, dynamic> body = {
        'service_id': _serviceId,
        'template_id': _templateId,
        'user_id': _userId,
        'accessToken': _accessToken,
        'template_params': templateParams,
      };

      print('📧 Sending email to: $toEmail');

      // Send HTTP POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      print('📧 EmailJS Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('✅ Welcome email sent successfully to $toEmail');
        return true;
      } else {
        print('❌ Failed to send email: ${response.statusCode}');
        print('❌ Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending welcome email: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      return false;
    }
  }

  /// Test email service connection with real values
  static Future<bool> testEmailService({String? testEmail}) async {
    try {
      String email = testEmail ?? 'test@example.com';
      print('📧 Testing email service with: $email');
      
      bool result = await sendWelcomeEmail(
        toEmail: email,
        firstName: 'Test',
        lastName: 'User',
        phoneNumber: '+94123456789',
      );
      
      print('📧 Test result: ${result ? "SUCCESS" : "FAILED"}');
      return result;
    } catch (e) {
      print('📧 Email service test failed: $e');
      return false;
    }
  }

  /// Debug function to check configuration
  static void debugConfiguration() {
    print('📧 === EmailJS Configuration Debug ===');
    print('📧 Service ID: $_serviceId');
    print('📧 Template ID: $_templateId');
    print('📧 User ID: $_userId');
    print('📧 Access Token: ${_accessToken.substring(0, 5)}...');
    print('📧 =====================================');
  }
}
