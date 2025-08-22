# TaskSync WhatsApp & Email Integration Setup Guide

## 🎯 Overview
Your TaskSync app now includes:
- ✅ WhatsApp welcome messages via GreenAPI
- ✅ Email welcome messages via EmailJS  
- ✅ Firebase password reset functionality
- ✅ Phone number validation and storage
- ✅ Enhanced user registration with full contact details

## 🔧 Required Setup Steps

### 1. GreenAPI WhatsApp Setup

#### Step 1.1: Create GreenAPI Account
1. Go to [https://green-api.com/](https://green-api.com/)
2. Create a free account
3. Create a new WhatsApp instance
4. Get your **Instance ID** and **Access Token**

#### Step 1.2: Configure WhatsApp Instance
1. Scan QR code to link your WhatsApp number
2. Set instance state to "authorized"
3. Test the connection using the test endpoint

#### Step 1.3: Update Configuration
Open `lib/config/api_config.dart` and update:
```dart
static const String greenApiInstanceId = 'YOUR_INSTANCE_ID'; // e.g., '1101123456'
static const String greenApiAccessToken = 'YOUR_ACCESS_TOKEN'; // Long token string
```

### 2. EmailJS Email Setup

#### Step 2.1: Create EmailJS Account
1. Go to [https://emailjs.com/](https://emailjs.com/)
2. Create a free account (100 emails/month free)
3. Add an email service (Gmail, Outlook, etc.)

#### Step 2.2: Create Email Templates
Create two templates:

**Welcome Email Template:**
- Template ID: `template_welcome`
- Variables: `{{to_name}}`, `{{first_name}}`, `{{to_email}}`
- Subject: "Welcome to TaskSync - Your Account is Ready! 🎉"

**Password Reset Template:**
- Template ID: `template_reset`
- Variables: `{{to_name}}`, `{{first_name}}`, `{{reset_link}}`
- Subject: "Reset Your TaskSync Password 🔐"

#### Step 2.3: Update Configuration
Open `lib/config/api_config.dart` and update:
```dart
static const String emailJsServiceId = 'YOUR_SERVICE_ID'; // e.g., 'service_abc123'
static const String emailJsTemplateId = 'YOUR_TEMPLATE_ID'; // e.g., 'template_def456'
static const String emailJsUserId = 'YOUR_USER_ID'; // e.g., 'user_ghi789'
static const String emailJsAccessToken = 'YOUR_ACCESS_TOKEN'; // Private key
```

### 3. App Domain Configuration

Update your app domain in `lib/config/api_config.dart`:
```dart
static const String appDomain = 'https://your-actual-domain.com';
```

### 4. Country Code Setup

Update the default country code for your target audience:
```dart
static const String defaultCountryCode = '94'; // Change to your country code
```

## 📱 App Features

### New User Registration Flow:
1. User enters: First Name, Last Name, Email, Phone, Password
2. Creates Firebase Auth account
3. Stores user data in Firestore
4. Sends Firebase email verification
5. Sends WhatsApp welcome message via GreenAPI
6. Sends custom welcome email via EmailJS
7. Shows success with message status

### Password Reset Flow:
1. User enters email on forgot password screen
2. Sends Firebase password reset email
3. Sends custom reset email via EmailJS
4. Shows success confirmation

### User Data Structure (Firestore):
```json
{
  "uid": "firebase_user_id",
  "firstName": "John",
  "lastName": "Doe", 
  "fullName": "John Doe",
  "email": "john@example.com",
  "phone": "+94771234567",
  "createdAt": "timestamp",
  "lastLoginAt": "timestamp",
  "isActive": true,
  "role": "user",
  "profileCompleted": true,
  "emailVerified": false
}
```

## 🧪 Testing

### Test WhatsApp:
1. Update API credentials in `api_config.dart`
2. Register a new account with your phone number
3. Check WhatsApp for welcome message

### Test Email:
1. Update EmailJS credentials in `api_config.dart`
2. Register with your email address
3. Check inbox for welcome email

### Test Password Reset:
1. Go to login → "Forgot Password"
2. Enter registered email
3. Check email for reset instructions

## 🔒 Security Notes

- Never commit real API keys to version control
- Use environment variables in production
- Validate phone numbers and emails on frontend and backend
- Implement rate limiting for API calls
- Monitor API usage to avoid quota limits

## 📋 API Limits

### GreenAPI Free Plan:
- 1000 messages/month
- Rate limit: ~10 messages/minute

### EmailJS Free Plan:
- 100 emails/month
- Rate limit: ~50 emails/day

## 🚀 Going Live

1. Replace all "YOUR_*" placeholders with real credentials
2. Test thoroughly in development
3. Set up monitoring for API failures
4. Configure proper error handling
5. Set up backup email service if needed

## 📞 Support

- **GreenAPI Docs**: [https://green-api.com/docs/](https://green-api.com/docs/)
- **EmailJS Docs**: [https://www.emailjs.com/docs/](https://www.emailjs.com/docs/)
- **Firebase Auth**: [https://firebase.google.com/docs/auth](https://firebase.google.com/docs/auth)

## ✅ Checklist

- [ ] GreenAPI account created and configured
- [ ] WhatsApp instance linked and authorized  
- [ ] EmailJS account created with email service
- [ ] Email templates created and tested
- [ ] API credentials updated in `api_config.dart`
- [ ] App domain configured
- [ ] Country code set for target audience
- [ ] Test registration flow end-to-end
- [ ] Test password reset flow
- [ ] Monitor API usage and errors

Your TaskSync app is now ready with professional WhatsApp and email integration! 🎉
