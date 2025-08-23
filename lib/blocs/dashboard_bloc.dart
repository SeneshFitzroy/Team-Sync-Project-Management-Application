import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Project.dart';
import '../models/Task.dart';
import '../models/UserModel.dart';
import '../models/MemberRequest.dart';

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
  final List<Task> upcomingTasks;
  final List<Task> overdueTasks;
  final List<Map<String, dynamic>> recentActivities;
  final List<Map<String, dynamic>> projectProgress;
  final List<UserModel> teamMembers;
  final List<MemberRequest> pendingRequests;

  const DashboardLoaded({
    required this.stats,
    required this.recentProjects,
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

      // Simple search implementation
      emit(DashboardSearchResults(results: [], query: event.query));
    } catch (e) {
      emit(DashboardError('Failed to search: ${e.toString()}'));
    }
  }

  Future<void> _loadDashboardData(Emitter<DashboardState> emit) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        emit(DashboardError('User not authenticated'));
        return;
      }

      // Load data with simple queries to avoid index requirements
      List<Project> recentProjects = [];
      List<Task> upcomingTasks = [];
      List<Task> overdueTasks = [];
      List<MemberRequest> pendingRequests = [];
      
      try {
        // Get projects - simple query without ordering
        final projectSnapshot = await FirebaseFirestore.instance
            .collection('projects')
            .where('teamMembers', arrayContains: userId)
            .limit(5)
            .get();
        
        recentProjects = projectSnapshot.docs
            .map((doc) => Project.fromMap(doc.data(), doc.id))
            .toList();
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
        
        final allTasks = taskSnapshot.docs
            .map((doc) => Task.fromMap(doc.data(), doc.id))
            .toList();
        
        final now = DateTime.now();
        upcomingTasks = allTasks.where((task) => 
          task.dueDate.isAfter(now) && task.status != TaskStatus.completed
        ).toList();
        
        overdueTasks = allTasks.where((task) => 
          task.dueDate.isBefore(now) && task.status != TaskStatus.completed
        ).toList();
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

      // Create simple stats
      final stats = {
        'totalProjects': recentProjects.length,
        'totalTasks': upcomingTasks.length + overdueTasks.length,
        'completedTasks': 0,
        'overdueItems': overdueTasks.length,
      };

      emit(DashboardLoaded(
        stats: stats,
        recentProjects: recentProjects,
        upcomingTasks: upcomingTasks,
        overdueTasks: overdueTasks,
        recentActivities: [],
        projectProgress: [],
        teamMembers: [],
        pendingRequests: pendingRequests,
      ));
    } catch (e) {
      print('Dashboard loading error: $e');
      emit(DashboardError('Failed to load dashboard data. Please check your connection.'));
    }
  }
}
