import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'dart:math';
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
import 'package:fl_chart/fl_chart.dart';

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
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          height: MediaQuery.of(context).size.height * 0.85,
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryBlue, AppTheme.primaryBlue.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.analytics, color: Colors.white, size: 24),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.name,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Project Analytics Dashboard',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: _getProjectAnalytics(project.id ?? ''),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          height: 400,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: AppTheme.primaryBlue),
                                SizedBox(height: 16),
                                Text('Loading analytics...'),
                              ],
                            ),
                          ),
                        );
                      }
                      
                      if (!snapshot.hasData) {
                        return _buildEmptyAnalytics();
                      }
                      
                      final analytics = snapshot.data!;
                      return _buildAnalyticsContent(project, analytics);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
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

  Color _getStatusColorFromString(dynamic status) {
    if (status == null) return Colors.grey;
    
    final statusStr = status.toString().toLowerCase();
    if (statusStr.contains('completed') || statusStr.contains('done')) {
      return Colors.green;
    } else if (statusStr.contains('progress') || statusStr.contains('active')) {
      return Colors.orange;
    } else if (statusStr.contains('planning')) {
      return Colors.blue;
    }
    return Colors.grey;
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

  Future<Map<String, dynamic>> _getProjectAnalytics(String projectId) async {
    try {
      // Get tasks data
      final tasksSnapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('projectId', isEqualTo: projectId)
          .get();
      
      // Get team members data
      final projectSnapshot = await FirebaseFirestore.instance
          .collection('projects')
          .doc(projectId)
          .get();
      
      final projectData = projectSnapshot.data();
      final teamMemberIds = List<String>.from(projectData?['teamMembers'] ?? []);
      
      // Get team member details
      List<Map<String, dynamic>> teamMembers = [];
      for (String memberId in teamMemberIds) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(memberId)
            .get();
        if (userDoc.exists) {
          teamMembers.add({
            'id': memberId,
            'name': userDoc.data()?['fullName'] ?? 'Unknown',
            'email': userDoc.data()?['email'] ?? '',
          });
        }
      }
      
      // Process task data
      Map<String, int> taskStatus = {'todo': 0, 'inProgress': 0, 'completed': 0};
      Map<String, int> memberTasks = {};
      Map<String, List<DateTime>> taskTimeline = {};
      List<Map<String, dynamic>> recentActivity = [];
      
      for (var doc in tasksSnapshot.docs) {
        final taskData = doc.data();
        final status = taskData['status']?.toString().toLowerCase() ?? 'todo';
        final assignedTo = taskData['assignedTo']?.toString() ?? '';
        final createdAt = (taskData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        
        // Count task statuses
        if (status.contains('completed') || status.contains('done')) {
          taskStatus['completed'] = (taskStatus['completed'] ?? 0) + 1;
        } else if (status.contains('progress') || status.contains('active')) {
          taskStatus['inProgress'] = (taskStatus['inProgress'] ?? 0) + 1;
        } else {
          taskStatus['todo'] = (taskStatus['todo'] ?? 0) + 1;
        }
        
        // Count tasks per member
        if (assignedTo.isNotEmpty) {
          memberTasks[assignedTo] = (memberTasks[assignedTo] ?? 0) + 1;
        }
        
        // Timeline data
        final dateKey = '${createdAt.day}/${createdAt.month}';
        if (!taskTimeline.containsKey(dateKey)) {
          taskTimeline[dateKey] = [];
        }
        taskTimeline[dateKey]!.add(createdAt);
        
        // Recent activity
        recentActivity.add({
          'title': taskData['title'] ?? 'Untitled Task',
          'status': status,
          'date': createdAt,
          'assignedTo': assignedTo,
        });
      }
      
      // Sort recent activity
      recentActivity.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
      
      return {
        'taskStatus': taskStatus,
        'memberTasks': memberTasks,
        'teamMembers': teamMembers,
        'taskTimeline': taskTimeline,
        'recentActivity': recentActivity.take(5).toList(),
        'totalTasks': tasksSnapshot.docs.length,
        'projectData': projectData,
      };
    } catch (e) {
      print('Error getting project analytics: $e');
      return {};
    }
  }

  Widget _buildEmptyAnalytics() {
    return Container(
      padding: EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.bar_chart,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No Analytics Available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Create tasks and assign team members to see project analytics',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsContent(Project project, Map<String, dynamic> analytics) {
    final taskStatus = analytics['taskStatus'] as Map<String, int>;
    final memberTasks = analytics['memberTasks'] as Map<String, int>;
    final teamMembers = analytics['teamMembers'] as List<Map<String, dynamic>>;
    final recentActivity = analytics['recentActivity'] as List<Map<String, dynamic>>;
    final totalTasks = analytics['totalTasks'] as int;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Project Overview Cards
        _buildOverviewCards(project, analytics),
        
        SizedBox(height: 24),
        
        // Charts Section
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Distribution Pie Chart
            Expanded(
              flex: 1,
              child: _buildTaskDistributionChart(taskStatus, totalTasks),
            ),
            SizedBox(width: 16),
            // Team Performance Bar Chart
            Expanded(
              flex: 1,
              child: _buildTeamPerformanceChart(memberTasks, teamMembers),
            ),
          ],
        ),
        
        SizedBox(height: 24),
        
        // Progress Timeline
        _buildProgressTimeline(analytics['taskTimeline'] as Map<String, List<DateTime>>),
        
        SizedBox(height: 24),
        
        // Recent Activity & Team Members
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildRecentActivity(recentActivity),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildTeamMembersSection(teamMembers),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverviewCards(Project project, Map<String, dynamic> analytics) {
    final totalTasks = analytics['totalTasks'] as int;
    final taskStatus = analytics['taskStatus'] as Map<String, int>;
    final completed = taskStatus['completed'] ?? 0;
    final teamMembers = analytics['teamMembers'] as List<Map<String, dynamic>>;
    
    final completionRate = totalTasks > 0 ? (completed / totalTasks * 100) : 0.0;
    
    return Row(
      children: [
        Expanded(
          child: _buildOverviewCard(
            'Total Tasks',
            totalTasks.toString(),
            Icons.assignment,
            Colors.blue,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildOverviewCard(
            'Completion',
            '${completionRate.toStringAsFixed(1)}%',
            Icons.check_circle,
            Colors.green,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildOverviewCard(
            'Team Size',
            teamMembers.length.toString(),
            Icons.people,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskDistributionChart(Map<String, int> taskStatus, int totalTasks) {
    if (totalTasks == 0) {
      return Container(
        height: 250,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pie_chart, size: 48, color: Colors.grey[400]),
              SizedBox(height: 8),
              Text('No tasks to display', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 250,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Task Distribution',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: (taskStatus['completed'] ?? 0).toDouble(),
                    color: Colors.green,
                    title: '${taskStatus['completed'] ?? 0}',
                    titleStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    radius: 50,
                  ),
                  PieChartSectionData(
                    value: (taskStatus['inProgress'] ?? 0).toDouble(),
                    color: Colors.orange,
                    title: '${taskStatus['inProgress'] ?? 0}',
                    titleStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    radius: 50,
                  ),
                  PieChartSectionData(
                    value: (taskStatus['todo'] ?? 0).toDouble(),
                    color: Colors.blue,
                    title: '${taskStatus['todo'] ?? 0}',
                    titleStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    radius: 50,
                  ),
                ],
                centerSpaceRadius: 30,
                sectionsSpace: 2,
              ),
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem('Completed', Colors.green),
              _buildLegendItem('In Progress', Colors.orange),
              _buildLegendItem('To Do', Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamPerformanceChart(Map<String, int> memberTasks, List<Map<String, dynamic>> teamMembers) {
    if (memberTasks.isEmpty) {
      return Container(
        height: 250,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart, size: 48, color: Colors.grey[400]),
              SizedBox(height: 8),
              Text('No task assignments', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      );
    }

    final maxTasks = memberTasks.values.isNotEmpty ? memberTasks.values.reduce(max) : 1;
    
    return Container(
      height: 250,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Team Performance',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxTasks.toDouble() + 1,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final memberIndex = value.toInt();
                        if (memberIndex >= 0 && memberIndex < teamMembers.length) {
                          final name = teamMembers[memberIndex]['name'] as String;
                          return Text(
                            name.length > 8 ? '${name.substring(0, 8)}...' : name,
                            style: TextStyle(fontSize: 10),
                          );
                        }
                        return Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(value.toInt().toString(), style: TextStyle(fontSize: 10));
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: teamMembers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final member = entry.value;
                  final memberId = member['id'] as String;
                  final taskCount = memberTasks[memberId] ?? 0;
                  
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: taskCount.toDouble(),
                        color: AppTheme.primaryBlue,
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTimeline(Map<String, List<DateTime>> taskTimeline) {
    if (taskTimeline.isEmpty) {
      return Container(
        height: 200,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timeline, size: 48, color: Colors.grey[400]),
              SizedBox(height: 8),
              Text('No timeline data', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      );
    }

    final sortedDates = taskTimeline.keys.toList()..sort();
    
    return Container(
      height: 200,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Task Creation Timeline',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < sortedDates.length) {
                          return Text(sortedDates[index], style: TextStyle(fontSize: 10));
                        }
                        return Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(value.toInt().toString(), style: TextStyle(fontSize: 10));
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: sortedDates.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), taskTimeline[entry.value]!.length.toDouble());
                    }).toList(),
                    isCurved: true,
                    color: AppTheme.primaryBlue,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(List<Map<String, dynamic>> recentActivity) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),
          if (recentActivity.isEmpty)
            Container(
              height: 100,
              child: Center(
                child: Text('No recent activity', style: TextStyle(color: Colors.grey[600])),
              ),
            )
          else
            ...recentActivity.map((activity) {
              final status = activity['status'] as String;
              final date = activity['date'] as DateTime;
              final title = activity['title'] as String;
              
              return Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getStatusColorFromString(status),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${date.day}/${date.month}/${date.year}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildTeamMembersSection(List<Map<String, dynamic>> teamMembers) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Team Members',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),
          if (teamMembers.isEmpty)
            Container(
              height: 100,
              child: Center(
                child: Text('No team members', style: TextStyle(color: Colors.grey[600])),
              ),
            )
          else
            ...teamMembers.map((member) {
              final name = member['name'] as String;
              final email = member['email'] as String;
              
              return Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppTheme.primaryBlue,
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'U',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          if (email.isNotEmpty)
                            Text(
                              email,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
      ],
    );
  }
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
