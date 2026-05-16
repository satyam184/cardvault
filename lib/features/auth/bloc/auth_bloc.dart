import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/services/token_storage_service.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}
class LoggedIn extends AuthEvent {
  final UserModel user;
  const LoggedIn(this.user);
}
class LoggedOut extends AuthEvent {}

// States
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, user, errorMessage];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;
  final TokenStorageService _tokenService;

  AuthBloc(this._repository, this._tokenService) : super(const AuthState()) {
    on<AppStarted>(_onAppStarted);
    on<LoggedIn>(_onLoggedIn);
    on<LoggedOut>(_onLoggedOut);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(const AuthState(status: AuthStatus.loading));
    
    final token = await _tokenService.getAccessToken();
    if (token != null) {
      // In a real app, you might want to call a /me endpoint here to get user data
      // For now, we assume authenticated if token exists
      emit(const AuthState(status: AuthStatus.authenticated));
    } else {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  void _onLoggedIn(LoggedIn event, Emitter<AuthState> emit) {
    emit(AuthState(status: AuthStatus.authenticated, user: event.user));
  }

  Future<void> _onLoggedOut(LoggedOut event, Emitter<AuthState> emit) async {
    await _repository.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
