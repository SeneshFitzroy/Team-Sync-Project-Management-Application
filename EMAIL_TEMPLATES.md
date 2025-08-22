# EmailJS Template Setup Guide

## Template 1: Welcome Email Template

**Create this template in your EmailJS dashboard:**

### Template Settings:
- **Template ID**: `template_welcome`
- **Template Name**: TaskSync Welcome Email

### Template Content:

**Subject:**
```
Welcome to TaskSync - Your Account is Ready! 🎉
```

**Email Body (HTML):**
```html
<!DOCTYPE html>
<html>
<head>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
        .content { background: white; padding: 30px; border: 1px solid #ddd; }
        .footer { background: #f8f9fa; padding: 20px; text-align: center; border-radius: 0 0 10px 10px; }
        .button { background: #667eea; color: white; padding: 12px 25px; text-decoration: none; border-radius: 5px; display: inline-block; margin: 10px 0; }
        .feature { display: flex; align-items: center; margin: 15px 0; }
        .feature-icon { font-size: 20px; margin-right: 10px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🎉 Welcome to TaskSync!</h1>
            <p>Your Ultimate Project Management Companion</p>
        </div>
        
        <div class="content">
            <h2>Hello {{to_name}}! 👋</h2>
            
            <p>Thank you for joining TaskSync! We're thrilled to have you as part of our productive community.</p>
            
            <div style="background: #f0f8ff; padding: 20px; border-radius: 8px; margin: 20px 0;">
                <h3>✅ Your Account Details:</h3>
                <p><strong>Name:</strong> {{to_name}}</p>
                <p><strong>Email:</strong> {{to_email}}</p>
                <p><strong>Status:</strong> Active & Ready to Go!</p>
            </div>
            
            <h3>🚀 What's Next?</h3>
            <ol>
                <li><strong>Verify Your Email</strong> - Check for our verification email</li>
                <li><strong>Complete Your Profile</strong> - Add your preferences</li>
                <li><strong>Create Your First Project</strong> - Start organizing tasks</li>
                <li><strong>Invite Your Team</strong> - Collaborate with others</li>
            </ol>
            
            <h3>💪 Key Features Waiting for You:</h3>
            <div class="feature">
                <span class="feature-icon">📊</span>
                <span>Project Management Dashboard</span>
            </div>
            <div class="feature">
                <span class="feature-icon">⏰</span>
                <span>Task Scheduling & Deadlines</span>
            </div>
            <div class="feature">
                <span class="feature-icon">👥</span>
                <span>Team Collaboration Tools</span>
            </div>
            <div class="feature">
                <span class="feature-icon">📈</span>
                <span>Progress Tracking & Reports</span>
            </div>
            <div class="feature">
                <span class="feature-icon">🔔</span>
                <span>Smart Notifications</span>
            </div>
            
            <div style="text-align: center; margin: 30px 0;">
                <a href="https://tasksync-app.com/login" class="button">Get Started Now</a>
            </div>
            
            <h3>🆘 Need Help?</h3>
            <p>We're here to help you succeed:</p>
            <ul>
                <li>📚 <a href="https://tasksync-app.com/guide">Quick Start Guide</a></li>
                <li>💬 <a href="https://tasksync-app.com/support">Support Center</a></li>
                <li>📧 Email: support@tasksync.com</li>
                <li>📞 Phone: +1-800-TASKSYNC</li>
            </ul>
        </div>
        
        <div class="footer">
            <p><strong>Thank you for choosing TaskSync!</strong></p>
            <p>Follow us: 
                <a href="#">Twitter</a> | 
                <a href="#">Facebook</a> | 
                <a href="#">LinkedIn</a>
            </p>
            <p style="font-size: 12px; color: #666;">
                This email was sent because you created a TaskSync account.<br>
                If you didn't create this account, please contact support immediately.
            </p>
        </div>
    </div>
</body>
</html>
```

**Template Variables to Add:**
- `{{to_name}}` - User's full name
- `{{to_email}}` - User's email address
- `{{first_name}}` - User's first name

---

## Template 2: Password Reset Template

**Create this template in your EmailJS dashboard:**

### Template Settings:
- **Template ID**: `template_reset`
- **Template Name**: TaskSync Password Reset

### Template Content:

**Subject:**
```
Reset Your TaskSync Password 🔐
```

**Email Body (HTML):**
```html
<!DOCTYPE html>
<html>
<head>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #ff6b6b 0%, #ee5a24 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
        .content { background: white; padding: 30px; border: 1px solid #ddd; }
        .footer { background: #f8f9fa; padding: 20px; text-align: center; border-radius: 0 0 10px 10px; }
        .button { background: #ff6b6b; color: white; padding: 15px 30px; text-decoration: none; border-radius: 5px; display: inline-block; margin: 20px 0; font-weight: bold; }
        .warning { background: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .security-tips { background: #f8f9fa; padding: 20px; border-radius: 8px; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🔐 Password Reset Request</h1>
            <p>TaskSync Security Team</p>
        </div>
        
        <div class="content">
            <h2>Hello {{to_name}},</h2>
            
            <p>We received a request to reset the password for your TaskSync account.</p>
            
            <div class="warning">
                <strong>⚠️ Security Notice:</strong><br>
                If you didn't request this password reset, please ignore this email. Your password will remain unchanged.
            </div>
            
            <p>To reset your password, click the button below:</p>
            
            <div style="text-align: center;">
                <a href="{{reset_link}}" class="button">Reset My Password</a>
            </div>
            
            <p style="color: #666; font-size: 14px;">
                If the button doesn't work, copy and paste this link into your browser:<br>
                <a href="{{reset_link}}">{{reset_link}}</a>
            </p>
            
            <div class="warning">
                <strong>⏰ Important:</strong> This reset link will expire in 1 hour for your security.
            </div>
            
            <div class="security-tips">
                <h3>🛡️ Security Tips:</h3>
                <ul>
                    <li>Never share your password with anyone</li>
                    <li>Use a strong, unique password</li>
                    <li>Enable two-factor authentication</li>
                    <li>Regularly update your password</li>
                </ul>
            </div>
            
            <h3>🆘 Need Help?</h3>
            <p>If you're having trouble or didn't request this reset:</p>
            <ul>
                <li>📧 Email: security@tasksync.com</li>
                <li>📞 Phone: +1-800-TASKSYNC</li>
                <li>💬 Live Chat: Available 24/7</li>
            </ul>
        </div>
        
        <div class="footer">
            <p><strong>TaskSync Security Team</strong></p>
            <p style="font-size: 12px; color: #666;">
                This is an automated security email from TaskSync.<br>
                For your protection, do not share this email with anyone.
            </p>
        </div>
    </div>
</body>
</html>
```

**Template Variables to Add:**
- `{{to_name}}` - User's name
- `{{reset_link}}` - Password reset URL
- `{{first_name}}` - User's first name

---

## Setup Instructions:

1. **Go to your EmailJS dashboard**
2. **Click "Email Templates"**
3. **Create New Template**
4. **Copy the HTML content above**
5. **Set up the template variables**
6. **Test the templates**
7. **Get your EmailJS credentials and update the config**
