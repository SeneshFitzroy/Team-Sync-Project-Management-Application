import 'package:flutter/material.dart';
import '../Components/nav_bar.dart';
import 'Profile.dart'; // Import the Profile screen
import 'CreateaNewProject.dart'; // Import the CreateANewProject screen
import './TaskManager.dart'; // Import TaskManager
import './Chat.dart'; // Import Chat
import './Calendar.dart'; // Import Calendar
import 'welcome-page2.dart'; // Import WelcomePage2
import 'package:firebase_auth/firebase_auth.dart'; // Add this import
import 'package:cloud_firestore/cloud_firestore.dart'; // Correct Firestore import
import 'login-page.dart'; // Import the login page
import '../utils/firebase_helpers.dart'; // Add this import

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _filterAnimController;
  
  // Filter states
  bool _showActiveOnly = false;
  bool _showAtRiskOnly = false;
  bool _showCompletedOnly = false;
  String _selectedSortOption = 'Progress (High to Low)';

  // Project list with additional fields for editing
  List<Map<String, dynamic>> projects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _filterAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    // Check if user is logged in
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // Not logged in, redirect to login page
      print("User not logged in, redirecting to login");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      });
      return;
    }
    
    // Load user data safely without assuming PigeonUserDetails
    _loadUserDataSafely(currentUser.uid);
    
    // Load projects from Firestore
    _loadProjectsFromFirestore();
  }

  // Load projects from Firestore
  Future<void> _loadProjectsFromFirestore() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final projectsSnapshot = await FirebaseFirestore.instance.collection('projects').get();
      
      if (projectsSnapshot.docs.isEmpty) {
        // If no projects exist yet, initialize with default projects
        await _saveDefaultProjectsToFirestore();
        // Then load them
        final newSnapshot = await FirebaseFirestore.instance.collection('projects').get();
        _processProjectsSnapshot(newSnapshot);
      } else {
        // Process existing projects
        _processProjectsSnapshot(projectsSnapshot);
      }
    } catch (e) {
      print("Error loading projects: $e");
      // Fall back to default projects if Firestore fails
      _loadDefaultProjects();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Process projects snapshot into the projects list
  void _processProjectsSnapshot(QuerySnapshot snapshot) {
    setState(() {
      projects = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'title': data['name'] ?? 'Untitled Project',
          'members': '${data['members_count'] ?? 0} Members',
          'status': data['status'] ?? 'active',
          'progress': (data['progress'] ?? 0) / 100, // Convert to 0-1 range
          'progressText': '${data['progress'] ?? 0}%',
          'color': _getColorForStatus(data['status'] ?? 'active'),
          'description': data['description'] ?? 'No description provided.',
          'created_at': data['created_at'] ?? Timestamp.now(),
        };
      }).toList();
      
      // Sort projects according to selected option
      _applySorting();
    });
  }
  
  // Get color based on status
  Color _getColorForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF187E0F);
      case 'at-risk':
        return const Color(0xFFD14318);
      case 'completed':
        return const Color(0xFF187E0F);
      default:
        return const Color(0xFF192F5D);
    }
  }
  
  // Save default projects to Firestore
  Future<void> _saveDefaultProjectsToFirestore() async {
    final batch = FirebaseFirestore.instance.batch();
    
    // Website Redesign
    final websiteDoc = FirebaseFirestore.instance.collection('projects').doc('website_redesign');
    batch.set(websiteDoc, {
      'name': 'Website Redesign',
      'members_count': 6,
      'status': 'completed',
      'progress': 90,
      'description': 'Redesign company website with new branding.',
      'created_at': FieldValue.serverTimestamp(),
    });
    
    // Marketing Campaign
    final marketingDoc = FirebaseFirestore.instance.collection('projects').doc('marketing_campaign');
    batch.set(marketingDoc, {
      'name': 'Marketing Campaign',
      'members_count': 8,
      'status': 'active',
      'progress': 75,
      'description': 'Digital marketing campaign for Q3 2023.',
      'created_at': FieldValue.serverTimestamp(),
    });
    
    // Product Launch
    final productDoc = FirebaseFirestore.instance.collection('projects').doc('product_launch');
    batch.set(productDoc, {
      'name': 'Product Launch',
      'members_count': 12,
      'status': 'at-risk',
      'progress': 60,
      'description': 'New product launch planning and execution.',
      'created_at': FieldValue.serverTimestamp(),
    });
    
    try {
      await batch.commit();
      print("Default projects saved to Firestore successfully");
    } catch (e) {
      print("Error saving default projects to Firestore: $e");
      throw e; // Re-throw to be caught by the calling function
    }
  }
  
  // Fall back to default projects if Firestore fails
  void _loadDefaultProjects() {
    setState(() {
      projects = [
        {
          'title': 'Marketing Campaign',
          'members': '8 Members',
          'status': 'active',
          'progress': 0.75,
          'progressText': '75%',
          'color': const Color(0xFF187E0F),
          'description': 'Digital marketing campaign for Q3 2023.',
        },
        {
          'title': 'Product Launch',
          'members': '12 Members',
          'status': 'at-risk',
          'progress': 0.60,
          'progressText': '60%',
          'color': const Color(0xFFD14318),
          'description': 'New product launch planning and execution.',
        },
        {
          'title': 'Website Redesign',
          'members': '6 Members',
          'status': 'completed',
          'progress': 0.90,
          'progressText': '90%',
          'color': const Color(0xFF187E0F),
          'description': 'Redesign company website with new branding.',
        },
      ];
    });
  }

  // Safe method to load user data without type casting issues
  Future<void> _loadUserDataSafely(String userId) async {
    try {
      final userData = await FirebaseHelpers.getUserDataSafely(userId);
      
      if (userData != null) {
        final displayName = userData['displayName'] as String? ?? 'User';
        final email = userData['email'] as String? ?? '';
        
        // Set state or update UI as needed
        setState(() {
          // Example: _userName = displayName;
        });
        
        print("Successfully loaded user data for: $displayName ($email)");
      } else {
        print("User document doesn't exist in Firestore");
      }
    } catch (e) {
      print("Error loading user data: $e");
      // Handle gracefully - don't crash if data can't be loaded
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _filterAnimController.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // Navigation logic to switch between screens
    if (index != 0) { // If not Dashboard tab (since we're already in Dashboard)
      switch (index) {
        case 1: // Tasks
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const TaskManager()),
          );
          break;
        case 2: // Chat
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ChatScreen()),
          );
          break;
        case 3: // Calendar
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Calendar()),
          );
          break;
      }
    }
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchQuery = '';
      _searchController.clear();
    });
    FocusScope.of(context).unfocus();
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 10,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFFEEEEEE),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filter Projects',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF192F5D),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Color(0xFF192F5D)),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF192F5D),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildFilterCheckbox(
                            'Active Projects',
                            _showActiveOnly,
                            (value) {
                              setModalState(() {
                                _showActiveOnly = value!;
                              });
                            },
                          ),
                          _buildFilterCheckbox(
                            'At Risk Projects',
                            _showAtRiskOnly,
                            (value) {
                              setModalState(() {
                                _showAtRiskOnly = value!;
                              });
                            },
                          ),
                          _buildFilterCheckbox(
                            'Completed Projects',
                            _showCompletedOnly,
                            (value) {
                              setModalState(() {
                                _showCompletedOnly = value!;
                              });
                            },
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Sort By',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF192F5D),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildSortOption(
                            'Progress (High to Low)',
                            _selectedSortOption == 'Progress (High to Low)',
                            () {
                              setModalState(() {
                                _selectedSortOption = 'Progress (High to Low)';
                              });
                            },
                          ),
                          _buildSortOption(
                            'Progress (Low to High)',
                            _selectedSortOption == 'Progress (Low to High)',
                            () {
                              setModalState(() {
                                _selectedSortOption = 'Progress (Low to High)';
                              });
                            },
                          ),
                          _buildSortOption(
                            'Alphabetical (A-Z)',
                            _selectedSortOption == 'Alphabetical (A-Z)',
                            () {
                              setModalState(() {
                                _selectedSortOption = 'Alphabetical (A-Z)';
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Color(0xFFEEEEEE),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setModalState(() {
                                _showActiveOnly = false;
                                _showAtRiskOnly = false;
                                _showCompletedOnly = false;
                                _selectedSortOption = 'Progress (High to Low)';
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: const Color(0xFF192F5D),
                              backgroundColor: Colors.white,
                              elevation: 0,
                              side: const BorderSide(color: Color(0xFF192F5D)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Reset'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                // Apply filters and close dialog
                              });
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: const Color(0xFF192F5D),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Apply'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterCheckbox(String label, bool value, Function(bool?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF192F5D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortOption(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF192F5D) : Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check,
                color: Color(0xFF192F5D),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      // Show confirmation dialog
      bool confirm = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to log out?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'LOGOUT',
                  style: TextStyle(color: Color(0xFF192F5D)),
                ),
              ),
            ],
          );
        },
      ) ?? false;

      if (confirm) {
        // Show a loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logging out...'),
            duration: Duration(seconds: 1),
          ),
        );
        
        // Actually sign out the user from Firebase Auth
        await FirebaseAuth.instance.signOut();
        print("User logged out from Firebase");
        
        // For testing purposes, add a debug print to confirm navigation is triggered
        print("Navigating to WelcomePage2...");
        
        // Use Future.delayed to ensure the auth state change has propagated
        // and to make sure any SnackBar messages have time to be seen
        Future.delayed(const Duration(milliseconds: 300), () {
          // Check if the widget is still mounted before navigating
          if (mounted) {
            // Use pushAndRemoveUntil to clear the navigation stack
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const WelcomePage2()),
              (Route<dynamic> route) => false, // This removes all previous routes
            );
          }
        });
      }
    } catch (e) {
      print("Error during logout: $e");
      // Make sure the widget is still mounted before showing the SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
              child: _isSearching
                  ? TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontFamily: 'Inter',
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search projects...',
                        hintStyle: TextStyle(
                          color: const Color(0xFF999999),
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[600], size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.close, color: Colors.grey[600], size: 20),
                          onPressed: _stopSearch,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    )
                  : InkWell(
                      onTap: _startSearch,
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
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () {
              // Show a popup menu when profile icon is tapped
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          leading: const Icon(Icons.person),
                          title: const Text('Profile'),
                          onTap: () {
                            Navigator.pop(context); // Close the bottom sheet
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ProfileScreen()),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.logout),
                          title: const Text('Logout'),
                          onTap: () { // This should navigate to WelcomePage2 when confirmed
                            Navigator.pop(context); // Close the bottom sheet
                            _handleLogout(context);
                          },
                        ),
                      ],
                    ),
                  );
                },
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
          GestureDetector(
            onTap: _showFilterDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0x11192F5D),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.filter_list, size: 16, color: const Color(0xFF192F5D).withOpacity(0.8)),
                  const SizedBox(width: 6),
                  const Text(
                    'Filters',
                    style: TextStyle(
                      color: Color(0xFF192F5D),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsList() {
    // Use the projects list from the class field instead of creating a local variable
    var filteredProjects = List<Map<String, dynamic>>.from(projects);
    
    // Display loading indicator while fetching projects
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Filter projects by search query
    if (_searchQuery.isNotEmpty) {
      filteredProjects = filteredProjects.where((project) => 
        project['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    // Apply status filters
    if (_showActiveOnly || _showAtRiskOnly || _showCompletedOnly) {
      filteredProjects = filteredProjects.where((project) {
        final status = project['status'].toString();
        if (_showActiveOnly && status == 'active') return true;
        if (_showAtRiskOnly && status == 'at-risk') return true;
        if (_showCompletedOnly && status == 'completed') return true;
        return false;
      }).toList();
    }
    
    // Apply sorting
    if (_selectedSortOption == 'Progress (High to Low)') {
      filteredProjects.sort((a, b) => (b['progress'] as double).compareTo(a['progress'] as double));
    } else if (_selectedSortOption == 'Progress (Low to High)') {
      filteredProjects.sort((a, b) => (a['progress'] as double).compareTo(b['progress'] as double));
    } else if (_selectedSortOption == 'Alphabetical (A-Z)') {
      filteredProjects.sort((a, b) => (a['title'] as String).compareTo(b['title'] as String));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          if (filteredProjects.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No projects found',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else
            ...filteredProjects.map((project) => Column(
              children: [
                Dismissible(
                  key: Key(project['title'] as String),
                  background: Container(
                    padding: const EdgeInsets.only(right: 20),
                    alignment: Alignment.centerRight,
                    color: Colors.red,
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    // Show confirmation dialog
                    return await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Delete Project'),
                          content: Text('Are you sure you want to delete "${project['title']}"?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('CANCEL'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text(
                                'DELETE',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        );
                      },
                    ) ?? false; // Return false if dialog is dismissed
                  },
                  onDismissed: (direction) {
                    // Remove project from the list
                    setState(() {
                      projects.removeWhere((p) => p['title'] == project['title']);
                    });
                    
                    // Delete from Firestore
                    _deleteProjectFromFirestore(project).then((_) {
                      // Show a snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Project "${project['title']}" deleted'),
                          action: SnackBarAction(
                            label: 'UNDO',
                            onPressed: () {
                              setState(() {
                                projects.add(project);
                                // Re-sort the list to maintain order
                                _applySorting();
                              });
                              // Restore in Firestore
                              _updateProjectInFirestore(project);
                            },
                          ),
                        ),
                      );
                    }).catchError((error) {
                      // Error already handled in the method
                      // Restore the project in the UI if Firestore delete fails
                      setState(() {
                        projects.add(project);
                        _applySorting();
                      });
                    });
                  },
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to TaskManager and pass project data
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskManager(
                            selectedProject: project['title'] as String,
                            projectColor: project['color'] as Color,
                            projectProgress: project['progress'] as double,
                            projectMembers: project['members'] as String,
                            projectStatus: project['status'] as String,
                          ),
                        ),
                      );
                    },
                    onLongPress: () {
                      // Show delete options in a modal bottom sheet
                      _showProjectOptions(project);
                    },
                    child: _buildProjectCard(
                      title: project['title'] as String,
                      members: project['members'] as String,
                      status: project['status'] as String,
                      progress: project['progress'] as double,
                      progressText: project['progressText'] as String,
                      color: project['color'] as Color,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            )),
          _buildCreateProjectButton(),
          // Add more padding at the bottom to prevent overflow
          const SizedBox(height: 36),
        ],
      ),
    );
  }

  // Method to sort projects based on selected sort option
  void _applySorting() {
    if (_selectedSortOption == 'Progress (High to Low)') {
      projects.sort((a, b) => (b['progress'] as double).compareTo(a['progress'] as double));
    } else if (_selectedSortOption == 'Progress (Low to High)') {
      projects.sort((a, b) => (a['progress'] as double).compareTo(b['progress'] as double));
    } else if (_selectedSortOption == 'Alphabetical (A-Z)') {
      projects.sort((a, b) => (a['title'] as String).compareTo(b['title'] as String));
    }
  }

  // Show options for a project (edit, delete, etc.)
  void _showProjectOptions(Map<String, dynamic> project) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  project['title'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF192F5D),
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.edit, color: Color(0xFF192F5D)),
                title: const Text('Edit Project'),
                onTap: () {
                  Navigator.pop(context);
                  _editProject(project);
                },
              ),
              ListTile(
                leading: Icon(
                  project['status'] == 'completed' 
                      ? Icons.refresh
                      : Icons.check_circle,
                  color: const Color(0xFF187E0F),
                ),
                title: Text(
                  project['status'] == 'completed'
                      ? 'Reopen Project'
                      : 'Mark as Completed',
                ),
                onTap: () {
                  Navigator.pop(context);
                  _updateProjectStatus(project);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Project', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteProject(project);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // Method to update project status
  void _updateProjectStatus(Map<String, dynamic> project) {
    setState(() {
      if (project['status'] == 'completed') {
        project['status'] = 'active';
        project['progress'] = 0.75; // Reset progress when reopening
        project['progressText'] = '75%';
      } else {
        project['status'] = 'completed';
        project['progress'] = 1.0;
        project['progressText'] = '100%';
      }
    });
    
    // Update in Firestore
    _updateProjectInFirestore(project).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            project['status'] == 'completed'
                ? 'Project "${project['title']}" marked as completed'
                : 'Project "${project['title']}" reopened'
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }).catchError((error) {
      // Error is already handled in the method
    });
  }

  // Method to update project in Firestore
  Future<void> _updateProjectInFirestore(Map<String, dynamic> project) async {
    try {
      // Check if the project has an ID (exists in Firestore)
      final String docId = project['id'] ?? 
        project['title'].toString().toLowerCase().replaceAll(' ', '_');
      
      // Convert progress from 0-1 range to percentage
      final int progressPercent = (project['progress'] * 100).round();
      
      // Extract member count from the members string
      final String membersStr = project['members'] as String;
      final int membersCount = int.tryParse(
        membersStr.split(' ')[0]
      ) ?? 0;
      
      await FirebaseFirestore.instance.collection('projects').doc(docId).set({
        'name': project['title'],
        'members_count': membersCount,
        'status': project['status'],
        'progress': progressPercent,
        'description': project['description'] ?? '',
        'updated_at': FieldValue.serverTimestamp(),
        // Only set created_at if it's a new document
        if (project['id'] == null) 'created_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      print("Project updated in Firestore: ${project['title']}");
      return;
    } catch (e) {
      print("Error updating project in Firestore: $e");
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating project: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      throw e;
    }
  }

  // Method to delete project from Firestore
  Future<void> _deleteProjectFromFirestore(Map<String, dynamic> project) async {
    try {
      final String docId = project['id'] ?? 
        project['title'].toString().toLowerCase().replaceAll(' ', '_');
      
      await FirebaseFirestore.instance.collection('projects').doc(docId).delete();
      print("Project deleted from Firestore: ${project['title']}");
      return;
    } catch (e) {
      print("Error deleting project from Firestore: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting project: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      throw e;
    }
  }

  // Method to handle project deletion with confirmation and Firebase sync
  void _deleteProject(Map<String, dynamic> project) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Project'),
          content: Text('Are you sure you want to delete "${project['title']}"?\nThis action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                // Store project temporarily for undo functionality
                final tempProject = Map<String, dynamic>.from(project);
                
                // Remove project from the list
                setState(() {
                  projects.removeWhere((p) => p['title'] == project['title']);
                });
                
                // Delete from Firestore
                _deleteProjectFromFirestore(project).then((_) {
                  // Show a snackbar with undo option
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Project "${project['title']}" deleted'),
                      action: SnackBarAction(
                        label: 'UNDO',
                        onPressed: () {
                          setState(() {
                            projects.add(tempProject);
                            // Re-sort the list to maintain order
                            _applySorting();
                          });
                          // Restore in Firestore
                          _updateProjectInFirestore(tempProject);
                        },
                      ),
                    ),
                  );
                }).catchError((error) {
                  // Error already handled in the method
                  // Restore the project in the UI if Firestore delete fails
                  setState(() {
                    projects.add(tempProject);
                    _applySorting();
                  });
                });
                
                Navigator.of(context).pop();
              },
              child: const Text(
                'DELETE',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  // Update _editProject method to sync with Firebase
  void _editProject(Map<String, dynamic> project) {
    // Make a copy of the project to edit
    final projectToEdit = Map<String, dynamic>.from(project);
    
    // Controllers for the edit form
    final nameController = TextEditingController(text: projectToEdit['title']);
    final descController = TextEditingController(text: projectToEdit['description'] ?? '');
    
    // Selected status in the dropdown
    String selectedStatus = projectToEdit['status'];
    
    // Current progress value for the slider
    double progressValue = projectToEdit['progress'];
    
    // Color selection
    Color selectedColor = projectToEdit['color'];
    final List<Color> colorOptions = [
      const Color(0xFF187E0F), // Green
      const Color(0xFFD14318), // Red/Orange
      const Color(0xFF192F5D), // Blue (app primary)
      const Color(0xFF9B870C), // Gold
      const Color(0xFF8E44AD), // Purple
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFFEEEEEE),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Edit Project',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF192F5D),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Color(0xFF192F5D)),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  
                  // Form
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Project Name
                          const Text(
                            'Project Name',
                            style: TextStyle(
                              color: Color(0xFF192F5D),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              hintText: 'Enter project name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Description
                          const Text(
                            'Description',
                            style: TextStyle(
                              color: Color(0xFF192F5D),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: descController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Enter description',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Status
                          const Text(
                            'Status',
                            style: TextStyle(
                              color: Color(0xFF192F5D),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedStatus,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'active',
                                    child: Text('Active'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'at-risk',
                                    child: Text('At Risk'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'completed',
                                    child: Text('Completed'),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      selectedStatus = value;
                                      // If completing, set progress to 100%
                                      if (value == 'completed') {
                                        progressValue = 1.0;
                                      }
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Progress
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Progress',
                                style: TextStyle(
                                  color: Color(0xFF192F5D),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${(progressValue * 100).round()}%',
                                style: const TextStyle(
                                  color: Color(0xFF192F5D),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: progressValue,
                            min: 0.0,
                            max: 1.0,
                            divisions: 20,
                            activeColor: selectedColor,
                            onChanged: (value) {
                              setState(() {
                                progressValue = value;
                                // Update status based on progress
                                if (value >= 1.0) {
                                  selectedStatus = 'completed';
                                } else if (value < 0.4) {
                                  selectedStatus = 'at-risk';
                                } else {
                                  selectedStatus = 'active';
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Color Selection
                          const Text(
                            'Project Color',
                            style: TextStyle(
                              color: Color(0xFF192F5D),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: colorOptions.map((color) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedColor = color;
                                  });
                                },
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: color == selectedColor
                                        ? Border.all(color: Colors.black, width: 2)
                                        : null,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Action buttons
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Color(0xFFEEEEEE),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: const Color(0xFF192F5D),
                              backgroundColor: Colors.white,
                              elevation: 0,
                              side: const BorderSide(color: Color(0xFF192F5D)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Update project with new values
                              projectToEdit['title'] = nameController.text;
                              projectToEdit['description'] = descController.text;
                              projectToEdit['status'] = selectedStatus;
                              projectToEdit['progress'] = progressValue;
                              projectToEdit['progressText'] = '${(progressValue * 100).round()}%';
                              projectToEdit['color'] = selectedColor;
                              
                              // Update the project in the list
                              this.setState(() {
                                final index = projects.indexWhere((p) => p['title'] == project['title']);
                                if (index != -1) {
                                  projects[index] = projectToEdit;
                                }
                              });
                              
                              // Update in Firestore
                              _updateProjectInFirestore(projectToEdit).then((_) {
                                // Show confirmation
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Project updated successfully'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }).catchError((error) {
                                // Error already handled in _updateProjectInFirestore
                              });
                              
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: const Color(0xFF192F5D),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Save Changes'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      // Dispose controllers when the modal is closed
      nameController.dispose();
      descController.dispose();
    });
  }

  // Enhanced Project card with animation
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
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 165,
      decoration: ShapeDecoration(
        color: const Color(0x56192F5D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        shadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Added ripple effect overlay for better user experience
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {}, // Empty onTap as we're handling tap in parent GestureDetector
                splashColor: color.withOpacity(0.1),
                highlightColor: color.withOpacity(0.05),
              ),
            ),
          ),
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
          // Status indicator on top right
          if (status == 'completed')
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF187E0F).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.check_circle, color: Color(0xFF187E0F), size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Completed',
                      style: TextStyle(
                        color: Color(0xFF187E0F),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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
                const SizedBox(height: 12),
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
                      color: status == 'active' ? const Color(0xFF187E0F) :
                             status == 'at-risk' ? const Color(0xFFD14318) :
                             const Color(0xFF187E0F),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      status == 'active' ? 'Active' :
                      status == 'at-risk' ? 'At Risk' :
                      'Completed',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.75),
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
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
                const SizedBox(height: 8),
                // Progress bar with animation
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 7,
                      decoration: ShapeDecoration(
                        color: const Color(0x26192F5D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      width: progressWidth,
                      height: 7,
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
      onTap: () async {
        // Navigate to CreateANewProject screen and wait for result
        final newProjectData = await Navigator.push<Map<String, dynamic>>(
          context,
          MaterialPageRoute(builder: (context) => const CreateANewProject()),
        );
        
        // If we got project data back, add it to our projects list
        if (newProjectData != null) {
          setState(() {
            projects.add(newProjectData);
            // Apply sorting to maintain order
            _applySorting();
          });
          
          // Save to Firestore
          _updateProjectInFirestore(newProjectData).then((_) {
            // Show confirmation message with animation
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('New project "${newProjectData['title']}" added'),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFF187E0F),
                duration: const Duration(seconds: 3),
              ),
            );
          }).catchError((error) {
            // Error already handled in _updateProjectInFirestore
          });
        }
      },
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: ShapeDecoration(
          color: const Color(0xFF192F5D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          shadows: [
            BoxShadow(
              color: const Color(0xFF192F5D).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Create New Project',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
