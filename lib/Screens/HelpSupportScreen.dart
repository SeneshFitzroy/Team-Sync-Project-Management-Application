import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../widgets/TickLogo.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> 
    with TickerProviderStateMixin {
  
  // Controllers
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // State variables
  bool _isSubmitting = false;
  bool _showContactForm = false;
  String _selectedCategory = 'General';
  
  final List<String> _categories = [
    'General',
    'Technical Issue',
    'Bug Report',
    'Feature Request',
    'Account Problem',
    'Other'
  ];

  final List<Map<String, dynamic>> _faqItems = [
    {
      'question': 'How do I reset my password?',
      'answer': 'Go to Security Settings in your profile and click "Send Password Reset" to receive a reset email.',
      'expanded': false,
    },
    {
      'question': 'How do I update my personal information?',
      'answer': 'Navigate to Profile > Personal Information and tap the edit button to modify your details.',
      'expanded': false,
    },
    {
      'question': 'How do I create and manage tasks?',
      'answer': 'Use the Task page to create new tasks, set priorities, and track progress. You can also assign tasks to team members.',
      'expanded': false,
    },
    {
      'question': 'How do I use the calendar feature?',
      'answer': 'The calendar shows all your tasks and deadlines. You can switch between month, week, and day views for better organization.',
      'expanded': false,
    },
    {
      'question': 'How do I communicate with team members?',
      'answer': 'Use the Chat feature to communicate with team members. You can create group chats and share files.',
      'expanded': false,
    },
    {
      'question': 'How do I enable two-factor authentication?',
      'answer': 'Go to Profile > Security Settings and toggle on Two-Factor Authentication for enhanced security.',
      'expanded': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitSupportTicket() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('support_tickets').add({
          'userId': user.uid,
          'userEmail': user.email,
          'category': _selectedCategory,
          'subject': _subjectController.text.trim(),
          'message': _messageController.text.trim(),
          'status': 'open',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        _showSuccessSnackBar('Support ticket submitted successfully!');
        setState(() {
          _showContactForm = false;
          _subjectController.clear();
          _messageController.clear();
          _selectedCategory = 'General';
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to submit support ticket: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@teamsync.com',
      query: 'subject=TeamSync Support Request',
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      _showErrorSnackBar('Could not launch email client');
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+1-800-TEAMSYNC');
    
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      _showErrorSnackBar('Could not launch phone dialer');
    }
  }

  Future<void> _launchWebsite() async {
    final Uri websiteUri = Uri.parse('https://teamsync.com/support');
    
    if (await canLaunchUrl(websiteUri)) {
      await launchUrl(websiteUri, mode: LaunchMode.externalApplication);
    } else {
      _showErrorSnackBar('Could not launch website');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primaryBlue, const Color(0xFF764BA2)],
          ),
        ),
        child: SafeArea(
          child: _buildMainContent(),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildQuickActionsCard(),
                    const SizedBox(height: 20),
                    _buildFAQCard(),
                    const SizedBox(height: 20),
                    if (_showContactForm) _buildContactForm(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          const TickLogo(size: 35),
          const SizedBox(width: 12),
          const Text(
            'Help & Support',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
          ),
          _buildQuickAction(
            'Contact Support',
            'Submit a support ticket',
            Icons.support_agent,
            () => setState(() => _showContactForm = !_showContactForm),
          ),
          _buildDivider(),
          _buildQuickAction(
            'Email Support',
            'Send us an email directly',
            Icons.email_outlined,
            _launchEmail,
          ),
          _buildDivider(),
          _buildQuickAction(
            'Call Support',
            'Speak with our support team',
            Icons.phone_outlined,
            _launchPhone,
          ),
          _buildDivider(),
          _buildQuickAction(
            'Visit Help Center',
            'Browse our online help center',
            Icons.help_center_outlined,
            _launchWebsite,
          ),
        ],
      ),
    );
  }

  Widget _buildFAQCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _faqItems.length,
            separatorBuilder: (context, index) => _buildDivider(),
            itemBuilder: (context, index) => _buildFAQItem(index),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryBlue.withOpacity(0.1), const Color(0xFF764BA2).withOpacity(0.1)],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primaryBlue, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
      onTap: onTap,
    );
  }

  Widget _buildFAQItem(int index) {
    final item = _faqItems[index];
    return ExpansionTile(
      title: Text(
        item['question'],
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            item['answer'],
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ),
      ],
      iconColor: AppTheme.primaryBlue,
      collapsedIconColor: Colors.grey.shade600,
    );
  }

  Widget _buildContactForm() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Support',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 20),
            
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category_outlined, color: AppTheme.primaryBlue),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
                ),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedCategory = value!),
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _subjectController,
              decoration: InputDecoration(
                labelText: 'Subject',
                prefixIcon: Icon(Icons.subject, color: AppTheme.primaryBlue),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
                ),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter a subject';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _messageController,
              maxLines: 5,
              maxLength: 500,
              decoration: InputDecoration(
                labelText: 'Message',
                prefixIcon: Icon(Icons.message_outlined, color: AppTheme.primaryBlue),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
                ),
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter your message';
                }
                if (value!.length < 10) {
                  return 'Message must be at least 10 characters';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 24),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _showContactForm = false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitSupportTicket,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSubmitting 
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Submit Ticket', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Divider(color: Colors.grey.shade200, height: 1),
    );
  }
}
