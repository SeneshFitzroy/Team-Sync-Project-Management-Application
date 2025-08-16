import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../Services/auth_service.dart';
import '../models/user_model.dart';
import 'EditProfile.dart';
import 'PersonalInformation.dart';
import 'SecuritySettings.dart';
import 'NotificationSettings.dart';
import 'HelpSupport.dart';
import 'About.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = AuthService.currentUser;
      if (user != null) {
        // Create a basic UserModel from Firebase User
        setState(() {
          _currentUser = UserModel(
            uid: user.uid,
            email: user.email ?? '',
            fullName: user.displayName ?? 'Unknown User',
            photoURL: user.photoURL,
            phoneNumber: user.phoneNumber,
          );
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundWhite,
        body: const Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryBlue,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
            // Header
            Container(
              decoration: const BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: AppTheme.textWhite),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Text(
                            'Profile',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppTheme.textWhite,
                              fontSize: 20,
                              fontFamily: AppTheme.fontFamily,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppTheme.textWhite),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfile(
                                  name: _currentUser?.fullName ?? "Unknown User",
                                  username: _currentUser?.displayName ?? "unknown",
                                  email: _currentUser?.email ?? "No email",
                                  phoneNumber: _currentUser?.phoneNumber ?? "+1 234 567 8900",
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Profile Avatar
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppTheme.textWhite,
                      backgroundImage: _currentUser?.hasProfilePhoto == true 
                        ? NetworkImage(_currentUser!.photoURL!) 
                        : null,
                      child: _currentUser?.hasProfilePhoto != true
                        ? const Icon(
                            Icons.person,
                            size: 60,
                            color: AppTheme.primaryBlue,
                          )
                        : null,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      _currentUser?.fullName ?? 'Unknown User',
                      style: const TextStyle(
                        color: AppTheme.textWhite,
                        fontSize: 24,
                        fontFamily: AppTheme.fontFamily,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _currentUser?.email ?? 'No email available',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontFamily: AppTheme.fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Profile Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                    _buildProfileOption(
                      context,
                      Icons.person,
                      'Personal Information',
                      'Update your personal details',
                      () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PersonalInformationPage())),
                    ),
                    _buildProfileOption(
                      context,
                      Icons.security,
                      'Security Settings',
                      'Manage your password and security',
                      () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SecuritySettingsPage())),
                    ),
                    _buildProfileOption(
                      context,
                      Icons.notifications,
                      'Notifications',
                      'Configure notification preferences',
                      () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationSettingsPage())),
                    ),
                    _buildProfileOption(
                      context,
                      Icons.help,
                      'Help & Support',
                      'Get help and contact support',
                      () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpSupportPage())),
                    ),
                    _buildProfileOption(
                      context,
                      Icons.info,
                      'About',
                      'App information and version',
                      () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutPage())),
                    ),
                    const SizedBox(height: 20),
                    _buildLogoutOption(context),
                  ],
                ),
              ),
          ], // Close Column children
        ), // Close Column
      ), // Close SingleChildScrollView
    ), // Close SafeArea
  ); // Close Scaffold
}

  Widget _buildProfileOption(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF2D62ED).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF2D62ED)),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
            color: Color(0xFF2D62ED),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.grey,
            fontFamily: 'Poppins',
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutOption(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.logout, color: Colors.red),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
            color: Colors.red,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.red, size: 16),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text(
                'Logout',
                style: TextStyle(
                  fontFamily: 'Poppins',
                ),
              ),
              content: const Text(
                'Are you sure you want to logout?',
                style: TextStyle(
                  fontFamily: 'Poppins',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.red,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
