import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/auth_repository.dart';
import '../../domain/models/employee_model.dart';

// ── Events ────────────────────────────────────────────────────────────────────
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthLoginRequested({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class AuthSignupRequested extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  const AuthSignupRequested({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });
  @override
  List<Object?> get props => [firstName, lastName, email, password];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

// ── States ────────────────────────────────────────────────────────────────────
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final EmployeeModel employee;
  const AuthAuthenticated(this.employee);
  @override
  List<Object?> get props => [employee];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthSignupSuccess extends AuthState {
  const AuthSignupSuccess();
}

class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// ── BLoC ──────────────────────────────────────────────────────────────────────
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc(this._repository) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthSignupRequested>(_onSignupRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await Future.delayed(const Duration(milliseconds: 800));
    final employee = _repository.currentEmployee;
    if (employee != null) {
      emit(AuthAuthenticated(employee));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final employee = await _repository.login(
        email:    event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(employee));
    } on DioException catch (e) {
      final data = e.response?.data;
      final String msg;
      if (data is Map) {
        msg = data['detail'] as String?
            ?? data['message'] as String?
            ?? data['error'] as String?
            ?? 'Invalid email or password.';
      } else {
        msg = 'Invalid email or password.';
      }
      emit(AuthFailure(msg));
    } catch (e) {
      emit(AuthFailure('Login failed: ${e.toString()}'));
    }
  }

  Future<void> _onSignupRequested(
    AuthSignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _repository.signup(
        firstName: event.firstName,
        lastName:  event.lastName,
        email:     event.email,
        password:  event.password,
      );
      // Clear the auto-created session so the user logs in manually.
      await _repository.logout();
      emit(const AuthSignupSuccess());
    } on DioException catch (e) {
      final data = e.response?.data;
      String msg = 'Sign up failed. Please try again.';
      if (data is Map) {
        // Surface field-level validation errors (e.g. password rules)
        final errors = data['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final parts = <String>[];
          errors.forEach((key, value) {
            if (value is List) {
              parts.addAll(value.cast<String>());
            } else {
              parts.add(value.toString());
            }
          });
          if (parts.isNotEmpty) msg = parts.join('\n');
        } else {
          msg = data['detail'] as String?
              ?? data['message'] as String?
              ?? data['error'] as String?
              ?? msg;
        }
      }
      emit(AuthFailure(msg));
    } catch (e) {
      emit(AuthFailure('Sign up failed: ${e.toString()}'));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _repository.logout();
    emit(const AuthUnauthenticated());
  }
}