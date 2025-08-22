import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class WhatsAppService {
  // GreenAPI Configuration from config file
  static const String _instanceId = ApiConfig.greenApiInstanceId;
  static const String _accessToken = ApiConfig.greenApiAccessToken;
  static const String _baseUrl = 'https://api.green-api.com';

  /// Send WhatsApp welcome message to user
  static Future<bool> sendWelcomeMessage({
    required String phoneNumber,
    required String firstName,
    required String lastName,
  }) async {
    try {
      // Format phone number (remove + and ensure it starts with country code)
      String formattedPhone = phoneNumber.replaceAll('+', '').replaceAll(' ', '');
      if (!formattedPhone.startsWith(ApiConfig.defaultCountryCode) && !formattedPhone.startsWith('1')) {
        // Add default country code if missing
        formattedPhone = '${ApiConfig.defaultCountryCode}$formattedPhone';
      }

      // Ensure phone number has @c.us suffix for WhatsApp
      String chatId = '${formattedPhone}@c.us';

      // Welcome message content
      String message = '''
🎉 *Welcome to TaskSync!* 🎉

Hi $firstName $lastName! 👋

Thank you for joining TaskSync - your ultimate project management companion!

✅ Your account has been successfully created
📧 Check your email for verification
🚀 Start managing your projects efficiently

*What you can do with TaskSync:*
• Create and manage projects
• Collaborate with team members
• Track task progress
• Set deadlines and reminders
• Generate reports

Ready to boost your productivity? Let's get started! 💪

Best regards,
TaskSync Team

---
Need help? Reply to this message or contact support.
      ''';

      // API endpoint
      String url = '$_baseUrl/waInstance$_instanceId/sendMessage/$_accessToken';

      // Request body
      Map<String, dynamic> body = {
        'chatId': chatId,
        'message': message,
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
        print('WhatsApp message sent successfully to $phoneNumber');
        return true;
      } else {
        print('Failed to send WhatsApp message: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending WhatsApp message: $e');
      return false;
    }
  }

  /// Send a quick test message to verify API configuration
  static Future<bool> testConnection(String phoneNumber) async {
    try {
      String formattedPhone = phoneNumber.replaceAll('+', '').replaceAll(' ', '');
      if (!formattedPhone.startsWith(ApiConfig.defaultCountryCode) && !formattedPhone.startsWith('1')) {
        formattedPhone = '${ApiConfig.defaultCountryCode}$formattedPhone';
      }
      String chatId = '${formattedPhone}@c.us';

      String url = '$_baseUrl/waInstance$_instanceId/sendMessage/$_accessToken';

      Map<String, dynamic> body = {
        'chatId': chatId,
        'message': '🧪 TaskSync API Test - Connection successful! ✅',
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('WhatsApp test failed: $e');
      return false;
    }
  }
}
