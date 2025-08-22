import 'dart:convert';
import 'package:http/http.dart' as http;

class BackupEmailService {
  /// Send simple welcome email using a different service
  static Future<bool> sendSimpleWelcomeEmail({
    required String toEmail,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    try {
      // Using EmailJS with a simple text template as backup
      const String url = 'https://api.emailjs.com/api/v1.0/email/send';
      
      // Simple email content as fallback
      String emailContent = '''
Welcome to TaskSync, $firstName!

Your account has been successfully created.

Account Details:
• Name: $firstName $lastName
• Email: $toEmail
• Phone: $phoneNumber
• Registration Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}

Thank you for joining TaskSync!

Best regards,
The TaskSync Team
      ''';

      Map<String, dynamic> templateParams = {
        'to_name': firstName,
        'to_email': toEmail,
        'from_name': 'TaskSync Team',
        'message': emailContent,
        'subject': 'Welcome to TaskSync - Account Created Successfully!',
      };

      Map<String, dynamic> body = {
        'service_id': 'service_xtlfp5m',
        'template_id': 'template_contact', // Default contact template
        'user_id': 'dz8xtM4ALRHVg9HBj',
        'accessToken': 'C_XRQslKP7-eO_LUr5MHN',
        'template_params': templateParams,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('✅ Backup email sent successfully to $toEmail');
        return true;
      } else {
        print('❌ Backup email failed: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending backup email: $e');
      return false;
    }
  }

  /// Send email using simple HTTP request (Gmail SMTP alternative)
  static Future<bool> sendPlainTextEmail({
    required String toEmail,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    try {
      // Simple console log for now
      print('📧 WELCOME EMAIL for $firstName $lastName');
      print('📧 To: $toEmail');
      print('📧 Phone: $phoneNumber');
      print('📧 Account created successfully at ${DateTime.now()}');
      
      // In a real app, you would integrate with SendGrid, Mailgun, etc.
      // For now, return true to simulate success
      return true;
    } catch (e) {
      print('❌ Error sending plain text email: $e');
      return false;
    }
  }
}
