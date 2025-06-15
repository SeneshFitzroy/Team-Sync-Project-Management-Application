import 'package:flutter/material.dart';
import '../Components/nav_bar.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _filterAnimController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Filter states
  bool _showActiveOnly = false;
  bool _showAtRiskOnly = false;
  bool _showCompletedOnly = false;
  String _selectedSortOption = 'Progress (High to Low)';
  
  // Project list with enhanced data
  List<Map<String, dynamic>> projects = [
    {
      'id': '1',
      'title': 'Mobile App Development',
      'members': '4',
      'status': 'active',
      'progress': 0.75,
      'progressText': '75%',
      'color': const Color(0xFF4A90E2),
      'description': 'Flutter-based mobile application with advanced features',
      'deadline': DateTime.now().add(const Duration(days: 30)),
      'priority': 'High',
      'tasks': 12,
      'completedTasks': 9,
      'category': 'Development',
    },
    {
      'id': '2',
      'title': 'Website Redesign',
      'members': '3',
      'status': 'active',
      'progress': 0.45,
      'progressText': '45%',
      'color': const Color(0xFF50C878),
      'description': 'Complete website overhaul with modern UI/UX',
      'deadline': DateTime.now().add(const Duration(days: 15)),
      'priority': 'Medium',
      'tasks': 8,
      'completedTasks': 4,
      'category': 'Design',
    },
    {
      'id': '3',
      'title': 'Marketing Campaign',
      'members': '5',
      'status': 'completed',
      'progress': 1.0,
      'progressText': '100%',
      'color': const Color(0xFF32CD32),
      'description': 'Q2 marketing strategy and implementation',
      'deadline': DateTime.now().subtract(const Duration(days: 5)),
      'priority': 'High',
      'tasks': 15,
      'completedTasks': 15,
      'category': 'Marketing',
    },
    {
      'id': '4',
      'title': 'Data Analytics Dashboard',
      'members': '2',
      'status': 'active',
      'progress': 0.25,
      'progressText': '25%',
      'color': const Color(0xFFFF6B6B),
      'description': 'Real-time analytics and reporting system',
      'deadline': DateTime.now().add(const Duration(days: 45)),
      'priority': 'Low',
      'tasks': 20,
      'completedTasks': 5,
      'category': 'Analytics',
    },
  ];
  
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _filterAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
    _applySorting();
  }

  @override
  void dispose() {
    _filterAnimController.dispose();
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A365D), Color(0xFF4A90E2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _buildBody(),
          ),
        ),
      ),
      bottomNavigationBar: NavBar(
        selectedIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
      floatingActionButton: _selectedIndex == 0 ? _buildFloatingActionButton() : null,
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return _buildTasksView();
      case 2:
        return _buildChatView();
      case 3:
        return _buildCalendarView();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        _buildStatsSection(),
        _buildProjectsSection(),
      ],
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white, size: 28),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notifications coming soon!')),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.white, size: 28),
          onPressed: _showFilterDialog,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildStatsSection() {
    final activeProjects = projects.where((p) => p['status'] == 'active').length;
    final completedProjects = projects.where((p) => p['status'] == 'completed').length;
    final totalTasks = projects.fold<int>(0, (sum, p) => sum + (p['tasks'] as int));
    final completedTasks = projects.fold<int>(0, (sum, p) => sum + (p['completedTasks'] as int));

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isSearching) _buildSearchBar(),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Active Projects',
                    activeProjects.toString(),
                    Icons.work_outline,
                    const Color(0xFF4A90E2),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Completed',
                    completedProjects.toString(),
                    Icons.check_circle_outline,
                    const Color(0xFF50C878),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Tasks',
                    totalTasks.toString(),
                    Icons.assignment_outlined,
                    const Color(0xFFFF6B6B),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Progress',
                    '${((completedTasks / totalTasks) * 100).round()}%',
                    Icons.trending_up,
                    const Color(0xFFFFB347),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 32),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsSection() {
    final filteredProjects = _getFilteredProjects();
    
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Projects',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                TextButton(
                  onPressed: () => _showSortDialog(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.sort, color: Colors.white70, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        'Sort',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredProjects.length,
              itemBuilder: (context, index) {
                return _buildProjectCard(filteredProjects[index], index);
              },
            ),
            const SizedBox(height: 100), // Extra space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openProjectDetails(project),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: project['color'],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        project['title'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A365D),
                        ),
                      ),
                    ),
                    _buildStatusChip(project['status']),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  project['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                _buildProgressSection(project),
                const SizedBox(height: 16),
                _buildProjectFooter(project),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    
    switch (status) {
      case 'active':
        color = const Color(0xFF4A90E2);
        label = 'Active';
        break;
      case 'completed':
        color = const Color(0xFF50C878);
        label = 'Completed';
        break;
      case 'on-hold':
        color = const Color(0xFFFFB347);
        label = 'On Hold';
        break;
      default:
        color = Colors.grey;
        label = 'Unknown';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildProgressSection(Map<String, dynamic> project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Progress',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            Text(
              project['progressText'],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A365D),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: project['progress'],
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(project['color']),
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _buildProjectFooter(Map<String, dynamic> project) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.people_outline, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              '${project['members']} members',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(width: 16),
            Icon(Icons.task_alt, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              '${project['completedTasks']}/${project['tasks']} tasks',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: () => _editProject(project),
              color: Colors.grey[600],
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, size: 20),
              onPressed: () => _showProjectMenu(project),
              color: Colors.grey[600],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'Search projects...',
          hintStyle: TextStyle(color: Colors.white70),
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.white70),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Create project coming soon!')),
        );
      },
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF1A365D),
      icon: const Icon(Icons.add),
      label: const Text(
        'New Project',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  // Additional view builders
  Widget _buildTasksView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task, size: 64, color: Colors.white70),
          SizedBox(height: 16),
          Text(
            'Tasks',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 8),
          Text('Task management coming soon!', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildChatView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat, size: 64, color: Colors.white70),
          SizedBox(height: 16),
          Text(
            'Chat',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 8),
          Text('Team chat coming soon!', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildCalendarView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 64, color: Colors.white70),
          SizedBox(height: 16),
          Text(
            'Calendar',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 8),
          Text('Calendar view coming soon!', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  // Helper methods
  List<Map<String, dynamic>> _getFilteredProjects() {
    var filtered = projects.where((project) {
      if (_searchQuery.isNotEmpty) {
        return project['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
               project['description'].toLowerCase().contains(_searchQuery.toLowerCase());
      }
      if (_showActiveOnly && project['status'] != 'active') return false;
      if (_showCompletedOnly && project['status'] != 'completed') return false;
      return true;
    }).toList();

    return filtered;
  }

  void _applySorting() {
    projects.sort((a, b) {
      switch (_selectedSortOption) {
        case 'Progress (High to Low)':
          return b['progress'].compareTo(a['progress']);
        case 'Progress (Low to High)':
          return a['progress'].compareTo(b['progress']);
        case 'Alphabetical':
          return a['title'].compareTo(b['title']);
        case 'Recent':
          return b['deadline'].compareTo(a['deadline']);
        default:
          return 0;
      }
    });
  }

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openProjectDetails(Map<String, dynamic> project) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Project details coming soon!')),
    );
  }

  void _editProject(Map<String, dynamic> project) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit project feature coming soon!')),
    );
  }

  void _showProjectMenu(Map<String, dynamic> project) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Project'),
              onTap: () {
                Navigator.pop(context);
                _editProject(project);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Manage Team'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Team management coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text('Archive Project'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Archive feature coming soon!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Projects'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Active Projects Only'),
              value: _showActiveOnly,
              onChanged: (value) {
                setState(() {
                  _showActiveOnly = value ?? false;
                });
                Navigator.pop(context);
              },
            ),
            CheckboxListTile(
              title: const Text('Completed Projects Only'),
              value: _showCompletedOnly,
              onChanged: (value) {
                setState(() {
                  _showCompletedOnly = value ?? false;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _showActiveOnly = false;
                _showCompletedOnly = false;
              });
              Navigator.pop(context);
            },
            child: const Text('Clear All'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort Projects'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'Progress (High to Low)',
            'Progress (Low to High)',
            'Alphabetical',
            'Recent',
          ].map((option) => RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: _selectedSortOption,
            onChanged: (value) {
              setState(() {
                _selectedSortOption = value!;
                _applySorting();
              });
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }
}
