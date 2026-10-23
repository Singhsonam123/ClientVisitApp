# Setup Instructions for Clean Architecture Login API

## Step 1: Initialize Service Locator in main()

Update your `lib/main.dart` to initialize the ServiceLocator before running the app:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/service_locator.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize all dependencies
  await ServiceLocator.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Team Agenda',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (context) => AuthBloc(
          context.read<AuthRepository>(),
          loginUseCase: ServiceLocator.get<LoginUseCase>(),
        ),
        child: const AuthCheckPage(), // Your initial auth check page
      ),
    );
  }
}
```

## Step 2: Run with Localhost API

### For Development (Localhost)

#### macOS/Linux:
```bash
flutter run --dart-define=API_URL=http://localhost:3000/api
```

#### Android Emulator:
```bash
flutter run --dart-define=API_URL=http://10.0.2.2:3000/api
```

#### iOS Simulator:
```bash
flutter run --dart-define=API_URL=http://localhost:3000/api
```

### For Production:
```bash
flutter run --dart-define=API_URL=https://api-photoshare.valuelabs.com/api
```

## Step 3: Verify API Configuration

The API client will automatically:
1. Use the provided API_URL or fall back to production default
2. Add Authorization header with bearer token after login
3. Log all requests and responses for debugging

Check the console output to verify:
```
[API] POST http://localhost:3000/api/auth/login/
[API] Request: {"email":"superadmin@valuelabs.com","password":"YourPassword123"}
[API] Response: {"access":"<token>","refresh":"<token>","user":{...}}
```

## Step 4: Test Login Flow

### Test Credentials
```
Email: superadmin@valuelabs.com
Password: YourPassword123
```

### Expected Flow
1. User enters credentials on login page
2. Click "Sign In" button
3. Loading indicator appears
4. API call is made to `/auth/login/`
5. On success:
   - Tokens are saved to SharedPreferences
   - User data is saved to SharedPreferences
   - App navigates to home page
6. On error:
   - Error toast is displayed
   - User can retry

## Step 5: Verify Local Storage

After successful login, verify data is saved:

```dart
import 'package:shared_preferences/shared_preferences.dart';

void verifyLoginData() async {
  final prefs = await SharedPreferences.getInstance();
  
  print('=== Login Data Verification ===');
  print('Is Logged In: ${prefs.getBool('is_logged_in')}');
  print('Access Token: ${prefs.getString('auth_token')}');
  print('Refresh Token: ${prefs.getString('refresh_token')}');
  print('User ID: ${prefs.getString('employee_id')}');
  print('User Email: ${prefs.getString('employee_email')}');
  print('User Name: ${prefs.getString('employee_name')}');
  print('User Role: ${prefs.getString('user_role')}');
  print('Full Response: ${prefs.getString('login_response')}');
}
```

## Step 6: Handle Token Refresh (Optional)

For production, implement token refresh logic:

```dart
// Add to LoginRepositoryImpl
Future<void> refreshToken() async {
  try {
    final refreshToken = prefs.getString('refresh_token');
    if (refreshToken == null) return;

    final response = await dio.post(
      ApiEndpoints.refreshTokenEndpoint,
      data: {'refresh': refreshToken},
    );

    final newAccessToken = response.data['access'] as String;
    await prefs.setString(AppConstants.prefKeyAuthToken, newAccessToken);
    ApiClient.setToken(newAccessToken);
  } catch (e) {
    // Handle refresh failure - logout user
    await logout();
  }
}
```

## Step 7: Add Interceptor for Token Refresh (Optional)

Add automatic token refresh to ApiClient:

```dart
// In ApiClient._dio initialization
..interceptors.addAll([
  InterceptorsWrapper(
    onError: (error, handler) async {
      if (error.response?.statusCode == 401) {
        // Token expired, try to refresh
        try {
          await _refreshToken();
          // Retry original request
          return handler.resolve(await _dio.request(
            error.requestOptions.path,
            options: Options(
              method: error.requestOptions.method,
              headers: error.requestOptions.headers,
            ),
            data: error.requestOptions.data,
          ));
        } catch (e) {
          return handler.reject(error);
        }
      }
      return handler.next(error);
    },
  ),
  // ... other interceptors
]);
```

## Troubleshooting

### Issue: "Service of type LoginUseCase not found"
**Solution**: Make sure `ServiceLocator.init()` is called before creating AuthBloc

### Issue: "Connection refused" error
**Solution**: 
- Verify backend server is running on the correct port
- For Android emulator, use `10.0.2.2` instead of `localhost`
- Check firewall settings

### Issue: "Invalid email or password" error
**Solution**:
- Verify credentials are correct
- Check backend API is responding correctly
- Check API logs for detailed error messages

### Issue: Tokens not saved to SharedPreferences
**Solution**:
- Verify SharedPreferences is initialized
- Check app has storage permissions
- Verify response JSON structure matches expected format

### Issue: Token not included in subsequent requests
**Solution**:
- Verify `ApiClient.setToken()` is called after login
- Check Authorization header is being added by interceptor
- Verify token is not empty or null

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│                   Presentation Layer                     │
│  ┌──────────────────────────────────────────────────┐   │
│  │  LoginPage                                       │   │
│  │  - Displays login form                           │   │
│  │  - Dispatches AuthCleanLoginRequested event      │   │
│  └──────────────────────────────────────────────────┘   │
│                          ↓                                │
│  ┌──────────────────────────────────────────────────┐   │
│  │  AuthBloc                                        │   │
│  │  - Handles AuthCleanLoginRequested event         │   │
│  │  - Calls LoginUseCase                            │   │
│  │  - Emits AuthLoading/AuthAuthenticated/AuthFailure   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│                    Domain Layer                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │  LoginUseCase                                    │   │
│  │  - Orchestrates login business logic             │   │
│  │  - Calls LoginRepository.login()                 │   │
│  └──────────────────────────────────────────────────┘   │
│                          ↓                                │
│  ┌──────────────────────────────────────────────────┐   │
│  │  LoginRepository (Abstract)                      │   │
│  │  - Defines login contract                        │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│                     Data Layer                           │
│  ┌──────────────────────────────────────────────────┐   │
│  │  LoginRepositoryImpl                              │   │
│  │  - Implements LoginRepository                    │   │
│  │  - Calls LoginRemoteDataSource                   │   │
│  │  - Saves data to SharedPreferences               │   │
│  └──────────────────────────────────────────────────┘   │
│                          ↓                                │
│  ┌──────────────────────────────────────────────────┐   │
│  │  LoginRemoteDataSource                           │   │
│  │  - Makes POST request to /auth/login/            │   │
│  │  - Parses LoginResponseModel                     │   │
│  └──────────────────────────────────────────────────┘   │
│                          ↓                                │
│  ┌──────────────────────────────────────────────────┐   │
│  │  ApiClient (Dio)                                 │   │
│  │  - Configurable base URL                         │   │
│  │  - Bearer token injection                        │   │
│  │  - Request/response logging                      │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│                   Backend API                            │
│  POST /api/auth/login/                                  │
│  Request: {email, password}                             │
│  Response: {access, refresh, user}                      │
└─────────────────────────────────────────────────────────┘
```

## Summary

You now have a complete clean architecture implementation for the login API:

✅ Domain layer with entities, repositories, and use cases
✅ Data layer with models, data sources, and repository implementation
✅ Presentation layer with BLoC and updated login page
✅ Dependency injection with ServiceLocator
✅ Common utilities for API endpoints and toast notifications
✅ Local storage persistence with SharedPreferences
✅ Configurable API URL for localhost development

The implementation follows SOLID principles and is ready for production use.
