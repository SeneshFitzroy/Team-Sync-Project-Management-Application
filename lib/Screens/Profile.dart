import 'package:flutter/material.dart';
import 'EditProfile.dart';
import 'Notifications.dart';  // Import the Notifications screen
import 'ChangePassword.dart';  // Import the ChangePassword screen
import 'AboutTaskSync.dart';  // Import the AboutTaskSync screen
import 'ContactSupport.dart';  // Import the ContactSupport screen
import 'welcome-page2.dart';  // Import the Welcome Page
import 'package:firebase_auth/firebase_auth.dart';  // Import Firebase Auth for logout

class ProfileScreen extends StatefulWidget {  // Changed to StatefulWidget
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Variables to store user data
  String userName = 'Mandira De Silva';
  String userHandle = '@mandira2002';
  String email = 'Mandira@gmail.com';
  String phoneNumber = '0761120457';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F8FF),
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD8DADC)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            
            // Profile Photo
            Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(width: 1),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  child: const Icon(Icons.person, size: 50, color: Colors.grey),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // User Name
            Text(
              userName,  // Using variable instead of constant
              style: const TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
              ),
            ),
            
            // Username
            Text(
              userHandle,  // Using variable instead of constant
              style: const TextStyle(
                color: Color(0xFF9D9D9D),
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Edit Profile Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  // Navigate to EditProfile and wait for result
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfile(
                        name: userName,
                        username: userHandle,
                        email: email,
                        phoneNumber: phoneNumber,
                      ),
                    ),
                  );
                  
                  // Update profile if result is returned
                  if (result != null && result is Map<String, String>) {
                    setState(() {
                      userName = result['name'] ?? userName;
                      userHandle = result['username'] ?? userHandle;
                      email = result['email'] ?? email;
                      phoneNumber = result['phoneNumber'] ?? phoneNumber;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF192F5D),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Edit Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Settings Section
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  'Settings',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            const Divider(color: Color(0xFFA9A9A9)),
            
            // Settings Items
            _buildSettingItem(
              icon: Icons.notifications_outlined,
              title: 'Notification',
              onTap: () {
                // Navigate to the Notifications screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                );
              },
            ),
            
            _buildSettingItem(
              icon: Icons.lock_outline,
              title: 'Change password',
              onTap: () {
                // Navigate to the ChangePassword screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChangePassword()),
                );
              },
            ),
            
            _buildSettingItem(
              icon: Icons.info_outline,
              title: 'About TaskSync',
              onTap: () {
                // Navigate to the AboutTaskSync screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutTaskSync()),
                );
              },
            ),
            
            _buildSettingItem(
              icon: Icons.support_agent_outlined,
              title: 'Contact Support',
              onTap: () {
                // Navigate to ContactSupport screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ContactSupport()),
                );
              },
            ),
            
            const Divider(color: Color(0xFFA9A9A9)),
            
            // Logout Item
            _buildSettingItem(
              icon: Icons.logout,
              title: 'Logout',
              iconColor: Colors.red,
              titleColor: Colors.red,
              onTap: () {
                // Logout action
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          // Sign out from Firebase
                          FirebaseAuth.instance.signOut().then((_) {
                            // Close the dialog
                            Navigator.pop(context);
                            // Navigate to Welcome Page and remove all previous routes
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const WelcomePage2(),
                              ),
                              (route) => false, // Remove all previous routes
                            );
                          }).catchError((error) {
                            print("Error signing out: $error");
                            // Still navigate to Welcome Page even if there's an error
                            Navigator.pop(context);
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const WelcomePage2(),
                              ),
                              (route) => false,
                            );
                          });
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
              },
            ),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = Colors.black,
    Color titleColor = Colors.black,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor,
          fontSize: 20,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 18),
      onTap: onTap,
    );
  }
}
