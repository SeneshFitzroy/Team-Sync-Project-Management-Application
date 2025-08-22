import 'package:flutter/material.dart';
import '../widgets/TickLogo.dart';
import './Profile.dart';
import './add_task_screen.dart';
import './task_management_screen.dart';
import '../Services/task_service.dart';
import '../Services/project_service.dart';
import '../models/project.dart';
import '../theme/app_theme.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Map<String, int> taskStats = {
    'total': 0,
    'completed': 0,
    'in_progress': 0,
    'pending': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadTaskStatistics();
  }

  Future<void> _loadTaskStatistics() async {
    try {
      final stats = await TaskService.getTaskStatistics();
      setState(() {
        taskStats = stats;
      });
    } catch (e) {
      // Handle error - show default values
      print('Error loading task statistics: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and profile (consistent pattern like Calendar)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Dashboard',
                      style: TextStyle(
                        color: AppTheme.primaryBlue,
                        fontSize: 22,
                        fontFamily: AppTheme.fontFamily,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications, color: AppTheme.primaryBlue),
                          onPressed: () {
                            // Add notification functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Notifications feature coming soon!')),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ProfileScreen()),
                            );
                          },
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey[200],
                            child: Icon(Icons.person, color: Colors.grey[700]),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Welcome section with tick logo
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2D62ED), Color(0xFF4C7FFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const TickLogo(size: 32),
                          const SizedBox(width: 12),
                          Text(
                            'TaskSync',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Welcome back!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Stay organized and boost your productivity',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Stats cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Tasks',
                        '${taskStats['total']}',
                        Icons.task_alt,
                        const Color(0xFF4CAF50),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Completed',
                        '${taskStats['completed']}',
                        Icons.check_circle,
                        const Color(0xFF2196F3),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'In Progress',
                        '${taskStats['in_progress']}',
                        Icons.schedule,
                        const Color(0xFFFF9800),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Pending',
                        '${taskStats['pending']}',
                        Icons.pending,
                        const Color(0xFFF44336),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Recent Projects section
                Text(
                  'Recent Projects',
                  style: TextStyle(
                    color: AppTheme.primaryBlue,
                    fontSize: 18,
                    fontFamily: AppTheme.fontFamily,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Project cards from Firebase
                StreamBuilder<List<Project>>(
                  stream: ProjectService.getRecentProjects(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading projects',
                          style: TextStyle(
                            color: Colors.red,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      );
                    }
                    
                    final projects = snapshot.data ?? [];
                    
                    if (projects.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.folder_open, color: Colors.grey[400], size: 48),
                            const SizedBox(height: 8),
                            Text(
                              'No projects yet',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Create your first project to get started!',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontFamily: 'Poppins',
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return Column(
                      children: projects.map((project) {
                        Color statusColor;
                        switch (project.status.toLowerCase()) {
                          case 'completed':
                            statusColor = const Color(0xFF4CAF50);
                            break;
                          case 'in_progress':
                            statusColor = const Color(0xFFFF9800);
                            break;
                          case 'on_hold':
                            statusColor = const Color(0xFFF44336);
                            break;
                          default:
                            statusColor = const Color(0xFF2D62ED);
                        }
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildProjectCard(
                            project.name,
                            project.description,
                            project.progress,
                            statusColor,
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Quick Actions
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    color: AppTheme.primaryBlue,
                    fontSize: 18,
                    fontFamily: AppTheme.fontFamily,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionCard(
                        'Create Task',
                        Icons.add_task,
                        const Color(0xFF2D62ED),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const add_task_screenScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickActionCard(
                        'View Tasks',
                        Icons.list_alt,
                        const Color(0xFF4CAF50),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const task_management_screenScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const add_task_screenScreen()),
          );
        },
        backgroundColor: const Color(0xFF2D62ED),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: TextStyle(
                  color: AppTheme.primaryBlue,
                  fontSize: 20,
                  fontFamily: AppTheme.fontFamily,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(String title, String subtitle, double progress, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
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
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppTheme.primaryBlue,
                        fontSize: 14,
                        fontFamily: AppTheme.fontFamily,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}