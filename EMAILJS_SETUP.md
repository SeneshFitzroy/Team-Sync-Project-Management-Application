# EmailJS Template Setup Guide

## Template Creation Instructions

### 1. Go to EmailJS Dashboard
Visit: https://dashboard.emailjs.com/admin

### 2. Navigate to Email Templates
- Click on "Email Templates" in the left sidebar
- Click "Create New Template"

### 3. Template Details
**Template ID:** `template_welcome`
**Template Name:** `TeamSync Password Reset`
**Email Subject:** `Reset Your TeamSync Password`

### 4. Template Content (HTML)

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TeamSync Password Reset</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f5f7fa;
            margin: 0;
            padding: 0;
        }
        .container {
            max-width: 600px;
            margin: 40px auto;
            background-color: #ffffff;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 40px 30px;
            text-align: center;
        }
        .header h1 {
            margin: 0;
            font-size: 28px;
            font-weight: 700;
            letter-spacing: -0.5px;
        }
        .content {
            padding: 40px 30px;
        }
        .greeting {
            font-size: 18px;
            color: #2d3748;
            margin-bottom: 20px;
            font-weight: 500;
        }
        .message {
            font-size: 16px;
            color: #4a5568;
            line-height: 1.6;
            margin-bottom: 30px;
        }
        .reset-button {
            display: inline-block;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            text-decoration: none;
            padding: 16px 32px;
            border-radius: 8px;
            font-weight: 600;
            font-size: 16px;
            text-align: center;
            margin: 20px 0;
            transition: transform 0.2s ease;
        }
        .reset-button:hover {
            transform: translateY(-2px);
        }
        .expiry-notice {
            background-color: #fff5f5;
            border-left: 4px solid #fc8181;
            padding: 15px 20px;
            margin: 20px 0;
            border-radius: 0 6px 6px 0;
        }
        .expiry-notice p {
            margin: 0;
            color: #c53030;
            font-size: 14px;
            font-weight: 500;
        }
        .security-tips {
            background-color: #f7fafc;
            border-radius: 8px;
            padding: 20px;
            margin: 20px 0;
        }
        .security-tips h3 {
            color: #2d3748;
            margin: 0 0 15px 0;
            font-size: 16px;
        }
        .security-tips ul {
            margin: 0;
            padding-left: 20px;
            color: #4a5568;
        }
        .security-tips li {
            margin: 8px 0;
            font-size: 14px;
        }
        .footer {
            background-color: #f7fafc;
            padding: 30px;
            text-align: center;
            border-top: 1px solid #e2e8f0;
        }
        .footer p {
            margin: 0;
            color: #718096;
            font-size: 14px;
        }
        .social-links {
            margin: 20px 0;
        }
        .social-links a {
            color: #667eea;
            text-decoration: none;
            margin: 0 10px;
            font-weight: 500;
        }
        @media (max-width: 600px) {
            .container {
                margin: 20px auto;
                border-radius: 0;
            }
            .header, .content, .footer {
                padding: 30px 20px;
            }
            .reset-button {
                display: block;
                text-align: center;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🎯 TeamSync</h1>
        </div>
        
        <div class="content">
            <div class="greeting">
                Hello {{user_name}},
            </div>
            
            <div class="message">
                We received a request to reset your password for your TeamSync account. If you didn't make this request, you can safely ignore this email.
            </div>
            
            <div style="text-align: center;">
                <a href="{{reset_link}}" class="reset-button">
                    🔐 Reset Your Password
                </a>
            </div>
            
            <div class="expiry-notice">
                <p>⏱️ This reset link will expire in 1 hour for your security.</p>
            </div>
            
            <div class="security-tips">
                <h3>🛡️ Security Tips:</h3>
                <ul>
                    <li>Never share your password with anyone</li>
                    <li>Use a strong, unique password</li>
                    <li>Enable two-factor authentication when available</li>
                    <li>If you didn't request this reset, please contact our support team</li>
                </ul>
            </div>
            
            <div class="message">
                If the button above doesn't work, you can copy and paste this link into your browser:
                <br><br>
                <a href="{{reset_link}}" style="color: #667eea; word-break: break-all;">{{reset_link}}</a>
            </div>
        </div>
        
        <div class="footer">
            <p>Best regards,<br><strong>The TeamSync Team</strong></p>
            
            <div class="social-links">
                <a href="#">Help Center</a> |
                <a href="#">Contact Support</a> |
                <a href="#">Privacy Policy</a>
            </div>
            
            <p style="margin-top: 20px; font-size: 12px;">
                © 2024 TeamSync. All rights reserved.<br>
                This email was sent to {{user_email}}
            </p>
        </div>
    </div>
</body>
</html>
```

### 5. Template Variables
Make sure to configure these variables in the EmailJS template:
- `{{user_name}}` - The recipient's name
- `{{user_email}}` - The recipient's email address  
- `{{reset_link}}` - The password reset link from Firebase

### 6. Test Template
After creating the template:
1. Click "Test" to preview the email
2. Fill in sample values for the variables
3. Send a test email to verify it works

## Current Configuration
- **Service ID:** service_xtlfp5m
- **User ID:** dz8xtM4ALRHVg9HBj  
- **Access Token:** C_XRQslKP7-eO_LUr5MHN
- **Template ID:** template_welcome

## Verification Steps
1. ✅ EmailJS account set up
2. ✅ Gmail service connected
3. ⏳ Create template with ID `template_welcome`
4. ⏳ Test email sending
5. ⏳ Verify password reset flow

## Troubleshooting
If emails aren't sending:
1. Check EmailJS dashboard for error logs
2. Verify template ID matches exactly
3. Ensure Gmail service is properly connected
4. Check spam folder for test emails
5. Verify all template variables are properly mapped
