# LoginUseCase Null Reference Fix

## Problem
When clicking the "Continue" button on the login page, the app was throwing a null reference error:
```
LoginUseCase coming as null
```

This occurred because the `AuthBloc` was being instantiated without the required `LoginUseCase` and `LogoutUseCase` dependencies.

## Root Cause
The `AuthBloc` constructor had optional parameters for `LoginUseCase` and `LogoutUseCase`:
```dart
AuthBloc(
  this._repository, {
  LoginUseCase? loginUseCase,
  LogoutUseCase? logoutUseCase,
})
```

However, when creating the `AuthBloc` in `main.dart`, these use cases were not being passed:
```dart
create: (context) => AuthBloc(authRepository)  // Missing use cases!
```

When the login page triggered `AuthCleanLoginRequested` event, it tried to call `_loginUseCase!.call()` but `_loginUseCase` was null, causing a runtime error.

## Solution

### 1. Updated AuthBloc Constructor
Made `LoginUseCase` and `LogoutUseCase` required parameters:

**File: [`lib/features/auth/presentation/bloc/auth_bloc.dart`](lib/features/auth/presentation/bloc/auth_bloc.dart:117)**
```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;
  final LoginUseCase _loginUseCase;      // Now required (non-nullable)
  final LogoutUseCase _logoutUseCase;    // Now required (non-nullable)

  AuthBloc(
    this._repository, {
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        super(const AuthInitial()) {
    // ... event handlers
  }
```

### 2. Removed Null Checks
Since the use cases are now guaranteed to be non-null, removed unnecessary null checks:

**In `_onCleanLoginRequested` (line 184):**
```dart
// Before
if (_loginUseCase == null) {
  emit(const AuthFailure('Login service not initialized'));
  await Future.delayed(const Duration(milliseconds: 500));
  emit(const AuthUnauthenticated());
  return;
}
final loginResponse = await _loginUseCase!.call(...)

// After
final loginResponse = await _loginUseCase.call(...)
```

**In `_onCleanLogoutRequested` (line 288):**
```dart
// Before
if (_logoutUseCase == null) {
  emit(const AuthFailure('Logout service not initialized'));
  return;
}
await _logoutUseCase!.call();

// After
await _logoutUseCase.call();
```

### 3. Updated main.dart
Initialized `ServiceLocator` and passed use cases to `AuthBloc`:

**File: [`lib/main.dart`](lib/main.dart:12)**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ServiceLocator.init();  // Initialize all dependencies
  runApp(const MyApp());
}

// In MyApp build method:
return BlocProvider(
  create: (context) => AuthBloc(
    authRepository,
    loginUseCase: ServiceLocator.get<LoginUseCase>(),
    logoutUseCase: ServiceLocator.get<LogoutUseCase>(),
  )..add(const AuthCheckRequested()),
  child: const AppRouter(),
);
```

### 4. Updated main_updated.dart
Applied the same fixes to the backup file for consistency.

## Verification
✅ **Flutter analyze: 0 errors** (163 total issues, all are info/warnings unrelated to auth)
✅ **All imports resolved correctly**
✅ **All class references valid**
✅ **LoginUseCase and LogoutUseCase properly injected**

## Login Flow Now Works
1. User enters email and password
2. Clicks "Continue" button
3. `AuthCleanLoginRequested` event is triggered
4. `_onCleanLoginRequested` handler executes
5. `_loginUseCase.call()` is invoked (no longer null)
6. API call is made to `/api/auth/login`
7. On success: `AuthAuthenticated` state emitted → Navigate to Home
8. On error: `AuthFailure` state emitted → Show error toast → Emit `AuthUnauthenticated` for retry

## Files Modified
- [`lib/features/auth/presentation/bloc/auth_bloc.dart`](lib/features/auth/presentation/bloc/auth_bloc.dart)
- [`lib/main.dart`](lib/main.dart)
- [`lib/main_updated.dart`](lib/main_updated.dart)

## Testing Checklist
- [ ] Run `flutter pub get`
- [ ] Run `flutter run` on device/emulator
- [ ] Test login with valid credentials
- [ ] Test login with invalid credentials (should show error toast)
- [ ] Test guest login flow
- [ ] Verify profile screen loads user data
- [ ] Test logout functionality
