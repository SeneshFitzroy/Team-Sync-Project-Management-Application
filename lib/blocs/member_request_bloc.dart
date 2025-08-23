import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/member_request.dart';
import '../models/user_model.dart';
import '../models/project.dart';
import '../Services/firebase_service.dart';

// Member Request Events
abstract class MemberRequestEvent extends Equatable {
  const MemberRequestEvent();

  @override
  List<Object?> get props => [];
}

class LoadPendingRequests extends MemberRequestEvent {}

class LoadSentRequests extends MemberRequestEvent {}

class AcceptRequest extends MemberRequestEvent {
  final String requestId;

  const AcceptRequest(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

class DeclineRequest extends MemberRequestEvent {
  final String requestId;

  const DeclineRequest(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

class SendProjectInvitation extends MemberRequestEvent {
  final String projectId;
  final String userId;
  final String message;

  const SendProjectInvitation({
    required this.projectId,
    required this.userId,
    required this.message,
  });

  @override
  List<Object?> get props => [projectId, userId, message];
}

// Member Request State
abstract class MemberRequestState extends Equatable {
  const MemberRequestState();

  @override
  List<Object?> get props => [];
}

class MemberRequestInitial extends MemberRequestState {}

class MemberRequestLoading extends MemberRequestState {}

class RequestsLoaded extends MemberRequestState {
  final List<MemberRequestWithDetails> pendingRequests;
  final List<MemberRequestWithDetails> sentRequests;

  const RequestsLoaded({
    required this.pendingRequests,
    required this.sentRequests,
  });

  @override
  List<Object?> get props => [pendingRequests, sentRequests];
}

class MemberRequestOperationSuccess extends MemberRequestState {
  final String message;

  const MemberRequestOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class MemberRequestError extends MemberRequestState {
  final String message;

  const MemberRequestError(this.message);

  @override
  List<Object?> get props => [message];
}

// Helper class to include user and project details with requests
class MemberRequestWithDetails {
  final MemberRequest request;
  final UserModel? fromUser;
  final UserModel? toUser;
  final Project? project;

  MemberRequestWithDetails({
    required this.request,
    this.fromUser,
    this.toUser,
    this.project,
  });
}

// Member Request Bloc
class MemberRequestBloc extends Bloc<MemberRequestEvent, MemberRequestState> {
  MemberRequestBloc() : super(MemberRequestInitial()) {
    on<LoadPendingRequests>(_onLoadPendingRequests);
    on<LoadSentRequests>(_onLoadSentRequests);
    on<AcceptRequest>(_onAcceptRequest);
    on<DeclineRequest>(_onDeclineRequest);
    on<SendProjectInvitation>(_onSendProjectInvitation);
  }

  Future<void> _onLoadPendingRequests(
    LoadPendingRequests event,
    Emitter<MemberRequestState> emit,
  ) async {
    try {
      await emit.forEach<List<MemberRequest>>(
        FirebaseService.getPendingRequestsStream(),
        onData: (pendingRequests) {
          // Convert to MemberRequestWithDetails
          final pendingWithDetails = pendingRequests.map((request) => 
            MemberRequestWithDetails(
              request: request,
              fromUser: null,
              toUser: null,
              project: null,
            )
          ).toList();
          
          // Preserve existing sent requests if available
          final currentState = state;
          final sentRequests = currentState is RequestsLoaded 
              ? currentState.sentRequests 
              : <MemberRequestWithDetails>[];
          
          return RequestsLoaded(
            pendingRequests: pendingWithDetails,
            sentRequests: sentRequests,
          );
        },
        onError: (error, stackTrace) => MemberRequestError('Failed to load requests: ${error.toString()}'),
      );
    } catch (e) {
      emit(MemberRequestError('Failed to load requests: ${e.toString()}'));
    }
  }

  Future<void> _onLoadSentRequests(
    LoadSentRequests event,
    Emitter<MemberRequestState> emit,
  ) async {
    try {
      await emit.forEach<List<MemberRequest>>(
        FirebaseService.getSentRequestsStream(),
        onData: (sentRequests) {
          // Convert to MemberRequestWithDetails
          final sentWithDetails = sentRequests.map((request) => 
            MemberRequestWithDetails(
              request: request,
              fromUser: null,
              toUser: null,
              project: null,
            )
          ).toList();
          
          // Preserve existing pending requests if available
          final currentState = state;
          final pendingRequests = currentState is RequestsLoaded 
              ? currentState.pendingRequests 
              : <MemberRequestWithDetails>[];
          
          return RequestsLoaded(
            pendingRequests: pendingRequests,
            sentRequests: sentWithDetails,
          );
        },
        onError: (error, stackTrace) => MemberRequestError('Failed to load sent requests: ${error.toString()}'),
      );
    } catch (e) {
      emit(MemberRequestError('Failed to load sent requests: ${e.toString()}'));
    }
  }

  Future<void> _onAcceptRequest(
    AcceptRequest event,
    Emitter<MemberRequestState> emit,
  ) async {
    try {
      await FirebaseService.acceptMemberRequest(event.requestId);
      emit(const MemberRequestOperationSuccess('Request accepted successfully'));
      add(LoadPendingRequests()); // Reload requests
    } catch (e) {
      emit(MemberRequestError('Failed to accept request: ${e.toString()}'));
    }
  }

  Future<void> _onDeclineRequest(
    DeclineRequest event,
    Emitter<MemberRequestState> emit,
  ) async {
    try {
      await FirebaseService.declineMemberRequest(event.requestId);
      emit(const MemberRequestOperationSuccess('Request declined'));
      add(LoadPendingRequests()); // Reload requests
    } catch (e) {
      emit(MemberRequestError('Failed to decline request: ${e.toString()}'));
    }
  }

  Future<void> _onSendProjectInvitation(
    SendProjectInvitation event,
    Emitter<MemberRequestState> emit,
  ) async {
    try {
      await FirebaseService.sendProjectInvitation(
        event.projectId,
        event.userId,
        event.message,
      );
      emit(const MemberRequestOperationSuccess('Invitation sent successfully'));
      add(LoadSentRequests()); // Reload sent requests
    } catch (e) {
      emit(MemberRequestError('Failed to send invitation: ${e.toString()}'));
    }
  }
}
