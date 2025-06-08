import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../Components/nav_bar.dart';
import '../Services/firebase_service.dart';
import 'Profile.dart';
import 'CreateaNewProject.dart';
import 'welcome-page1.dart';

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

  // Project list - using Firebase data with fallback to sample data
  List<Map<String, dynamic>> projects = [];
  bool _isLoading = false;
  StreamSubscription<QuerySnapshot>? _projectsSubscription;

  @override
  void initState() {
    super.initState();
    _filterAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    // Initialize with Firebase projects or fallback to sample data
    _loadFirebaseProjects();
  }

  void _loadFirebaseProjects() {
    setState(() {
      _isLoading = true;
    });

    try {
      // Listen to Firebase projects stream
      _projectsSubscription = FirebaseService.getUserProjects().listen(
        (snapshot) {
          if (mounted) {
            setState(() {
              projects = snapshot.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return {
                  'id': doc.id,
                  'title': data['title'] ?? 'Untitled Project',
                  'members': data['members'] is List 
                      ? '${(data['members'] as List).length} Members'
                      : data['members'] ?? '0 Members',
                  'status': data['status'] ?? 'active',
                  'progress': (data['progress'] ?? 0.0).toDouble(),
                  'progressText': '${((data['progress'] ?? 0.0) * 100).round()}%',
                  'color': _getProjectColor(data['status'] ?? 'active'),
                  'description': data['description'] ?? '',
                  'updatedAt': data['updatedAt'],
                };
              }).toList();
              _isLoading = false;
              _applySorting();
            });
          }
        },
        onError: (error) {
          print('Error loading projects: $error');
          // Fallback to sample data on error
          _loadSampleProjects();
        },
      );
    } catch (e) {
      print('Error setting up projects listener: $e');
      // Fallback to sample data on error
      _loadSampleProjects();
    }
  }

  Color _getProjectColor(String status) {
    switch (status) {
      case 'active':
        return const Color(0xFF187E0F);
      case 'at-risk':
        return const Color(0xFFD14318);
      case 'completed':
        return const Color(0xFF192F5D);
      default:
        return const Color(0xFF9B870C);
    }
  }

  void _loadSampleProjects() {
    // Fallback sample projects if Firebase fails
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          projects = [
            {
              'title': 'Mobile App Design',
              'members': '5 Members',
              'status': 'active',
              'progress': 0.75,
              'progressText': '75%',
              'color': const Color(0xFF187E0F),
              'description': 'Designing the new mobile app interface',
            },
            {
              'title': 'Website Redesign',
              'members': '3 Members',
              'status': 'at-risk',
              'progress': 0.35,
              'progressText': '35%',
              'color': const Color(0xFFD14318),
              'description': 'Complete website redesign project',
            },
            {
              'title': 'Marketing Campaign',
              'members': '4 Members',
              'status': 'completed',
              'progress': 1.0,
              'progressText': '100%',
              'color': const Color(0xFF192F5D),
              'description': 'Q4 marketing campaign planning',
            },
            {
              'title': 'Database Migration',
              'members': '2 Members',
              'status': 'active',
              'progress': 0.6,
              'progressText': '60%',
              'color': const Color(0xFF9B870C),
              'description': 'Migrating legacy database to cloud',
            },
          ];
          _isLoading = false;
          _applySorting();
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _filterAnimController.dispose();
    _projectsSubscription?.cancel();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    if (index != 0) {
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
                                // Apply the current filter states
                                _applySorting();
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

  Widget _buildFilterCheckbox(String title, bool value, Function(bool?) onChanged) {
    return CheckboxListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF192F5D),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildSortOption(String title, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF192F5D).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF192F5D) : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
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

  Future<void> _handleLogout() async {
    try {
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to log out?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Logout'),
              ),
            ],
          );
        },
      );

      if (confirm == true) {
        // Clear preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        
        // Navigate to welcome page
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const WelcomePage1()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      print("Logout error: $e");
      // Still navigate even if there's an error
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const WelcomePage1()),
          (route) => false,
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
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (BuildContext context) {
                  return SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
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
                            children: [
                              const Icon(Icons.person, color: Color(0xFF192F5D), size: 24),
                              const SizedBox(width: 12),
                              const Text(
                                'Profile Options',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF192F5D),
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.close, color: Color(0xFF192F5D)),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.person_outline, color: Color(0xFF192F5D)),
                          title: const Text(
                            'View Profile',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ProfileScreen()),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.logout, color: Colors.red),
                          title: const Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.red,
                            ),
                          ),
                          onTap: () async {
                            Navigator.pop(context);
                            await _handleLogout();
                          },
                        ),
                        const SizedBox(height: 16),
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
    var filteredProjects = List<Map<String, dynamic>>.from(projects);
    
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
    
    return Column(
      children: [
        ...filteredProjects.map((project) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: GestureDetector(
                onTap: () {
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
        const SizedBox(height: 36),
      ],
    );
  }

  void _applySorting() {
    if (_selectedSortOption == 'Progress (High to Low)') {
      projects.sort((a, b) => (b['progress'] as double).compareTo(a['progress'] as double));
    } else if (_selectedSortOption == 'Progress (Low to High)') {
      projects.sort((a, b) => (a['progress'] as double).compareTo(b['progress'] as double));
    } else if (_selectedSortOption == 'Alphabetical (A-Z)') {
      projects.sort((a, b) => (a['title'] as String).compareTo(b['title'] as String));
    }
  }

  Widget _buildProjectCard({
    required String title,
    required String members,
    required String status,
    required double progress,
    required String progressText,
    required Color color,
  }) {
    final availableWidth = MediaQuery.of(context).size.width - 48 - 24;
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
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {},
                splashColor: color.withOpacity(0.1),
                highlightColor: color.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 8,
              height: 165,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
        final newProjectData = await Navigator.push<Map<String, dynamic>>(
          context,
          MaterialPageRoute(builder: (context) => const CreateANewProject()),
        );
        
        if (newProjectData != null) {
          try {
            // Save project to Firebase
            final projectId = await FirebaseService.createProject({
              'title': newProjectData['title'],
              'description': newProjectData['description'],
              'status': 'active',
              'progress': 0.0,
              'members': [], // Will be updated when team members are added
            });
            
            // Log activity
            await FirebaseService.logActivity('project_created', {
              'projectId': projectId,
              'projectTitle': newProjectData['title'],
              'timestamp': DateTime.now().toIso8601String(),
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('New project "${newProjectData['title']}" created'),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFF187E0F),
                duration: const Duration(seconds: 3),
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error creating project: $e'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24.0),
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
