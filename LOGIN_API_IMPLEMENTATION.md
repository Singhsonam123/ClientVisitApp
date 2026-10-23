# Login API Implementation - Clean Architecture

## Overview
This document describes the implementation of the login API using clean architecture principles in the ClientVisitApp Flutter application.

## Architecture Layers

### 1. Domain Layer
The domain layer contains business logic and is independent of any framework or external dependencies.

#### Entities
- **[`LoginResponseEntity`](lib/features/auth/domain/entities/login_response.dart)** - Represents the login response with tokens and user info
- **[`UserEntity`](lib/features/auth/domain/entities/login_response.dart)** - Represents user information

#### Repositories (Abstract)
- **[`LoginRepository`](lib/features/auth/domain/repositories/login_repository.dart)** - Abstract interface for login operations

#### Use Cases
- **[`LoginUseCase`](lib/features/auth/domain/usecases/login_usecase.dart)** - Orchestrates login business logic

### 2. Data Layer
The data layer handles API calls and local storage persistence.

#### Models
- **[`LoginResponseModel`](lib/features/auth/data/models/login_response_model.dart)** - JSON serializable model for API responses
- **[`UserModel`](lib/features/auth/data/models/login_response_model.dart)** - JSON serializable user model

#### Data Sources
- **[`LoginRemoteDataSource`](lib/features/auth/data/datasources/login_remote_datasource.dart)** - Handles remote API calls to `/auth/login/`

#### Repositories (Implementation)
- **[`LoginRepositoryImpl`](lib/features/auth/data/repositories/login_repository_impl.dart)** - Implements login repository with API calls and local storage

### 3. Presentation Layer
The presentation layer handles UI and state management.

#### BLoC
- **[`AuthBloc`](lib/features/auth/presentation/bloc/auth_bloc.dart)** - State management for authentication
  - New Event: `AuthCleanLoginRequested` - Triggers clean architecture login flow
  - Handler: `_onCleanLoginRequested` - Processes login via use case

#### Pages
- **[`LoginPage`](lib/features/auth/presentation/pages/login_page.dart)** - Updated to use clean architecture login

## API Endpoint

### Login Endpoint
```
POST /api/auth/login/
```

#### Request
```json
{
  "email": "superadmin@valuelabs.com",
  "password": "YourPassword123"
}
```

#### Response
```json
{
  "access": "<jwt_access_token>",
  "refresh": "<jwt_refresh_token>",
  "user": {
    "user_id": "uuid",
    "email": "superadmin@valuelabs.com",
    "full_name": "Super Admin",
    "role": "SUPER_ADMIN"
  }
}
```

## Local Storage
All login response data is saved to SharedPreferences:

| Key | Value |
|-----|-------|
| `auth_token` | JWT access token |
| `refresh_token` | JWT refresh token |
| `employee_id` | User ID |
| `employee_email` | User email |
| `employee_name` | User full name |
| `user_role` | User role |
| `is_logged_in` | Boolean flag |
| `login_response` | Full JSON response |

## Dependency Injection

### Service Locator
The **[`ServiceLocator`](lib/core/di/service_locator.dart)** class manages all dependencies:

```dart
// Initialize in main()
await ServiceLocator.init();

// Get dependencies
final loginUseCase = ServiceLocator.get<LoginUseCase>();
```

#### Registered Dependencies
- `LoginRemoteDataSource` - Remote API calls
- `LoginRepository` - Repository implementation
- `LoginUseCase` - Business logic orchestration

## Common Utilities

### API Endpoints
All API endpoints are centralized in **[`ApiEndpoints`](lib/core/constants/api_endpoints.dart)**:
```dart
static const String loginEndpoint = '/auth/login/';
```

### Toast Notifications
Common toast/snackbar utility in **[`AppToast`](lib/core/utils/app_toast.dart)**:
```dart
AppToast.showError(context, 'Login failed');
AppToast.showSuccess(context, 'Login successful');
AppToast.showWarning(context, 'Warning message');
AppToast.showInfo(context, 'Info message');
```

## Running with Localhost API

### Configure API URL
Run the app with a custom API URL:

```bash
flutter run --dart-define=API_URL=http://localhost:3000/api
```

Or for Android emulator:
```bash
flutter run --dart-define=API_URL=http://10.0.2.2:3000/api
```

### API Client Configuration
The **[`ApiClient`](lib/core/network/api_client.dart)** automatically:
1. Sets the base URL from environment variable or uses production default
2. Injects Authorization header with bearer token
3. Logs all requests and responses

## Login Flow

### Step-by-Step Process

1. **User Input** - User enters email and password on login page
2. **Validation** - Login page validates inputs
3. **Event Dispatch** - `AuthCleanLoginRequested` event is dispatched to AuthBloc
4. **Loading State** - BLoC emits `AuthLoading` state
5. **API Call** - LoginUseCase calls LoginRepository
6. **Remote Call** - LoginRemoteDataSource makes POST request to `/auth/login/`
7. **Response Parsing** - LoginResponseModel parses JSON response
8. **Local Storage** - LoginRepositoryImpl saves all data to SharedPreferences
9. **Token Setup** - Access token is set in ApiClient for subsequent requests
10. **Success State** - BLoC emits `AuthAuthenticated` state with user data
11. **Navigation** - App navigates to home page

### Error Handling

If any step fails:
1. Exception is caught in `_onCleanLoginRequested`
2. Error message is extracted from response or exception
3. BLoC emits `AuthFailure` state with error message
4. AppToast displays error to user

## Testing the Implementation

### Test Credentials
```
Email: superadmin@valuelabs.com
Password: YourPassword123
```

### Verify Local Storage
After successful login, check SharedPreferences:
```dart
final prefs = await SharedPreferences.getInstance();
print('Token: ${prefs.getString('auth_token')}');
print('User ID: ${prefs.getString('employee_id')}');
print('User Email: ${prefs.getString('employee_email')}');
print('User Name: ${prefs.getString('employee_name')}');
print('User Role: ${prefs.getString('user_role')}');
```

## Files Created/Modified

### New Files
- `lib/features/auth/domain/entities/login_response.dart`
- `lib/features/auth/domain/repositories/login_repository.dart`
- `lib/features/auth/domain/usecases/login_usecase.dart`
- `lib/features/auth/data/models/login_response_model.dart`
- `lib/features/auth/data/datasources/login_remote_datasource.dart`
- `lib/features/auth/data/repositories/login_repository_impl.dart`
- `lib/core/di/service_locator.dart`
- `lib/core/constants/api_endpoints.dart`
- `lib/core/utils/app_toast.dart`

### Modified Files
- `lib/features/auth/presentation/bloc/auth_bloc.dart` - Added clean login event and handler
- `lib/features/auth/presentation/pages/login_page.dart` - Updated to use clean architecture login

## Next Steps

1. **Initialize ServiceLocator** in `main()`:
   ```dart
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await ServiceLocator.init();
     runApp(const MyApp());
   }
   ```

2. **Provide LoginUseCase to AuthBloc**:
   ```dart
   BlocProvider(
     create: (context) => AuthBloc(
       context.read<AuthRepository>(),
       loginUseCase: ServiceLocator.get<LoginUseCase>(),
     ),
     child: const LoginPage(),
   )
   ```

3. **Test with localhost API**:
   ```bash
   flutter run --dart-define=API_URL=http://localhost:3000/api
   ```

4. **Verify token persistence** across app restarts

## Architecture Benefits

✅ **Separation of Concerns** - Each layer has a single responsibility
✅ **Testability** - Easy to unit test with mocked dependencies
✅ **Reusability** - Use cases can be reused across different UI components
✅ **Maintainability** - Clear structure makes code easier to maintain
✅ **Scalability** - Easy to add new features following the same pattern
✅ **Dependency Injection** - Loose coupling between components
