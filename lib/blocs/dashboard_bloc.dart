import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../models/user_model.dart';
import '../models/member_request.dart';
import '../Services/firebase_service.dart';
import '../Services/dashboard_service.dart';

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

      final results = await DashboardService.searchContent(event.query);
      emit(DashboardSearchResults(results: results, query: event.query));
    } catch (e) {
      emit(DashboardError('Failed to search: ${e.toString()}'));
    }
  }

  Future<void> _loadDashboardData(Emitter<DashboardState> emit) async {
    try {
      // Load all dashboard data concurrently
      final futures = await Future.wait([
        DashboardService.getDashboardStats(),
        DashboardService.getRecentActivities(),
        DashboardService.getUpcomingDeadlines(),
        DashboardService.getProjectProgress(),
        DashboardService.getTeamMembers(),
        _getRecentProjects(),
        _getOverdueTasks(),
        _getPendingRequests(),
      ]);

      final stats = futures[0] as Map<String, dynamic>;
      final recentActivities = futures[1] as List<Map<String, dynamic>>;
      final upcomingTasks = futures[2] as List<Task>;
      final projectProgress = futures[3] as List<Map<String, dynamic>>;
      final teamMembers = futures[4] as List<UserModel>;
      final recentProjects = futures[5] as List<Project>;
      final overdueTasks = futures[6] as List<Task>;
      final pendingRequests = futures[7] as List<MemberRequest>;

      emit(DashboardLoaded(
        stats: stats,
        recentProjects: recentProjects,
        upcomingTasks: upcomingTasks,
        overdueTasks: overdueTasks,
        recentActivities: recentActivities,
        projectProgress: projectProgress,
        teamMembers: teamMembers,
        pendingRequests: pendingRequests,
      ));
    } catch (e) {
      emit(DashboardError('Failed to load dashboard data: ${e.toString()}'));
    }
  }

  Future<List<Project>> _getRecentProjects() async {
    final userId = FirebaseService.currentUserId;
    if (userId == null) return [];

    // Get user's projects stream and take the first result
    final projectsStream = FirebaseService.getUserProjectsStream();
    final projects = await projectsStream.first;
    
    // Sort by creation date and take the 5 most recent
    projects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return projects.take(5).toList();
  }

  Future<List<Task>> _getOverdueTasks() async {
    final userId = FirebaseService.currentUserId;
    if (userId == null) return [];

    final tasksStream = FirebaseService.getUserTasksStream();
    final tasks = await tasksStream.first;
    
    return tasks.where((task) => task.isOverdue).toList();
  }

  Future<List<MemberRequest>> _getPendingRequests() async {
    final requestsStream = FirebaseService.getPendingRequestsStream();
    return await requestsStream.first;
  }
}
