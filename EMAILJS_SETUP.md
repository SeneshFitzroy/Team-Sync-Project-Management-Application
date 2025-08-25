# 📧 EmailJS Template Setup Guide

## 🚀 Quick Setup Steps

### 1. Go to EmailJS Dashboard
Visit: https://dashboard.emailjs.com/admin

### 2. Navigate to Email Templates
- Click on "Email Templates" in the left sidebar
- Click "Create New Template"

### 3. Template Configuration
**Template ID:** `template_welcome` (MUST be exactly this!)
**Template Name:** `TaskSync Welcome Email`
**Email Subject:** `🎉 Welcome to TaskSync - Your Project Management Journey Begins!`

### 4. Simple Template Content

**IMPORTANT:** Use this exact template content in EmailJS:

```html
<h1>🎯 Welcome to TaskSync!</h1>

<p>Hello {{user_name}},</p>

<p>Welcome to TaskSync! Your account has been successfully created.</p>

<h3>Account Details:</h3>
<ul>
  <li><strong>Name:</strong> {{first_name}} {{last_name}}</li>
  <li><strong>Email:</strong> {{user_email}}</li>
  <li><strong>Phone:</strong> {{phone_number}}</li>
  <li><strong>Registration Date:</strong> {{registration_date}}</li>
</ul>

<h3>What's Next?</h3>
<p>🔹 Explore your dashboard<br>
🔹 Create your first project<br>
🔹 Invite team members<br>
🔹 Start managing tasks efficiently</p>

<p>If you have any questions, feel free to contact our support team.</p>

<p>Best regards,<br>
<strong>The TaskSync Team</strong></p>

<hr>
<p style="font-size: 12px; color: #666;">
© 2024 TaskSync. All rights reserved.<br>
This email was sent to {{user_email}}
</p>
```

### 5. Template Variables Setup
Make sure these variables are configured in your EmailJS template:
- `{{user_name}}` - Full name
- `{{user_email}}` - User's email address
- `{{first_name}}` - First name
- `{{last_name}}` - Last name  
- `{{phone_number}}` - Phone number
- `{{registration_date}}` - Account creation date

### 6. Current EmailJS Configuration ✅
- **Service ID:** service_xtlfp5m
- **User ID:** dz8xtM4ALRHVg9HBj
- **Access Token:** C_XRQslKP7-eO_LUr5MHN
- **Template ID:** template_welcome

## 🧪 Testing Steps

### After Creating the Template:
1. ✅ Click "Test" in EmailJS dashboard
2. ✅ Fill in sample values:
   - user_name: "John Doe"
   - user_email: "john@example.com"
   - first_name: "John"
   - last_name: "Doe"
   - phone_number: "+94761234567"
   - registration_date: "25/8/2024"
3. ✅ Send test email to verify it works
4. ✅ Check your email inbox (and spam folder)

### In Your App:
1. ✅ Create a new account
2. ✅ Check email within 30 seconds
3. ✅ Look in inbox and spam/promotions folder

## 🐛 Troubleshooting

### If No Email Received:
1. **Check Template ID:** Must be exactly `template_welcome`
2. **Check Gmail Service:** Ensure connected as tasksync.team@gmail.com
3. **Check Spam:** Look in spam/promotions folder
4. **Check Variables:** All template variables must be properly mapped
5. **Check Limits:** You have 200 emails/month free

### Common Issues:
- **Template ID mismatch:** Case sensitive, must be `template_welcome`
- **Variable names:** Must match exactly (case sensitive)
- **Gmail connection:** Must allow "Send email on your behalf"
- **Rate limits:** Don't send too many test emails quickly

## 🎯 Success Checklist
- [ ] Template created with ID `template_welcome`
- [ ] All variables properly mapped
- [ ] Test email sent successfully from EmailJS
- [ ] Gmail service connected properly
- [ ] App creates account and sends email

## 📞 Support
If you're still having issues:
1. Check EmailJS dashboard for error logs
2. Verify your Gmail connection
3. Test the template manually in EmailJS first
4. Ensure all variable names match exactly
