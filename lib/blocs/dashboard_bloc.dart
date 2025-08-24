import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../models/user_model.dart';
import '../models/member_request.dart';

// Dashboard Events
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboardData extends DashboardEvent {}

class RefreshDashboardData extends DashboardEvent {}

class SearchDashboardContent extends DashboardEvent {
  final String query;

  const SearchDashboardContent(this.query);

  @override
  List<Object?> get props => [query];
}

// Dashboard State
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final Map<String, dynamic> stats;
  final List<Project> recentProjects;
  final List<Project> projectsDueToday;
  final List<Task> upcomingTasks;
  final List<Task> overdueTasks;
  final List<Map<String, dynamic>> recentActivities;
  final List<Map<String, dynamic>> projectProgress;
  final List<UserModel> teamMembers;
  final List<MemberRequest> pendingRequests;

  const DashboardLoaded({
    required this.stats,
    required this.recentProjects,
    required this.projectsDueToday,
    required this.upcomingTasks,
    required this.overdueTasks,
    required this.recentActivities,
    required this.projectProgress,
    required this.teamMembers,
    required this.pendingRequests,
  });

  @override
  List<Object?> get props => [
        stats,
        recentProjects,
        projectsDueToday,
        upcomingTasks,
        overdueTasks,
        recentActivities,
        projectProgress,
        teamMembers,
        pendingRequests,
      ];
}

class DashboardSearchResults extends DashboardState {
  final List<Map<String, dynamic>> results;
  final String query;

  const DashboardSearchResults({
    required this.results,
    required this.query,
  });

  @override
  List<Object?> get props => [results, query];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

// Dashboard Bloc
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<RefreshDashboardData>(_onRefreshDashboardData);
    on<SearchDashboardContent>(_onSearchDashboardContent);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    await _loadDashboardData(emit);
  }

  Future<void> _onRefreshDashboardData(
    RefreshDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    await _loadDashboardData(emit);
  }

  Future<void> _onSearchDashboardContent(
    SearchDashboardContent event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      if (event.query.isEmpty) {
        add(LoadDashboardData());
        return;
      }

      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        emit(const DashboardError('User not authenticated'));
        return;
      }

              // Load all data for searching
        List<Project> allProjects = [];
        List<Task> allTasks = [];
        List<Map<String, dynamic>> searchResults = [];

        try {
          // Search projects
          final projectSnapshot = await FirebaseFirestore.instance
              .collection('projects')
              .where('teamMembers', arrayContains: userId)
              .get();
          
          allProjects = projectSnapshot.docs
              .map((doc) => Project.fromMap(doc.data(), doc.id))
              .toList();

          // Search tasks
          final taskSnapshot = await FirebaseFirestore.instance
              .collection('tasks')
              .where('assignedTo', isEqualTo: userId)
              .get();
          
          allTasks = taskSnapshot.docs
              .map((doc) => Task.fromMap(doc.data(), doc.id))
              .toList();

          final query = event.query.toLowerCase();
          
          // Search in projects
          for (var project in allProjects) {
            if (project.name.toLowerCase().contains(query) ||
                project.description.toLowerCase().contains(query)) {
              searchResults.add({
                'type': 'project',
                'title': project.name,
                'subtitle': project.description,
                'data': project,
              });
            }
          }

          // Search in tasks
          for (var task in allTasks) {
            if (task.title.toLowerCase().contains(query) ||
                task.description.toLowerCase().contains(query)) {
              searchResults.add({
                'type': 'task',
                'title': task.title,
                'subtitle': task.description,
                'data': task,
              });
            }
          }

          emit(DashboardSearchResults(results: searchResults, query: event.query));
        } catch (e) {
          print('Search error: $e');
          emit(DashboardSearchResults(results: [], query: event.query));
        }
    } catch (e) {
      emit(DashboardError('Failed to search: ${e.toString()}'));
    }
  }

  Future<void> _loadDashboardData(Emitter<DashboardState> emit) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        emit(const DashboardError('User not authenticated'));
        return;
      }

      // Load data with simple queries to avoid index requirements
      List<Project> recentProjects = [];
      List<Project> projectsDueToday = [];
      List<Project> allProjects = [];
      List<Task> upcomingTasks = [];
      List<Task> overdueTasks = [];
      List<Task> tasksDueToday = [];
      List<Task> allTasks = [];
      List<MemberRequest> pendingRequests = [];
      
      try {
        // Get projects - simple query without ordering
        final projectSnapshot = await FirebaseFirestore.instance
            .collection('projects')
            .where('teamMembers', arrayContains: userId)
            .limit(5)
            .get();
        
        allProjects = projectSnapshot.docs
            .map((doc) => Project.fromMap(doc.data(), doc.id))
            .toList();
        
        // Filter projects - get recent ones and projects due today
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        
        recentProjects = allProjects.take(5).toList();
        
        // Find projects due today
        projectsDueToday = allProjects.where((project) {
          if (project.dueDate == null) return false;
          final projectDate = DateTime(project.dueDate!.year, project.dueDate!.month, project.dueDate!.day);
          return projectDate.isAtSameMomentAs(today);
        }).toList();
        
        print('📅 Projects due today: ${projectsDueToday.length}');
        
      } catch (e) {
        print('Error loading projects: $e');
      }

      try {
        // Get tasks - simple query without ordering
        final taskSnapshot = await FirebaseFirestore.instance
            .collection('tasks')
            .where('assignedTo', isEqualTo: userId)
            .limit(10)
            .get();
        
        allTasks = taskSnapshot.docs
            .map((doc) => Task.fromMap(doc.data(), doc.id))
            .toList();
        
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final tomorrow = today.add(const Duration(days: 1));
        
        upcomingTasks = allTasks.where((task) => 
          task.dueDate.isAfter(tomorrow) && task.status != TaskStatus.completed
        ).toList();
        
        overdueTasks = allTasks.where((task) => 
          task.dueDate.isBefore(today) && task.status != TaskStatus.completed
        ).toList();
        
        tasksDueToday = allTasks.where((task) {
          final taskDate = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
          return taskDate.isAtSameMomentAs(today) && task.status != TaskStatus.completed;
        }).toList();
      } catch (e) {
        print('Error loading tasks: $e');
      }

      try {
        // Get member requests
        final requestSnapshot = await FirebaseFirestore.instance
            .collection('member_requests')
            .where('recipientId', isEqualTo: userId)
            .where('status', isEqualTo: 'pending')
            .limit(5)
            .get();
        
        pendingRequests = requestSnapshot.docs
            .map((doc) => MemberRequest.fromMap(doc.data(), doc.id))
            .toList();
      } catch (e) {
        print('Error loading member requests: $e');
      }

      // Create comprehensive stats
      final completedTasks = allTasks.where((task) => task.status == TaskStatus.completed).length;
      final activeProjects = allProjects.where((project) => project.status == ProjectStatus.active).length;
      final completionRate = allTasks.isNotEmpty 
          ? ((completedTasks / allTasks.length) * 100).round() 
          : 0;
      
      // Calculate unique team members across all projects
      Set<String> uniqueTeamMembers = {};
      for (var project in allProjects) {
        uniqueTeamMembers.addAll(project.teamMembers);
      }
      
      final stats = {
        'totalProjects': allProjects.length,
        'activeProjects': activeProjects,
        'totalTasks': allTasks.length,
        'completedTasks': completedTasks,
        'tasksDueToday': tasksDueToday.length,
        'overdueTasks': overdueTasks.length,
        'overdueItems': overdueTasks.length,
        'completionRate': completionRate,
        'totalTeamMembers': uniqueTeamMembers.length,
      };

      emit(DashboardLoaded(
        stats: stats,
        recentProjects: recentProjects,
        projectsDueToday: projectsDueToday,
        upcomingTasks: upcomingTasks,
        overdueTasks: overdueTasks,
        recentActivities: const [],
        projectProgress: const [],
        teamMembers: const [],
        pendingRequests: pendingRequests,
      ));
    } catch (e) {
      print('Dashboard loading error: $e');
      emit(const DashboardError('Failed to load dashboard data. Please check your connection.'));
    }
  }
}
