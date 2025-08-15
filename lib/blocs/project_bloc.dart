import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/firebase_service.dart';
import '../models/project.dart';

// Events
abstract class ProjectEvent {}

class LoadProjectsEvent extends ProjectEvent {}

class CreateProjectEvent extends ProjectEvent {
  final String name;
  final DateTime startDate;
  final List<String> teamMembers;
  
  CreateProjectEvent(this.name, this.startDate, this.teamMembers);
}

class DeleteProjectEvent extends ProjectEvent {
  final String projectId;
  
  DeleteProjectEvent(this.projectId);
}

// States
abstract class ProjectState {}

class ProjectInitial extends ProjectState {}

class ProjectLoading extends ProjectState {}

class ProjectsLoaded extends ProjectState {
  final List<Project> projects;
  
  ProjectsLoaded(this.projects);
}

class ProjectError extends ProjectState {
  final String message;
  
  ProjectError(this.message);
}

// BLoC
class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final FirebaseService _firebaseService;
  
  ProjectBloc(this._firebaseService) : super(ProjectInitial()) {
    on<LoadProjectsEvent>(_onLoadProjects);
    on<CreateProjectEvent>(_onCreateProject);
    on<DeleteProjectEvent>(_onDeleteProject);
  }
  
  Future<void> _onLoadProjects(LoadProjectsEvent event, Emitter<ProjectState> emit) async {
    emit(ProjectLoading());
    try {
      final projects = await _firebaseService.getProjects();
      emit(ProjectsLoaded(projects));
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }
  
  Future<void> _onCreateProject(CreateProjectEvent event, Emitter<ProjectState> emit) async {
    try {
      await _firebaseService.createProject(event.name, event.startDate, event.teamMembers);
      add(LoadProjectsEvent()); // Reload projects
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }
  
  Future<void> _onDeleteProject(DeleteProjectEvent event, Emitter<ProjectState> emit) async {
    try {
      await _firebaseService.deleteProject(event.projectId);
      add(LoadProjectsEvent()); // Reload projects
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }
}
