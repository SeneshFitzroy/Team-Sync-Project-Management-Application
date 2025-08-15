import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/firebase_service.dart';
import '../models/task.dart';

// Events
abstract class TaskEvent {}

class LoadTasksForProjectEvent extends TaskEvent {
  final String projectId;
  
  LoadTasksForProjectEvent(this.projectId);
}

class LoadMyTasksEvent extends TaskEvent {}

class CreateTaskEvent extends TaskEvent {
  final Task task;
  
  CreateTaskEvent(this.task);
}

class UpdateTaskEvent extends TaskEvent {
  final Task task;
  
  UpdateTaskEvent(this.task);
}

class DeleteTaskEvent extends TaskEvent {
  final String taskId;
  
  DeleteTaskEvent(this.taskId);
}

// States
abstract class TaskState {}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TasksLoaded extends TaskState {
  final List<Task> tasks;
  
  TasksLoaded(this.tasks);
}

class TaskError extends TaskState {
  final String message;
  
  TaskError(this.message);
}

// BLoC
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final FirebaseService _firebaseService;
  
  TaskBloc(this._firebaseService) : super(TaskInitial()) {
    on<LoadTasksForProjectEvent>(_onLoadTasksForProject);
    on<LoadMyTasksEvent>(_onLoadMyTasks);
    on<CreateTaskEvent>(_onCreateTask);
    on<UpdateTaskEvent>(_onUpdateTask);
    on<DeleteTaskEvent>(_onDeleteTask);
  }
  
  Future<void> _onLoadTasksForProject(LoadTasksForProjectEvent event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final tasks = await _firebaseService.getTasksForProject(event.projectId);
      emit(TasksLoaded(tasks));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }
  
  Future<void> _onLoadMyTasks(LoadMyTasksEvent event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final tasks = await _firebaseService.getMyTasks();
      emit(TasksLoaded(tasks));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }
  
  Future<void> _onCreateTask(CreateTaskEvent event, Emitter<TaskState> emit) async {
    try {
      await _firebaseService.createTask(event.task);
      // Reload tasks for the project
      if (state is TasksLoaded) {
        add(LoadTasksForProjectEvent(event.task.projectId));
      }
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }
  
  Future<void> _onUpdateTask(UpdateTaskEvent event, Emitter<TaskState> emit) async {
    try {
      await _firebaseService.updateTask(event.task);
      // Reload tasks for the project
      if (state is TasksLoaded) {
        add(LoadTasksForProjectEvent(event.task.projectId));
      }
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }
  
  Future<void> _onDeleteTask(DeleteTaskEvent event, Emitter<TaskState> emit) async {
    try {
      await _firebaseService.deleteTask(event.taskId);
      // Reload tasks if we're currently showing tasks
      if (state is TasksLoaded) {
        final currentTasks = (state as TasksLoaded).tasks;
        final taskToDelete = currentTasks.firstWhere((task) => task.id == event.taskId);
        add(LoadTasksForProjectEvent(taskToDelete.projectId));
      }
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }
}
