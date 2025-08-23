import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/project.dart';
import '../models/user_model.dart';
import '../Services/firebase_service.dart';

// Project Events
abstract class ProjectEvent extends Equatable {
  const ProjectEvent();

  @override
  List<Object?> get props => [];
}

class LoadProjects extends ProjectEvent {}

class CreateProject extends ProjectEvent {
  final String name;
  final String description;
  final DateTime? dueDate;
  final String? color;

  const CreateProject({
    required this.name,
    required this.description,
    this.dueDate,
    this.color,
  });

  @override
  List<Object?> get props => [name, description, dueDate, color];
}

class UpdateProject extends ProjectEvent {
  final Project project;

  const UpdateProject(this.project);

  @override
  List<Object?> get props => [project];
}

class DeleteProject extends ProjectEvent {
  final String projectId;

  const DeleteProject(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class InviteUserToProject extends ProjectEvent {
  final String projectId;
  final String userId;
  final String message;

  const InviteUserToProject({
    required this.projectId,
    required this.userId,
    required this.message,
  });

  @override
  List<Object?> get props => [projectId, userId, message];
}

class RemoveMemberFromProject extends ProjectEvent {
  final String projectId;
  final String userId;

  const RemoveMemberFromProject({
    required this.projectId,
    required this.userId,
  });

  @override
  List<Object?> get props => [projectId, userId];
}

class SearchUsers extends ProjectEvent {
  final String query;

  const SearchUsers(this.query);

  @override
  List<Object?> get props => [query];
}

// Project State
abstract class ProjectState extends Equatable {
  const ProjectState();

  @override
  List<Object?> get props => [];
}

class ProjectInitial extends ProjectState {}

class ProjectLoading extends ProjectState {}

class ProjectsLoaded extends ProjectState {
  final List<Project> projects;

  const ProjectsLoaded(this.projects);

  @override
  List<Object?> get props => [projects];
}

class ProjectOperationSuccess extends ProjectState {
  final String message;

  const ProjectOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class UserSearchResults extends ProjectState {
  final List<UserModel> users;
  final String query;

  const UserSearchResults({
    required this.users,
    required this.query,
  });

  @override
  List<Object?> get props => [users, query];
}

class ProjectError extends ProjectState {
  final String message;

  const ProjectError(this.message);

  @override
  List<Object?> get props => [message];
}

// Project Bloc
class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  ProjectBloc() : super(ProjectInitial()) {
    on<LoadProjects>(_onLoadProjects);
    on<CreateProject>(_onCreateProject);
    on<UpdateProject>(_onUpdateProject);
    on<DeleteProject>(_onDeleteProject);
    on<InviteUserToProject>(_onInviteUserToProject);
    on<RemoveMemberFromProject>(_onRemoveMemberFromProject);
    on<SearchUsers>(_onSearchUsers);
  }

  Future<void> _onLoadProjects(
    LoadProjects event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectLoading());
    try {
      final projectsStream = FirebaseService.getUserProjectsStream();
      await emit.forEach<List<Project>>(
        projectsStream,
        onData: (projects) => ProjectsLoaded(projects),
        onError: (error, stackTrace) => ProjectError('Failed to load projects: ${error.toString()}'),
      );
    } catch (e) {
      emit(ProjectError('Failed to load projects: ${e.toString()}'));
    }
  }

  Future<void> _onCreateProject(
    CreateProject event,
    Emitter<ProjectState> emit,
  ) async {
    try {
      final userId = FirebaseService.currentUserId;
      if (userId == null) {
        emit(const ProjectError('User not authenticated'));
        return;
      }

      final project = Project(
        name: event.name,
        description: event.description,
        ownerId: userId,
        teamMembers: [userId], // Add creator as first member
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        dueDate: event.dueDate,
        color: event.color,
        progress: 0.0,
      );

      await FirebaseService.createProject(project);
      emit(const ProjectOperationSuccess('Project created successfully'));
      add(LoadProjects()); // Reload projects
    } catch (e) {
      emit(ProjectError('Failed to create project: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateProject(
    UpdateProject event,
    Emitter<ProjectState> emit,
  ) async {
    try {
      final updatedProject = event.project.copyWith(
        updatedAt: DateTime.now(),
      );
      
      await FirebaseService.updateProject(updatedProject);
      emit(const ProjectOperationSuccess('Project updated successfully'));
      add(LoadProjects()); // Reload projects
    } catch (e) {
      emit(ProjectError('Failed to update project: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteProject(
    DeleteProject event,
    Emitter<ProjectState> emit,
  ) async {
    try {
      await FirebaseService.deleteProject(event.projectId);
      emit(const ProjectOperationSuccess('Project deleted successfully'));
      add(LoadProjects()); // Reload projects
    } catch (e) {
      emit(ProjectError('Failed to delete project: ${e.toString()}'));
    }
  }

  Future<void> _onInviteUserToProject(
    InviteUserToProject event,
    Emitter<ProjectState> emit,
  ) async {
    try {
      await FirebaseService.sendProjectInvitation(
        event.projectId,
        event.userId,
        event.message,
      );
      emit(const ProjectOperationSuccess('Invitation sent successfully'));
    } catch (e) {
      emit(ProjectError('Failed to send invitation: ${e.toString()}'));
    }
  }

  Future<void> _onRemoveMemberFromProject(
    RemoveMemberFromProject event,
    Emitter<ProjectState> emit,
  ) async {
    try {
      await FirebaseService.removeMemberFromProject(
        event.projectId,
        event.userId,
      );
      emit(const ProjectOperationSuccess('Member removed successfully'));
      add(LoadProjects()); // Reload projects
    } catch (e) {
      emit(ProjectError('Failed to remove member: ${e.toString()}'));
    }
  }

  Future<void> _onSearchUsers(
    SearchUsers event,
    Emitter<ProjectState> emit,
  ) async {
    try {
      if (event.query.isEmpty) {
        emit(const UserSearchResults(users: [], query: ''));
        return;
      }

      final users = await FirebaseService.searchUsers(event.query);
      emit(UserSearchResults(users: users, query: event.query));
    } catch (e) {
      emit(ProjectError('Failed to search users: ${e.toString()}'));
    }
  }
}
