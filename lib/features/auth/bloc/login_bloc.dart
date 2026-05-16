import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/models/user_model.dart';

// Events
abstract class LoginEvent extends Equatable {
  const LoginEvent();
  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends LoginEvent {
  final String email;
  final String password;
  const LoginSubmitted(this.email, this.password);
}

class RegisterSubmitted extends LoginEvent {
  final String name;
  final String email;
  final String password;
  const RegisterSubmitted(this.name, this.email, this.password);
}

// States
enum LoginStatus { initial, loading, success, failure }

class LoginState extends Equatable {
  final LoginStatus status;
  final UserModel? user;
  final String? error;

  const LoginState({
    this.status = LoginStatus.initial,
    this.user,
    this.error,
  });

  @override
  List<Object?> get props => [status, user, error];
}

// BLoC
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _repository;

  LoginBloc(this._repository) : super(const LoginState()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  Future<void> _onLoginSubmitted(LoginSubmitted event, Emitter<LoginState> emit) async {
    emit(const LoginState(status: LoginStatus.loading));
    try {
      final response = await _repository.login(event.email, event.password);
      emit(LoginState(status: LoginStatus.success, user: response.user));
    } catch (e) {
      emit(LoginState(status: LoginStatus.failure, error: e.toString()));
    }
  }

  Future<void> _onRegisterSubmitted(RegisterSubmitted event, Emitter<LoginState> emit) async {
    emit(const LoginState(status: LoginStatus.loading));
    try {
      final response = await _repository.register(
        name: event.name,
        email: event.email,
        password: event.password,
      );
      emit(LoginState(status: LoginStatus.success, user: response.user));
    } catch (e) {
      emit(LoginState(status: LoginStatus.failure, error: e.toString()));
    }
  }
}
