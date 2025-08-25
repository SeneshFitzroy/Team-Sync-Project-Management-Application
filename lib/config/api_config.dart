class ApiConfig {
  // =================================================================
  // TASKSYNC PROJECT MANAGEMENT APPLICATION - TECHNOLOGY STACK
  // =================================================================
  
  /*
  🚀 FRONTEND & BACKEND:
  • Flutter (Dart) – Cross-platform development for Android, iOS, Web & Desktop
  • Responsive UI with Material Design components
  • State management with StatefulWidgets and Provider patterns
  • Real-time data binding and reactive programming
  
  🔥 DATABASE & BACKEND SERVICES:
  • Firebase Firestore – Real-time NoSQL database with offline support
  • Firebase Authentication – Secure user management and authentication
  • Firebase Storage – Cloud-based file and media storage
  • Real-time data synchronization across all devices
  
  🛠️ DEVELOPMENT TOOLS:
  • Figma – Professional UI/UX design and prototyping
  • GitHub – Version control, collaboration, and CI/CD
  • VS Code – Primary development environment
  • Android Studio – Mobile development and debugging
  
  📱 COMMUNICATION SERVICES:
  • EmailJS – Automated email notifications and welcome messages
  • Green API – WhatsApp messaging integration for user engagement
  • Multi-channel communication system
  */
  
  // =================================================================
  // API CONFIGURATIONS
  // =================================================================
  
  // GreenAPI WhatsApp Configuration - REPLACE WITH YOUR CREDENTIALS
  static const String greenApiInstanceId = 'YOUR_GREEN_API_INSTANCE_ID';
  static const String greenApiAccessToken = 'YOUR_GREEN_API_ACCESS_TOKEN';
  
  // EmailJS Configuration - REPLACE WITH YOUR CREDENTIALS  
  static const String emailJsServiceId = 'YOUR_EMAILJS_SERVICE_ID'; // Gmail service from your EmailJS
  static const String emailJsTemplateId = 'YOUR_EMAILJS_TEMPLATE_ID'; // YOUR ACTUAL TEMPLATE ID
  static const String emailJsUserId = 'YOUR_EMAILJS_USER_ID'; // From EmailJS account settings
  static const String emailJsAccessToken = 'YOUR_EMAILJS_ACCESS_TOKEN'; // From EmailJS account settings
  
  // App Domain (for password reset links)
  static const String appDomain = 'https://tasksync-app.com';
  
  // Default country code for WhatsApp (Sri Lanka)
  static const String defaultCountryCode = '94';
  
  // =================================================================
  // SETUP INSTRUCTIONS
  // =================================================================
  
  /*
  📋 COMPLETE SETUP GUIDE:
  
  1. 🟢 GreenAPI WhatsApp Setup:
     • Visit: https://green-api.com/
     • Create account and get your WhatsApp Business instance
     • Replace greenApiInstanceId and greenApiAccessToken above
     • Test WhatsApp messaging functionality
     • Configure webhook for message delivery status
  
  2. 📧 EmailJS Setup:
     • Visit: https://emailjs.com/
     • Create account and connect Gmail service
     • Create professional email templates for welcome/reset emails
     • Replace all emailJs* values above with your credentials
     • Test email delivery and template rendering
  
  3. 🌐 Domain Setup:
     • Replace appDomain with your production domain
     • Configure password reset link handling
     • Set up SSL certificates for secure communication
  
  4. 🌍 Localization:
     • Update defaultCountryCode for your target country
     • Configure regional phone number formatting
     • Set appropriate timezone and date formats
  
  5. 🔥 Firebase Configuration:
     • Ensure Firebase project is properly configured
     • Enable Firestore, Authentication, and Storage
     • Configure security rules for production
     • Set up backup and monitoring
  
  🎯 PRODUCTION CHECKLIST:
  ✅ All API keys configured and tested
  ✅ Firebase security rules implemented
  ✅ Email templates designed and tested
  ✅ WhatsApp business account verified
  ✅ Error handling and logging implemented
  ✅ Performance optimization completed
  ✅ Security audit passed
  */
}
