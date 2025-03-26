import 'package:flutter/material.dart';
import '../Components/nav_bar.dart';
import 'Profile.dart'; // Import the Profile screen
import 'CreateaNewProject.dart'; // Import the CreateANewProject screen

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Navigation logic can be added here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildTitle(),
                    _buildProjectsList(),
                  ],
                ),
              ),
            ),
            NavBar(
              selectedIndex: _selectedIndex,
              onTap: _onNavItemTapped,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: ShapeDecoration(
                color: const Color(0x11192F5D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(Icons.search, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Search projects...',
                    style: TextStyle(
                      color: const Color(0xFF999999),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () {
              // Navigate to Profile screen when profile icon is tapped
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
              ),
              child: Icon(Icons.person, color: Colors.grey[700], size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 16),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Project Dashboard',
              style: TextStyle(
                color: Color(0xFF192F5D),
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: ShapeDecoration(
              color: const Color(0x11192F5D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.filter_list, size: 16, color: Colors.black87),
                const SizedBox(width: 4),
                const Text(
                  'Filters',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildProjectCard(
            title: 'Marketing Campaign',
            members: '8 Members',
            status: 'active',
            progress: 0.75,
            progressText: '75%',
            color: const Color(0xFF187E0F),
          ),
          const SizedBox(height: 24),
          _buildProjectCard(
            title: 'Product Launch',
            members: '12 Members',
            status: 'at-risk',
            progress: 0.60,
            progressText: '60%',
            color: const Color(0xFFD14318),
          ),
          const SizedBox(height: 24),
          _buildProjectCard(
            title: 'Website Redesign',
            members: '6 Members',
            status: 'completed',
            progress: 0.90,
            progressText: '90%',
            color: const Color(0xFF187E0F),
          ),
          const SizedBox(height: 24),
          _buildCreateProjectButton(),
          // Add more padding at the bottom to prevent overflow
          const SizedBox(height: 36),
        ],
      ),
    );
  }

  // Adjust the project card dimensions to be more compact if needed
  Widget _buildProjectCard({
    required String title,
    required String members,
    required String status,
    required double progress,
    required String progressText,
    required Color color,
  }) {
    // Calculate progress width accounting for padding
    final availableWidth = MediaQuery.of(context).size.width - 48 - 24; // screen width minus horizontal paddings
    final progressWidth = availableWidth * progress;
    
    return Container(
      width: double.infinity,
      // Slightly increase height to accommodate all content
      height: 165,
      decoration: ShapeDecoration(
        color: const Color(0x56192F5D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Stack(
        children: [
          // Left color bar - adjust height to match container
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 8,
              height: 165, // Match the new container height
              decoration: ShapeDecoration(
                color: color,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  ),
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12), // Reduced from 15
                // Info row
                Row(
                  children: [
                    Icon(Icons.group, size: 16, color: Colors.black.withOpacity(0.75)),
                    const SizedBox(width: 8),
                    Text(
                      members,
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.75),
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(width: 20),
                    Icon(
                      status == 'active' ? Icons.check_circle : 
                      status == 'at-risk' ? Icons.warning :
                      Icons.task_alt,
                      size: 16, 
                      color: Colors.black.withOpacity(0.75)
                    ),
                    const SizedBox(width: 8),
                    Text(
                      status,
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.75),
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25), // Reduced from 30
                // Progress label
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.75),
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      progressText,
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.75),
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8), // Reduced from 10
                // Progress bar - reduce height slightly
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 7, // Reduced from 9
                      decoration: ShapeDecoration(
                        color: const Color(0x26192F5D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Container(
                      width: progressWidth,
                      height: 7, // Reduced from 9
                      decoration: ShapeDecoration(
                        color: color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateProjectButton() {
    return GestureDetector(
      onTap: () {
        // Navigate to CreateANewProject screen when button is clicked
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateANewProject()),
        );
      },
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: ShapeDecoration(
          color: const Color(0xFF192F5D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: const Center(
          child: Text(
            'Create New Project',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
