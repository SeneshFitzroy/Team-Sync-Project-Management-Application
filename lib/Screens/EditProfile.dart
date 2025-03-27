import 'package:flutter/material.dart';

class EditProfile extends StatefulWidget {
  final String name;
  final String username;
  final String email;
  final String phoneNumber;

  const EditProfile({
    super.key, 
    required this.name,
    required this.username,
    required this.email,
    required this.phoneNumber,
  });

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  // Controllers for form fields
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _usernameController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with passed data
    _nameController = TextEditingController(text: widget.name);
    _phoneController = TextEditingController(text: widget.phoneNumber);
    _emailController = TextEditingController(text: widget.email);
    _usernameController = TextEditingController(text: widget.username);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

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
            fontSize: 24,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Image
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1),
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.grey[200],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.network(
                        'https://via.placeholder.com/100',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.person, size: 60);
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFF192F5D),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                        onPressed: () {
                          // Add image picker functionality here
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // User name display
            Text(
              _nameController.text,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
              ),
            ),
            
            Text(
              _usernameController.text,
              style: const TextStyle(
                color: Color(0xFF9D9D9D),
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Divider
            Container(
              height: 1,
              color: const Color(0xFFA9A9A9),
            ),
            
            const SizedBox(height: 20),
            
            // Form fields
            buildTextField("Full Name", _nameController),
            buildTextField("Phone Number", _phoneController),
            buildTextField("Email", _emailController),
            buildTextField("Username", _usernameController),
            
            const SizedBox(height: 30),
            
            // Save button
            ElevatedButton(
              onPressed: () {
                // Return updated data to ProfileScreen
                Navigator.pop(context, {
                  'name': _nameController.text,
                  'username': _usernameController.text,
                  'email': _emailController.text,
                  'phoneNumber': _phoneController.text,
                });
                
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated successfully')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF192F5D),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD8DADC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 12),
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF9D9D9D),
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          TextField(
            controller: controller,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }
}
