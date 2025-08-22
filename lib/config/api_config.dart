class ApiConfig {
  // GreenAPI WhatsApp Configuration
  // IMPORTANT: Replace these with your actual GreenAPI credentials
  // Get them from: https://green-api.com/
  static const String greenApiInstanceId = 'YOUR_INSTANCE_ID'; // Example: '1101123456'
  static const String greenApiAccessToken = 'YOUR_ACCESS_TOKEN'; // Example: 'abc123def456...'
  
  // EmailJS Configuration  
  // IMPORTANT: Replace these with your actual EmailJS credentials
  // Get them from: https://emailjs.com/
  static const String emailJsServiceId = 'YOUR_SERVICE_ID'; // Example: 'service_abc123'
  static const String emailJsTemplateId = 'YOUR_TEMPLATE_ID'; // Example: 'template_def456'
  static const String emailJsUserId = 'YOUR_USER_ID'; // Example: 'user_ghi789'
  static const String emailJsAccessToken = 'YOUR_ACCESS_TOKEN'; // Example: 'jkl012mno345'
  
  // App Domain (for password reset links)
  static const String appDomain = 'https://your-app-domain.com';
  
  // Default country code for WhatsApp (change as needed)
  static const String defaultCountryCode = '94'; // Sri Lanka (+94)
  
  /*
  SETUP INSTRUCTIONS:
  
  1. GreenAPI Setup:
     - Go to https://green-api.com/
     - Create an account and get your instance
     - Replace greenApiInstanceId and greenApiAccessToken above
     - Test WhatsApp functionality
  
  2. EmailJS Setup:
     - Go to https://emailjs.com/
     - Create an account and email service
     - Create an email template for welcome/reset emails
     - Replace emailJs* values above
     - Test email functionality
  
  3. Domain Setup:
     - Replace appDomain with your actual domain
     - Configure password reset handling
  
  4. Country Code:
     - Update defaultCountryCode for your target country
  */
}
