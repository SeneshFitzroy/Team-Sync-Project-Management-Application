class ApiConfig {
  // GreenAPI WhatsApp Configuration - YOUR ACTUAL CREDENTIALS
  static const String greenApiInstanceId = '7105307387';
  static const String greenApiAccessToken = '29158cf0aff0400f997dbe5fbe9d604e551b120d46814dcaa4';
  
  // EmailJS Configuration - YOUR ACTUAL CREDENTIALS  
  static const String emailJsServiceId = 'service_xtlfp5m'; // Gmail service from your EmailJS
  static const String emailJsTemplateId = 'template_welcome'; // Welcome template only
  static const String emailJsUserId = 'YOUR_USER_ID'; // Get from EmailJS account settings
  static const String emailJsAccessToken = 'YOUR_ACCESS_TOKEN'; // Get from EmailJS account settings
  
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
