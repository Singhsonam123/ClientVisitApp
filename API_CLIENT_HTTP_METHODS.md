# ApiClient HTTP Methods

## Overview
The `ApiClient` class now includes convenient static methods for all common HTTP operations. These methods automatically handle:
- Bearer token injection via the Authorization header
- Request/response logging
- Timeout configuration
- Error handling

## Available Methods

### GET Request
```dart
static Future<Response<T>> get<T>(
  String path, {
  Map<String, dynamic>? queryParameters,
  Options? options,
  CancelToken? cancelToken,
  ProgressCallback? onReceiveProgress,
})
```

**Example:**
```dart
final response = await ApiClient.get('/projects/');
```

### POST Request
```dart
static Future<Response<T>> post<T>(
  String path, {
  dynamic data,
  Map<String, dynamic>? queryParameters,
  Options? options,
  CancelToken? cancelToken,
  ProgressCallback? onSendProgress,
  ProgressCallback? onReceiveProgress,
})
```

**Example:**
```dart
final response = await ApiClient.post(
  '/projects/',
  data: {'name': 'My Project', 'description': 'Description'},
);
```

### PATCH Request
```dart
static Future<Response<T>> patch<T>(
  String path, {
  dynamic data,
  Map<String, dynamic>? queryParameters,
  Options? options,
  CancelToken? cancelToken,
  ProgressCallback? onSendProgress,
  ProgressCallback? onReceiveProgress,
})
```

**Example:**
```dart
final response = await ApiClient.patch(
  '/projects/123/',
  data: {'name': 'Updated Name'},
);
```

### DELETE Request
```dart
static Future<Response<T>> delete<T>(
  String path, {
  dynamic data,
  Map<String, dynamic>? queryParameters,
  Options? options,
  CancelToken? cancelToken,
})
```

**Example:**
```dart
final response = await ApiClient.delete('/projects/123/');
```

### PUT Request
```dart
static Future<Response<T>> put<T>(
  String path, {
  dynamic data,
  Map<String, dynamic>? queryParameters,
  Options? options,
  CancelToken? cancelToken,
  ProgressCallback? onSendProgress,
  ProgressCallback? onReceiveProgress,
})
```

**Example:**
```dart
final response = await ApiClient.put(
  '/projects/123/',
  data: {'name': 'New Name', 'description': 'New Description'},
);
```

## Features

### Automatic Authorization
All requests automatically include the Bearer token in the Authorization header:
```
Authorization: Bearer <token>
```

### Request/Response Logging
All requests and responses are logged with:
- Request body
- Response body
- Status codes
- Headers

### Timeout Configuration
- Connection timeout: 15 seconds
- Receive timeout: 30 seconds

### Type Safety
All methods support generic type parameters for type-safe responses:
```dart
final response = await ApiClient.get<List<ProjectModel>>('/projects/');
```

## Migration Guide

### Before (using Dio directly)
```dart
final dio = ApiClient.instance;
final response = await dio.get('/projects/');
```

### After (using ApiClient methods)
```dart
final response = await ApiClient.get('/projects/');
```

## File Location
- **File:** [`lib/core/network/api_client.dart`](lib/core/network/api_client.dart)
- **Lines:** 76-173

## Benefits
1. **Cleaner Code:** No need to access `ApiClient.instance` directly
2. **Consistency:** All HTTP calls use the same interface
3. **Maintainability:** Centralized HTTP method definitions
4. **Type Safety:** Generic type parameters for responses
5. **Automatic Token Injection:** Bearer token added to all requests automatically
