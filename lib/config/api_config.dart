class ApiConfig {
  // GreenAPI WhatsApp Configuration - YOUR ACTUAL CREDENTIALS
  static const String greenApiInstanceId = '7105307387';
  static const String greenApiAccessToken = 'YOUR_API_TOKEN_FROM_GREENAPI'; // Get this from your GreenAPI dashboard
  
  // EmailJS Configuration - YOUR ACTUAL CREDENTIALS  
  static const String emailJsServiceId = 'YOUR_SERVICE_ID'; // From EmailJS dashboard
  static const String emailJsTemplateId = 'YOUR_TEMPLATE_ID'; // Create welcome template
  static const String emailJsUserId = 'YOUR_USER_ID'; // From EmailJS account settings
  static const String emailJsAccessToken = 'YOUR_ACCESS_TOKEN'; // From EmailJS account settings
  
  // App Domain (for password reset links)
  static const String appDomain = 'https://tasksync-app.com';
  
  // Default country code for WhatsApp (Sri Lanka)
  static const String defaultCountryCode = '94';
  
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
