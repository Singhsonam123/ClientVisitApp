import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/auth_repository.dart';
import '../../domain/models/employee_model.dart';

// ── Session Expired Event ─────────────────────────────────────────────────
/// Emitted when a 401 Unauthorized response is received after token refresh fails
class SessionExpiredEvent extends AuthEvent {
  const SessionExpiredEvent();
}

// ── Events ────────────────────────────────────────────────────────────────────
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthRoleSelected extends AuthEvent {
  final UserRole role;
  const AuthRoleSelected(this.role);
  @override
  List<Object?> get props => [role];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthLoginRequested({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class AuthCleanLoginRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthCleanLoginRequested({required this.email, required this.password});
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

class AuthCleanLogoutRequested extends AuthEvent {
  const AuthCleanLogoutRequested();
}

class AuthGuestRequested extends AuthEvent {
  const AuthGuestRequested();
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

class AuthRoleSelectionRequired extends AuthState {
  const AuthRoleSelectionRequired();
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

 class AuthSessionExpired extends AuthState {
   const AuthSessionExpired();
 }

// ── BLoC ──────────────────────────────────────────────────────────────────────
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc(this._repository) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthRoleSelected>(_onRoleSelected);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthCleanLoginRequested>(_onCleanLoginRequested);
    on<AuthSignupRequested>(_onSignupRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCleanLogoutRequested>(_onCleanLogoutRequested);
    on<AuthGuestRequested>(_onGuestRequested);
    on<SessionExpiredEvent>(_onSessionExpired);
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
      emit(const AuthRoleSelectionRequired());
    }
  }

  Future<void> _onRoleSelected(
    AuthRoleSelected event,
    Emitter<AuthState> emit,
  ) async {
    await _repository.saveSelectedRole(event.role);
    emit(const AuthUnauthenticated());
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
      final String msg = _extractErrorMessage(e);
      emit(AuthFailure(msg));
    } catch (e) {
      emit(AuthFailure('Login failed: ${e.toString()}'));
    }
  }

  Future<void> _onCleanLoginRequested(
    AuthCleanLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final employee = await _repository.login(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(employee));
    } on DioException catch (e) {
      final String msg = _extractErrorMessage(e);
      emit(AuthFailure(msg));
      // Emit unauthenticated state after error to allow retry
      await Future.delayed(const Duration(milliseconds: 500));
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthFailure('Login failed: ${e.toString()}'));
      // Emit unauthenticated state after error to allow retry
      await Future.delayed(const Duration(milliseconds: 500));
      emit(const AuthUnauthenticated());
    }
  }

  /// Extracts error message from DioException
  String _extractErrorMessage(DioException e) {
    // Check status code first
    final statusCode = e.response?.statusCode;
    if (statusCode != null && statusCode >= 500) {
      return 'Server error: Please try again later';
    }

    final data = e.response?.data;
    
    // Handle Map response (JSON)
    if (data is Map) {
      return data['detail'] as String?
          ?? data['message'] as String?
          ?? data['error'] as String?
          ?? 'Invalid email or password.';
    }
    
    // Handle String response (HTML error page or plain text)
    if (data is String) {
      if (data.contains('Internal Server Error') || data.contains('500')) {
        return 'Server error: Please try again later';
      }
      if (data.contains('Unauthorized') || data.contains('401')) {
        return 'Invalid email or password.';
      }
      if (data.contains('Forbidden') || data.contains('403')) {
        return 'Access denied. Please check your credentials.';
      }
      // Return generic message for other HTML responses
      return 'Login failed. Please try again.';
    }

    return 'Invalid email or password.';
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

  Future<void> _onCleanLogoutRequested(
    AuthCleanLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _repository.logout();
      emit(const AuthUnauthenticated());
    } catch (e) {
      print('Logout error: $e');
      // Even if logout fails, clear the session and emit unauthenticated
      // This ensures user is logged out regardless of server response
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onGuestRequested(
    AuthGuestRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      // Create a guest employee model
      final guestEmployee = EmployeeModel(
        id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Guest User',
        email: 'guest@example.com',
        department: 'Guest',
        role: UserRole.employee,
      );
      emit(AuthAuthenticated(guestEmployee));
    } catch (e) {
      emit(AuthFailure('Guest login failed: ${e.toString()}'));
      await Future.delayed(const Duration(milliseconds: 500));
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onSessionExpired(
    SessionExpiredEvent event,
    Emitter<AuthState> emit,
  ) async {
    print('[AUTH] Session expired - logging out user');
    await _repository.logout();
    emit(const AuthSessionExpired());
  }
}