import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../widgets/TickLogo.dart';
import './Profile.dart';
import './TaskPage.dart';
import './ProjectsPage.dart';
import '../blocs/dashboard_bloc.dart';
import '../blocs/project_bloc.dart';
import '../blocs/task_bloc.dart';
import '../blocs/member_request_bloc.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import '../services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _particleController;
  
  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _particleAnimation;

  String userName = 'User';
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserInfo();
    
    // Load dashboard data
    context.read<DashboardBloc>().add(LoadDashboardData());
    context.read<ProjectBloc>().add(LoadProjects());
    context.read<TaskBloc>().add(LoadTasks());
    context.read<MemberRequestBloc>().add(LoadPendingRequests());
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_particleController);

    _fadeController.forward();
    _slideController.forward();
    _particleController.repeat();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _particleController.dispose();
    _searchController.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          userName = user.displayName ?? user.email?.split('@')[0] ?? 'User';
        });
      }
    } catch (e) {
      print('Error loading user info: $e');
    }
  }

  void _onSearchChanged(String query) {
    // Cancel previous timer
    _searchTimer?.cancel();
    
    // Create new timer with 500ms delay
    _searchTimer = Timer(Duration(milliseconds: 500), () {
      if (query.isEmpty) {
        context.read<DashboardBloc>().add(LoadDashboardData());
      } else {
        context.read<DashboardBloc>().add(SearchDashboardContent(query));
      }
    });
  }

  void _refreshData() {
    context.read<DashboardBloc>().add(RefreshDashboardData());
    context.read<ProjectBloc>().add(LoadProjects());
    context.read<TaskBloc>().add(LoadTasks());
    context.read<MemberRequestBloc>().add(LoadPendingRequests());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryBlue,
              Color(0xFF764BA2),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated particle background
            AnimatedBuilder(
              animation: _particleAnimation,
              child: Container(),
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticlePainter(_particleAnimation.value),
                  size: Size.infinite,
                );
              },
            ),
            
            // Main content
            SafeArea(
              child: RefreshIndicator(
                onRefresh: () async => _refreshData(),
                color: Colors.white,
                backgroundColor: AppTheme.primaryBlue,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          SlideTransition(
                            position: _slideAnimation,
                            child: _buildHeader(),
                          ),
                          
                          SizedBox(height: 20),
                          
                          // Search Bar
                          SlideTransition(
                            position: _slideAnimation,
                            child: _buildSearchBar(),
                          ),
                          
                          SizedBox(height: 25),
                          
                          // Dashboard Content
                          BlocBuilder<DashboardBloc, DashboardState>(
                            builder: (context, state) {
                              if (state is DashboardLoading) {
                                return _buildLoadingWidget();
                              } else if (state is DashboardLoaded) {
                                return _buildDashboardContent(state);
                              } else if (state is DashboardSearchResults) {
                                return _buildSearchResults(state);
                              } else if (state is DashboardError) {
                                return _buildErrorWidget(state.message);
                              }
                              return _buildLoadingWidget();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            TickLogo(size: 40),
            SizedBox(width: 12),
            Text(
              'Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        Row(
          children: [
            BlocBuilder<MemberRequestBloc, MemberRequestState>(
              builder: (context, state) {
                int notificationCount = 0;
                if (state is RequestsLoaded) {
                  notificationCount = state.pendingRequests.length;
                }
                
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      IconButton(
                        icon: Icon(Icons.notifications_outlined, color: Colors.white),
                        onPressed: () {
                          _showNotifications();
                        },
                      ),
                      if (notificationCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '$notificationCount',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Icon(Icons.person_outline, color: Colors.white, size: 24),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showNotifications() {
    // Load pending requests first
    context.read<MemberRequestBloc>().add(LoadPendingRequests());
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocBuilder<MemberRequestBloc, MemberRequestState>(
        builder: (context, state) {
          if (state is RequestsLoaded) {
            return _buildNotificationSheet(state.pendingRequests);
          }
          return Container(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationSheet(List<MemberRequestWithDetails> requests) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: AppTheme.primaryBlue),
                ),
              ],
            ),
          ),
          Expanded(
            child: requests.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No notifications',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final requestWithDetails = requests[index];
                      return _buildNotificationItem(requestWithDetails);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(MemberRequestWithDetails requestWithDetails) {
    final request = requestWithDetails.request;
    final fromUser = requestWithDetails.fromUser;
    final project = requestWithDetails.project;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primaryBlue,
                child: Text(
                  fromUser?.initials ?? '?',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${fromUser?.fullName ?? 'Unknown User'} invited you to join',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      project?.name ?? 'Unknown Project',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (request.message.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(
              request.message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context.read<MemberRequestBloc>().add(AcceptRequest(request.id!));
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Accept'),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.read<MemberRequestBloc>().add(DeclineRequest(request.id!));
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.primaryBlue),
                    foregroundColor: AppTheme.primaryBlue,
                  ),
                  child: Text('Decline'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: TextStyle(color: Colors.black, fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Search projects and tasks...',
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 16),
          prefixIcon: Icon(Icons.search, color: Colors.grey[700], size: 24),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(40),
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 20),
            Text(
              'Loading your dashboard...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.white.withOpacity(0.8),
            size: 48,
          ),
          SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshData,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              foregroundColor: Colors.white,
            ),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(DashboardLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Welcome Card
        SlideTransition(
          position: _slideAnimation,
          child: _buildWelcomeCard(),
        ),
        
        SizedBox(height: 25),
        
        // Task Statistics
        SlideTransition(
          position: _slideAnimation,
          child: _buildEnhancedTaskStatistics(state.stats),
        ),
        
        SizedBox(height: 25),
        
        // Projects
        SlideTransition(
          position: _slideAnimation,
          child: _buildProjectsSection(state.recentProjects),
        ),
        
        SizedBox(height: 25),
        
        // Upcoming Tasks
        SlideTransition(
          position: _slideAnimation,
          child: _buildUpcomingTasks(context, state.upcomingTasks),
        ),
        
        SizedBox(height: 25),
        
        // Projects Due Today
        if (state.projectsDueToday.isNotEmpty) ...[
          SlideTransition(
            position: _slideAnimation,
            child: _buildProjectsDueToday(state.projectsDueToday),
          ),
          SizedBox(height: 25),
        ],
        
        // Project Progress
        if (state.projectProgress.isNotEmpty) ...[
          SlideTransition(
            position: _slideAnimation,
            child: _buildProjectProgress(state.projectProgress),
          ),
          SizedBox(height: 25),
        ],
        
        // Team Members
        if (state.teamMembers.isNotEmpty) ...[
          SlideTransition(
            position: _slideAnimation,
            child: _buildTeamMembers(state.teamMembers),
          ),
          SizedBox(height: 25),
        ],
        
        // Create Project Button
        SlideTransition(
          position: _slideAnimation,
          child: _buildCreateProjectButton(context),
        ),
        SizedBox(height: 25),
      ],
    );
  }

  Widget _buildSearchResults(DashboardSearchResults state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search Results for "${state.query}"',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 20),
        if (state.results.isEmpty)
          Container(
            padding: EdgeInsets.all(40),
            child: Column(
              children: [
                Icon(
                  Icons.search_off,
                  color: Colors.white.withOpacity(0.6),
                  size: 48,
                ),
                SizedBox(height: 16),
                Text(
                  'No results found',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          )
        else
          ...state.results.map((result) => _buildSearchResultItem(result)),
      ],
    );
  }

  Widget _buildSearchResultItem(Map<String, dynamic> result) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            result['type'] == 'project' ? Icons.folder_outlined : Icons.task_outlined,
            color: Colors.white,
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result['title'] ?? '',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if ((result['subtitle'] ?? '').isNotEmpty)
                  Text(
                    result['subtitle'] ?? '',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Chip(
            label: Text(
              result['type'].toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
            backgroundColor: AppTheme.primaryBlue.withOpacity(0.8),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryBlue, Color(0xFF764BA2)],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(Icons.waving_hand, color: Colors.white, size: 28),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Ready to tackle your tasks today? Let\'s make it productive!',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedTaskStatistics(Map<String, dynamic> stats) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                'Your Statistics',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildStatCard(
                'Projects', 
                stats['totalProjects'] ?? 0, 
                Icons.folder_outlined, 
                [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProjectsPage())),
              )),
              SizedBox(width: 12),
              Expanded(child: _buildStatCard(
                'Tasks', 
                stats['totalTasks'] ?? 0, 
                Icons.assignment_outlined, 
                [Color(0xFFE17055), Color(0xFFFAB1A0)],
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TaskPage())),
              )),
            ],
          ),
          SizedBox(width: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard(
                'Team Members', 
                stats['totalTeamMembers'] ?? 0, 
                Icons.people_outline, 
                [Color(0xFF00B894), Color(0xFF55EFC4)],
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProjectsPage())),
              )),
            ],
          ),
          // Completion Rate Progress Bar
          if ((stats['totalTasks'] ?? 0) > 0) ...[
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Completion Rate',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${stats['completionRate'] ?? 0}%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (stats['completionRate'] ?? 0) / 100,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        (stats['completionRate'] ?? 0) >= 75 
                            ? Colors.green 
                            : (stats['completionRate'] ?? 0) >= 50 
                                ? Colors.orange 
                                : Colors.red,
                      ),
                      minHeight: 8,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${stats['completedTasks'] ?? 0} of ${stats['totalTasks'] ?? 0} tasks completed',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int value, IconData icon, List<Color> gradientColors, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            SizedBox(height: 8),
            Text(
              value.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            if (onTap != null) ...[
              SizedBox(height: 4),
              Icon(
                Icons.touch_app,
                color: Colors.white.withOpacity(0.7),
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }



  Widget _buildProjectsSection(List<Project> projects) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.folder_outlined, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                'Projects',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (projects.isEmpty)
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.folder_open,
                    color: Colors.white.withOpacity(0.6),
                    size: 48,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No projects found',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          else
            ...projects.take(3).map((project) => GestureDetector(
              onTap: () => _showProjectDetails(project),
              child: Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getStatusColor(project.status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (project.description.isNotEmpty) ...[
                            SizedBox(height: 4),
                            Text(
                              project.description,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.group,
                                color: Colors.white.withOpacity(0.7),
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '${project.teamMembers.length} members',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                              Spacer(),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(project.status).withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _getStatusText(project.status),
                                  style: TextStyle(
                                    color: _getStatusColor(project.status),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white.withOpacity(0.5),
                      size: 16,
                    ),
                  ],
                ),
              ),
            )).toList(),
        ],
      ),
    );
  }

  void _showProjectDetails(Project project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.folder, color: AppTheme.primaryBlue),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                project.name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Description Section
              _buildDetailSection('Description:', 
                project.description.isEmpty ? 'No description provided' : project.description),
              
              SizedBox(height: 16),
              
              // Progress Chart Section
              Text('Project Progress:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 12),
              FutureBuilder<Map<String, int>>(
                future: _getProjectProgress(project.id ?? ''),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  
                  if (!snapshot.hasData) {
                    return Container(
                      height: 150,
                      child: Center(child: Text('No progress data available')),
                    );
                  }
                  
                  final progressData = snapshot.data!;
                  final total = progressData['total'] ?? 0;
                  final completed = progressData['completed'] ?? 0;
                  final inProgress = progressData['inProgress'] ?? 0;
                  final todo = progressData['todo'] ?? 0;
                  
                  if (total == 0) {
                    return Container(
                      height: 150,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment, size: 48, color: Colors.grey[400]),
                            SizedBox(height: 8),
                            Text(
                              'No tasks yet',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              'Create tasks to track progress',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  return Container(
                    height: 250,
                    child: Column(
                      children: [
                        // Progress Statistics
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildProgressStat('Completed', completed, Colors.green),
                            _buildProgressStat('In Progress', inProgress, Colors.orange),
                            _buildProgressStat('To Do', todo, Colors.blue),
                          ],
                        ),
                        SizedBox(height: 16),
                        // Progress Bar
                        Container(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Overall Progress: ${((completed / total) * 100).toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: completed / total,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  completed / total >= 0.8 ? Colors.green :
                                  completed / total >= 0.5 ? Colors.orange : Colors.blue,
                                ),
                                minHeight: 8,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              SizedBox(height: 16),
              
              // Status Section
              Text('Status:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(project.status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusText(project.status),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Team Members Section
              Text('Team Members:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.people, color: AppTheme.primaryBlue),
                    SizedBox(width: 8),
                    Text(
                      '${project.teamMembers.length} members',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              
              if (project.dueDate != null) ...[
                SizedBox(height: 16),
                
                // Due Date Section
                Text('Due Date:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: AppTheme.primaryBlue),
                      SizedBox(width: 8),
                      Text(
                        '${project.dueDate!.day}/${project.dueDate!.month}/${project.dueDate!.year}',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
              
              SizedBox(height: 16),
              
              // Created Date Section
              Text('Created:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: AppTheme.primaryBlue),
                    SizedBox(width: 8),
                    Text(
                      '${project.createdAt.day}/${project.createdAt.month}/${project.createdAt.year}',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryBlue,
            ),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String label, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            content,
            style: TextStyle(fontSize: 14, height: 1.4),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning:
        return Colors.orange;
      case ProjectStatus.active:
        return Colors.green;
      case ProjectStatus.completed:
        return Colors.blue;
      case ProjectStatus.paused:
        return Colors.yellow;
      case ProjectStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning:
        return 'Planning';
      case ProjectStatus.active:
        return 'Active';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.paused:
        return 'Paused';
      case ProjectStatus.cancelled:
        return 'Cancelled';
    }
  }
}

  Widget _buildUpcomingTasks(BuildContext context, List<Task> tasks) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                'Upcoming Deadlines',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (tasks.isEmpty)
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.white.withOpacity(0.6),
                    size: 48,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'All caught up!',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No upcoming deadlines to worry about.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else
            ...tasks.take(3).map((task) => _buildTaskCard(task)),
          if (tasks.length > 3) ...[
            SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TaskPage()),
                );
              },
              child: Text(
                'View All Tasks (${tasks.length})',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    final isOverdue = task.isOverdue;
    final daysUntilDue = task.dueDate.difference(DateTime.now()).inDays;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isOverdue 
            ? Colors.red.withOpacity(0.2)
            : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOverdue 
              ? Colors.red.withOpacity(0.5)
              : Colors.white.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getPriorityColor(task.priority),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getPriorityIcon(task.priority),
              color: Colors.white,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: isOverdue ? Colors.red[300] : Colors.white.withOpacity(0.8),
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      isOverdue 
                          ? 'Overdue by ${(-daysUntilDue)} days'
                          : daysUntilDue == 0 
                              ? 'Due today'
                              : 'Due in $daysUntilDue days',
                      style: TextStyle(
                        color: isOverdue ? Colors.red[300] : Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(width: 12),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(task.priority),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        task.priority.name.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
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

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.urgent:
        return Colors.purple;
    }
  }

  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Icons.low_priority;
      case TaskPriority.medium:
        return Icons.remove;
      case TaskPriority.high:
        return Icons.priority_high;
      case TaskPriority.urgent:
        return Icons.warning;
    }
  }

  Widget _buildProjectProgress(List<Map<String, dynamic>> projectProgress) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                'Project Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...projectProgress.take(3).map((item) => _buildProgressItem(item)),
        ],
      ),
    );
  }

  Widget _buildProgressItem(Map<String, dynamic> item) {
    final project = item['project'] as Project;
    final progress = item['progress'] as double;
    final totalTasks = item['totalTasks'] as int;
    final completedTasks = item['completedTasks'] as int;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                project.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              progress > 0.7 ? Colors.green : progress > 0.4 ? Colors.orange : Colors.red,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '$completedTasks of $totalTasks tasks completed',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMembers(List<UserModel> members) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.group, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                'Team Members',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: members.take(8).map((member) => _buildMemberAvatar(member)).toList(),
          ),
          if (members.length > 8) ...[
            SizedBox(height: 12),
            Text(
              '+${members.length - 8} more team members',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMemberAvatar(UserModel member) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: AppTheme.primaryBlue,
          child: Text(
            member.initials,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(
          member.fullName.split(' ').first,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildProjectsDueToday(List<Project> projects) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.today, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                'Projects Due Today',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(0xFFFFB142),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${projects.length}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...projects.map((project) => Container(
            margin: EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Color(0xFFFFB142),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (project.description.isNotEmpty) ...[
                        SizedBox(height: 4),
                        Text(
                          project.description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.group,
                            color: Colors.white.withOpacity(0.7),
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${project.teamMembers.length} members',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                          Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Color(0xFFFFB142).withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Due Today',
                              style: TextStyle(
                                color: Color(0xFFFFB142),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
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
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildCreateProjectButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.create_new_folder, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                'Project Management',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => _showCreateProjectDialog(context),
              icon: Icon(Icons.add, size: 20),
              label: Text(
                'Create New Project',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateProjectDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final budgetController = TextEditingController();
    final clientController = TextEditingController();
    DateTime? selectedDueDate;
    DateTime? selectedStartDate;
    String selectedPriority = 'Medium';
    String selectedStatus = 'Planning';
    List<UserModel> allUsers = [];
    List<String> selectedMemberIds = [];
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.add_box, color: AppTheme.primaryBlue),
              SizedBox(width: 8),
              Text('Create New Project'),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(maxHeight: 700),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Project Name
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Project Name *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.folder),
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Description
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Project Description *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),
                  
                  // Client/Organization
                  TextField(
                    controller: clientController,
                    decoration: InputDecoration(
                      labelText: 'Client/Organization',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.business),
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Budget
                  TextField(
                    controller: budgetController,
                    decoration: InputDecoration(
                      labelText: 'Budget (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 16),
                  
                  // Priority Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedPriority,
                    decoration: InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.priority_high),
                    ),
                    items: ['Low', 'Medium', 'High', 'Critical'].map((priority) {
                      return DropdownMenuItem(
                        value: priority,
                        child: Text(priority),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedPriority = value!;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  
                  // Status Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Initial Status',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.flag),
                    ),
                    items: ['Planning', 'Active', 'On Hold'].map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value!;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  
                  // Start Date
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.play_arrow),
                      title: Text(
                        selectedStartDate == null
                            ? 'Select Start Date'
                            : 'Start: ${selectedStartDate!.day}/${selectedStartDate!.month}/${selectedStartDate!.year}',
                      ),
                      trailing: selectedStartDate != null
                          ? IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  selectedStartDate = null;
                                });
                              },
                            )
                          : null,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedStartDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(Duration(days: 365 * 2)),
                        );
                        if (date != null) {
                          setState(() {
                            selectedStartDate = date;
                          });
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Due Date
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.calendar_today),
                      title: Text(
                        selectedDueDate == null
                            ? 'Select Due Date'
                            : 'Due: ${selectedDueDate!.day}/${selectedDueDate!.month}/${selectedDueDate!.year}',
                      ),
                      trailing: selectedDueDate != null
                          ? IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  selectedDueDate = null;
                                });
                              },
                            )
                          : null,
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDueDate ?? DateTime.now().add(Duration(days: 30)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDueDate = picked;
                          });
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Team Members Section
                  Text(
                    'Team Members',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: FutureBuilder<List<UserModel>>(
                      future: FirebaseService.getAllUsers(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(child: Text('No users found'));
                        }
                        
                        allUsers = snapshot.data!;
                        
                        return ListView.builder(
                          itemCount: allUsers.length,
                          itemBuilder: (context, index) {
                            final user = allUsers[index];
                            final isSelected = selectedMemberIds.contains(user.uid);
                            
                            return CheckboxListTile(
                              title: Text(user.fullName),
                              subtitle: Text(user.email),
                              value: isSelected,
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    selectedMemberIds.add(user.uid);
                                  } else {
                                    selectedMemberIds.remove(user.uid);
                                  }
                                });
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
              ),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && descriptionController.text.isNotEmpty) {
                  // Add current user as a team member automatically
                  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
                  if (currentUserId != null && !selectedMemberIds.contains(currentUserId)) {
                    selectedMemberIds.add(currentUserId);
                  }
                  
                  // Create project with enhanced data
                  _createEnhancedProject(
                    name: nameController.text,
                    description: descriptionController.text,
                    client: clientController.text,
                    budget: budgetController.text,
                    priority: selectedPriority,
                    status: selectedStatus,
                    startDate: selectedStartDate,
                    dueDate: selectedDueDate,
                    teamMembers: selectedMemberIds,
                    context: context,
                  );
                  
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please fill in the required fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
              ),
              child: Text('Create Project'),
            ),
          ],
        ),
      ),
    );
  }

  void _createEnhancedProject({
    required String name,
    required String description,
    String? client,
    String? budget,
    String? priority,
    String? status,
    DateTime? startDate,
    DateTime? dueDate,
    required List<String> teamMembers,
    required BuildContext context,
  }) {
    context.read<ProjectBloc>().add(CreateProject(
      name: name,
      description: description,
      dueDate: dueDate,
      teamMembers: teamMembers,
    ));
  }

  Future<Map<String, int>> _getProjectProgress(String projectId) async {
    try {
      final tasks = await FirebaseFirestore.instance
          .collection('tasks')
          .where('projectId', isEqualTo: projectId)
          .get();
      
      int total = tasks.docs.length;
      int completed = 0;
      int inProgress = 0;
      int todo = 0;
      
      for (var doc in tasks.docs) {
        final status = doc.data()['status'] ?? 'todo';
        switch (status.toLowerCase()) {
          case 'completed':
          case 'done':
            completed++;
            break;
          case 'in_progress':
          case 'in progress':
          case 'active':
            inProgress++;
            break;
          default:
            todo++;
            break;
        }
      }
      
      return {
        'total': total,
        'completed': completed,
        'inProgress': inProgress,
        'todo': todo,
      };
    } catch (e) {
      print('Error getting project progress: $e');
      return {
        'total': 0,
        'completed': 0,
        'inProgress': 0,
        'todo': 0,
      };
    }
  }

  Widget _buildProgressStat(String label, int value, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              value.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

// Particle Painter for background animation
class ParticlePainter extends CustomPainter {
  final double animationValue;

  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 50; i++) {
      final x = (i * 50 + animationValue * 100) % size.width;
      final y = (i * 30 + animationValue * 50) % size.height;
      canvas.drawCircle(Offset(x, y), 2, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
