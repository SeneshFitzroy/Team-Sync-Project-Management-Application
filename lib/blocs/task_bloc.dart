import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/task.dart';
import '../Services/firebase_service.dart';

// Task Events
abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskEvent {}

class LoadTasksForProject extends TaskEvent {
  final String projectId;

  const LoadTasksForProject(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class CreateTask extends TaskEvent {
  final String title;
  final String description;
  final TaskPriority priority;
  final DateTime dueDate;
  final String? assignedTo;
  final String? projectId;
  final List<String> tags;
  final String? color;

  const CreateTask({
    required this.title,
    required this.description,
    required this.priority,
    required this.dueDate,
    this.assignedTo,
    this.projectId,
    this.tags = const [],
    this.color,
  });

  @override
  List<Object?> get props => [
        title,
        description,
        priority,
        dueDate,
        assignedTo,
        projectId,
        tags,
        color,
      ];
}

class UpdateTask extends TaskEvent {
  final Task task;

  const UpdateTask(this.task);

  @override
  List<Object?> get props => [task];
}

class UpdateTaskStatus extends TaskEvent {
  final String taskId;
  final TaskStatus status;

  const UpdateTaskStatus({
    required this.taskId,
    required this.status,
  });

  @override
  List<Object?> get props => [taskId, status];
}

class DeleteTask extends TaskEvent {
  final String taskId;

  const DeleteTask(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class AssignTask extends TaskEvent {
  final String taskId;
  final String userId;

  const AssignTask({
    required this.taskId,
    required this.userId,
  });

  @override
  List<Object?> get props => [taskId, userId];
}

class FilterTasks extends TaskEvent {
  final TaskStatus? status;
  final TaskPriority? priority;
  final String? projectId;
  final String? assignedTo;

  const FilterTasks({
    this.status,
    this.priority,
    this.projectId,
    this.assignedTo,
  });

  @override
  List<Object?> get props => [status, priority, projectId, assignedTo];
}

class SearchTasks extends TaskEvent {
  final String query;

  const SearchTasks(this.query);

  @override
  List<Object?> get props => [query];
}

// Task State
abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TasksLoaded extends TaskState {
  final List<Task> tasks;
  final List<Task> filteredTasks;
  final Map<String, int> taskCounts;

  const TasksLoaded({
    required this.tasks,
    required this.filteredTasks,
    required this.taskCounts,
  });

  @override
  List<Object?> get props => [tasks, filteredTasks, taskCounts];
}

class TaskOperationSuccess extends TaskState {
  final String message;

  const TaskOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class TaskSearchResults extends TaskState {
  final List<Task> results;
  final String query;

  const TaskSearchResults({
    required this.results,
    required this.query,
  });

  @override
  List<Object?> get props => [results, query];
}

class TaskError extends TaskState {
  final String message;

  const TaskError(this.message);

  @override
  List<Object?> get props => [message];
}

// Task Bloc
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  List<Task> _allTasks = [];
  TaskStatus? _statusFilter;
  TaskPriority? _priorityFilter;
  String? _projectFilter;
  String? _assignedToFilter;

  TaskBloc() : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<LoadTasksForProject>(_onLoadTasksForProject);
    on<CreateTask>(_onCreateTask);
    on<UpdateTask>(_onUpdateTask);
    on<UpdateTaskStatus>(_onUpdateTaskStatus);
    on<DeleteTask>(_onDeleteTask);
    on<AssignTask>(_onAssignTask);
    on<FilterTasks>(_onFilterTasks);
    on<SearchTasks>(_onSearchTasks);
  }

  Future<void> _onLoadTasks(
    LoadTasks event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskLoading());
    try {
      final userId = FirebaseService.currentUserId;
      if (userId == null) {
        emit(const TaskError('User not authenticated'));
        return;
      }

      // Use just the assigned tasks stream to avoid the async complexity
      await emit.forEach<List<Task>>(
        FirebaseService.getUserTasksStream(),
        onData: (tasks) {
          _allTasks = tasks;
          _allTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return _buildTasksLoadedState();
        },
        onError: (error, stackTrace) => TaskError('Failed to load tasks: ${error.toString()}'),
      );
    } catch (e) {
      emit(TaskError('Failed to load tasks: ${e.toString()}'));
    }
  }

  Future<void> _onLoadTasksForProject(
    LoadTasksForProject event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskLoading());
    try {
      final tasksStream = FirebaseService.getProjectTasksStream(event.projectId);
      await emit.forEach<List<Task>>(
        tasksStream,
        onData: (tasks) {
          _allTasks = tasks;
          _allTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return _buildTasksLoadedState();
        },
        onError: (error, stackTrace) => TaskError('Failed to load project tasks: ${error.toString()}'),
      );
    } catch (e) {
      emit(TaskError('Failed to load project tasks: ${e.toString()}'));
    }
  }

  Future<void> _onCreateTask(
    CreateTask event,
    Emitter<TaskState> emit,
  ) async {
    try {
      final userId = FirebaseService.currentUserId;
      if (userId == null) {
        emit(const TaskError('User not authenticated'));
        return;
      }

      final task = Task(
        title: event.title,
        description: event.description,
        priority: event.priority,
        dueDate: event.dueDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        assignedTo: event.assignedTo,
        projectId: event.projectId,
        createdBy: userId,
        tags: event.tags,
        color: event.color,
      );

      await FirebaseService.createTask(task);
      emit(const TaskOperationSuccess('Task created successfully'));
      add(LoadTasks()); // Reload tasks
    } catch (e) {
      emit(TaskError('Failed to create task: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateTask(
    UpdateTask event,
    Emitter<TaskState> emit,
  ) async {
    try {
      final updatedTask = event.task.copyWith(
        updatedAt: DateTime.now(),
      );

      await FirebaseService.updateTask(updatedTask);
      emit(const TaskOperationSuccess('Task updated successfully'));
      add(LoadTasks()); // Reload tasks
    } catch (e) {
      emit(TaskError('Failed to update task: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateTaskStatus(
    UpdateTaskStatus event,
    Emitter<TaskState> emit,
  ) async {
    try {
      final task = _allTasks.firstWhere((t) => t.id == event.taskId);
      final updatedTask = task.copyWith(
        status: event.status,
        updatedAt: DateTime.now(),
        completedAt: event.status == TaskStatus.completed ? DateTime.now() : null,
      );

      await FirebaseService.updateTask(updatedTask);
      emit(const TaskOperationSuccess('Task status updated'));
      add(LoadTasks()); // Reload tasks
    } catch (e) {
      emit(TaskError('Failed to update task status: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteTask(
    DeleteTask event,
    Emitter<TaskState> emit,
  ) async {
    try {
      await FirebaseService.deleteTask(event.taskId);
      emit(const TaskOperationSuccess('Task deleted successfully'));
      add(LoadTasks()); // Reload tasks
    } catch (e) {
      emit(TaskError('Failed to delete task: ${e.toString()}'));
    }
  }

  Future<void> _onAssignTask(
    AssignTask event,
    Emitter<TaskState> emit,
  ) async {
    try {
      final task = _allTasks.firstWhere((t) => t.id == event.taskId);
      final updatedTask = task.copyWith(
        assignedTo: event.userId,
        updatedAt: DateTime.now(),
      );

      await FirebaseService.updateTask(updatedTask);
      emit(const TaskOperationSuccess('Task assigned successfully'));
      add(LoadTasks()); // Reload tasks
    } catch (e) {
      emit(TaskError('Failed to assign task: ${e.toString()}'));
    }
  }

  Future<void> _onFilterTasks(
    FilterTasks event,
    Emitter<TaskState> emit,
  ) async {
    _statusFilter = event.status;
    _priorityFilter = event.priority;
    _projectFilter = event.projectId;
    _assignedToFilter = event.assignedTo;

    emit(_buildTasksLoadedState());
  }

  Future<void> _onSearchTasks(
    SearchTasks event,
    Emitter<TaskState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(_buildTasksLoadedState());
      return;
    }

    final filteredTasks = _allTasks.where((task) {
      return task.title.toLowerCase().contains(event.query.toLowerCase()) ||
          task.description.toLowerCase().contains(event.query.toLowerCase()) ||
          task.tags.any((tag) => tag.toLowerCase().contains(event.query.toLowerCase()));
    }).toList();

    emit(TaskSearchResults(results: filteredTasks, query: event.query));
  }

  TasksLoaded _buildTasksLoadedState() {
    var filteredTasks = _allTasks;

    // Apply filters
    if (_statusFilter != null) {
      filteredTasks = filteredTasks.where((task) => task.status == _statusFilter).toList();
    }
    if (_priorityFilter != null) {
      filteredTasks = filteredTasks.where((task) => task.priority == _priorityFilter).toList();
    }
    if (_projectFilter != null) {
      filteredTasks = filteredTasks.where((task) => task.projectId == _projectFilter).toList();
    }
    if (_assignedToFilter != null) {
      filteredTasks = filteredTasks.where((task) => task.assignedTo == _assignedToFilter).toList();
    }

    // Calculate task counts
    final taskCounts = {
      'total': _allTasks.length,
      'todo': _allTasks.where((t) => t.status == TaskStatus.todo).length,
      'inProgress': _allTasks.where((t) => t.status == TaskStatus.inProgress).length,
      'review': _allTasks.where((t) => t.status == TaskStatus.review).length,
      'completed': _allTasks.where((t) => t.status == TaskStatus.completed).length,
      'overdue': _allTasks.where((t) => t.isOverdue).length,
    };

    return TasksLoaded(
      tasks: _allTasks,
      filteredTasks: filteredTasks,
      taskCounts: taskCounts,
    );
  }
}
