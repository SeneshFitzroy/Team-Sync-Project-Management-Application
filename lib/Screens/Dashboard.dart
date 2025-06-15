import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../Components/nav_bar.dart';
import 'package:fluttercomponenets/Services/firebase_service.dart';
import 'Profile.dart';
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
  // Project list
  List<Map<String, dynamic>> projects = [];
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription<QuerySnapshot>? _projectsSubscription;
  User? _currentUser;

  // Modal dialog states
  bool isLoading = false;
  bool isSearching = false;
  List<Map<String, dynamic>> publicProjects = [];

  @override
  void initState() {
    super.initState();
    _filterAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _initializeUserAndProjects();
  }

  void _initializeUserAndProjects() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser == null) {
      // Redirect to login if not authenticated
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const WelcomePage1()),
        (route) => false,
      );
      return;
    }
    _loadFirebaseProjects();
  }

  void _loadFirebaseProjects() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _projectsSubscription?.cancel(); // Cancel any existing subscription
      _projectsSubscription = FirebaseService.getUserProjects(userId: _currentUser!.uid).listen(
        (snapshot) {
          if (!mounted) return;
          setState(() {
            projects = snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return {
                'id': doc.id,
                'title': data['title'] ?? 'Untitled Project',
                'members': (data['members'] as List<dynamic>?)?.length.toString() ?? '0',
                'status': data['status'] ?? 'active',
                'progress': (data['progress']?.toDouble() ?? 0.0),
                'progressText': '${((data['progress']?.toDouble() ?? 0.0) * 100).round()}%',
                'color': _getProjectColor(data['status'] ?? 'active'),
                'description': data['description'] ?? '',
                'updatedAt': (data['updatedAt'] as Timestamp?)?.toDate(),
              };
            }).toList();
            _isLoading = false;
            _applySorting();
          });
        },
        onError: (error) {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
            _errorMessage = 'Failed to load projects: $error';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading projects: $error'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error setting up projects: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getProjectColor(String status) {
    switch (status.toLowerCase()) {
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
          Navigator.pushReplacementNamed(context, '/taskmanager');
          break;
        case 2: // Chat
          Navigator.pushReplacementNamed(context, '/chat');
          break;
        case 3: // Calendar
          Navigator.pushReplacementNamed(context, '/calendar');
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
        await FirebaseAuth.instance.signOut();
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const WelcomePage1()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout error: $e'),
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
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadFirebaseProjects,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (projects.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'No projects found. Create a new project to get started!',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    var filteredProjects = List<Map<String, dynamic>>.from(projects);

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filteredProjects = filteredProjects.where((project) {
        return (project['title'] as String).toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply status filters
    if (_showActiveOnly || _showAtRiskOnly || _showCompletedOnly) {
      filteredProjects = filteredProjects.where((project) {
        final status = project['status'].toString().toLowerCase();
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
                  Navigator.pushNamed(
                    context,
                    '/taskmanager',
                    arguments: {
                      'selectedProject': project['title'] as String,
                      'projectColor': project['color'] as Color,
                      'projectProgress': project['progress'] as double,
                      'projectMembers': project['members'] as String,
                      'projectStatus': project['status'] as String,
                      'projectId': project['id'] as String,
                    },
                  );
                },
                child: _buildProjectCard(
                  title: project['title'] as String,
                  members: '${project['members']} Members',
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
    setState(() {
      if (_selectedSortOption == 'Progress (High to Low)') {
        projects.sort((a, b) => (b['progress'] as double).compareTo(a['progress'] as double));
      } else if (_selectedSortOption == 'Progress (Low to High)') {
        projects.sort((a, b) => (a['progress'] as double).compareTo(b['progress'] as double));
      } else if (_selectedSortOption == 'Alphabetical (A-Z)') {
        projects.sort((a, b) => (a['title'] as String).compareTo(b['title'] as String));
      }
    });
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
          if (status.toLowerCase() == 'completed')
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
                      status.toLowerCase() == 'active'
                          ? Icons.check_circle
                          : status.toLowerCase() == 'at-risk'
                              ? Icons.warning
                              : Icons.task_alt,
                      size: 16,
                      color: status.toLowerCase() == 'active'
                          ? const Color(0xFF187E0F)
                          : status.toLowerCase() == 'at-risk'
                              ? const Color(0xFFD14318)
                              : const Color(0xFF187E0F),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      status.toLowerCase() == 'active'
                          ? 'Active'
                          : status.toLowerCase() == 'at-risk'
                              ? 'At Risk'
                              : 'Completed',
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          // Create New Project Button
          Expanded(
            child: GestureDetector(
              onTap: _showCreateProjectDialog,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF192F5D),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF192F5D).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline, color: Colors.white, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Create Project',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Join Project Button
          Expanded(
            child: GestureDetector(
              onTap: _showJoinProjectDialog,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF192F5D), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.group_add, color: Color(0xFF192F5D), size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Join Project',
                      style: TextStyle(
                        color: Color(0xFF192F5D),
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateProjectDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCreateProjectModal(),
    );
  }

  void _showJoinProjectDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildJoinProjectModal(),
    );
  }
  Widget _buildCreateProjectModal() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    bool isPublic = false;
    bool isLoading = false;

    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Text(
                      'Create New Project',
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
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
              
              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Project Title
                      const Text(
                        'Project Title',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF192F5D),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          hintText: 'Enter project title',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0x33192F5D)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF192F5D), width: 2),
                          ),
                          filled: true,
                          fillColor: const Color(0x0A192F5D),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Project Description
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF192F5D),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: descriptionController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Describe your project...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0x33192F5D)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF192F5D), width: 2),
                          ),
                          filled: true,
                          fillColor: const Color(0x0A192F5D),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Public/Private Toggle
                      Row(
                        children: [
                          const Text(
                            'Make project public',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF192F5D),
                            ),
                          ),
                          const Spacer(),
                          Switch(
                            value: isPublic,
                            onChanged: (value) {
                              setModalState(() {
                                isPublic = value;
                              });
                            },
                            activeColor: const Color(0xFF192F5D),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isPublic 
                          ? 'Others can discover and join this project'
                          : 'Only invited members can join this project',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Action Buttons
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () => _createProject(
                          titleController.text,
                          descriptionController.text,
                          isPublic,
                          setModalState,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF192F5D),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Create Project',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
  }

  Widget _buildJoinProjectModal() {
    final inviteCodeController = TextEditingController();
    bool isLoading = false;
    List<Map<String, dynamic>> publicProjects = [];
    bool isSearching = false;

    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Text(
                      'Join Project',
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
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
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Join by Invite Code
                      const Text(
                        'Join by Invite Code',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF192F5D),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: inviteCodeController,
                              decoration: InputDecoration(
                                hintText: 'Enter invite code',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0x33192F5D)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF192F5D), width: 2),
                                ),
                                filled: true,
                                fillColor: const Color(0x0A192F5D),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: isLoading ? null : () => _joinProjectByCode(
                              inviteCodeController.text,
                              setModalState,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF192F5D),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Join'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      // Browse Public Projects
                      Row(
                        children: [
                          const Text(
                            'Browse Public Projects',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF192F5D),
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => _loadPublicProjects(setModalState),
                            child: const Text('Refresh'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Public Projects List
                      if (isSearching)
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: CircularProgressIndicator(color: Color(0xFF192F5D)),
                          ),
                        )
                      else if (publicProjects.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 12),
                              Text(
                                'No public projects available',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () => _loadPublicProjects(setModalState),
                                child: const Text('Search for projects'),
                              ),
                            ],
                          ),
                        )
                      else
                        ...publicProjects.map((project) => _buildPublicProjectCard(project, setModalState)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPublicProjectCard(Map<String, dynamic> project, StateSetter setModalState) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  project['title'] ?? 'Untitled Project',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF192F5D),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => _joinProject(project['id'], setModalState),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF192F5D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Join'),
              ),
            ],
          ),
          if (project['description'] != null && project['description'].isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              project['description'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.people, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${project['memberCount'] ?? 0} members',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _createProject(String title, String description, bool isPublic, StateSetter setModalState) async {
    if (title.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a project title')),
      );
      return;
    }

    setModalState(() {
      isLoading = true;
    });

    try {
      final projectId = await FirebaseService.createProject(
        {
          'title': title.trim(),
          'description': description.trim(),
          'status': 'active',
          'progress': 0.0,
          'members': [_currentUser!.uid],
          'memberCount': 1,
          'isPublic': isPublic,
          'isActive': true,
          'inviteCode': _generateInviteCode(),
        },
        userId: _currentUser!.uid,
      );

      await FirebaseService.logActivity(
        'project_created',
        {
          'projectId': projectId,
          'projectTitle': title,
          'isPublic': isPublic,
        },
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Project "$title" created successfully!')),
              ],
            ),
            backgroundColor: const Color(0xFF187E0F),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating project: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setModalState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _joinProjectByCode(String inviteCode, StateSetter setModalState) async {
    if (inviteCode.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an invite code')),
      );
      return;
    }

    setModalState(() {
      isLoading = true;
    });

    try {
      final project = await FirebaseService.getProjectByInviteCode(inviteCode.trim());
      if (project == null) {
        throw Exception('Invalid invite code');
      }

      final success = await FirebaseService.joinProject(
        projectId: project['id'],
        userId: _currentUser!.uid,
      );

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Successfully joined "${project['title']}"!')),
              ],
            ),
            backgroundColor: const Color(0xFF187E0F),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error joining project: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setModalState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _joinProject(String projectId, StateSetter setModalState) async {
    setModalState(() {
      isLoading = true;
    });

    try {
      final success = await FirebaseService.joinProject(
        projectId: projectId,
        userId: _currentUser!.uid,
      );

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Successfully joined the project!'),
              ],
            ),
            backgroundColor: Color(0xFF187E0F),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error joining project: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setModalState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadPublicProjects(StateSetter setModalState) async {
    setModalState(() {
      isSearching = true;
    });

    try {
      final projects = await FirebaseService.searchPublicProjects(limit: 10);
      setModalState(() {
        publicProjects = projects;
        isSearching = false;
      });
    } catch (e) {
      setModalState(() {
        isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading projects: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';    final random = DateTime.now().millisecondsSinceEpoch;
    String code = '';
    for (int i = 0; i < 6; i++) {
      code += chars[(random + i) % chars.length];
    }
    return code;
  }
}