# Token Injection Fix for Projects API

## Problem
The projects API was returning 401 Unauthorized errors because the Bearer token was not being included in the API requests.

## Root Cause
The `ProjectsRemoteDataSourceImpl` was using `ApiClient.instance` directly (the Dio instance), which bypassed the new HTTP method helpers that ensure proper token injection through the interceptor.

## Solution
Updated all API calls in `ProjectsRemoteDataSourceImpl` to use the new `ApiClient` HTTP method helpers instead of accessing `ApiClient.instance` directly.

## Changes Made

### File Modified
**File:** [`lib/features/projects/data/datasources/projects_remote_datasource.dart`](lib/features/projects/data/datasources/projects_remote_datasource.dart)

### Before (Using Dio directly)
```dart
class ProjectsRemoteDataSourceImpl implements ProjectsRemoteDataSource {
  final Dio _dio = ApiClient.instance;

  @override
  Future<List<ProjectModel>> listProjects() async {
    try {
      final response = await _dio.get(ApiEndpoints.projectsEndpoint);
      // ...
    }
  }
}
```

### After (Using ApiClient methods)
```dart
class ProjectsRemoteDataSourceImpl implements ProjectsRemoteDataSource {
  @override
  Future<List<ProjectModel>> listProjects() async {
    try {
      final response = await ApiClient.get(ApiEndpoints.projectsEndpoint);
      // ...
    }
  }
}
```

## Methods Updated

1. **createProject()** - Changed from `_dio.post()` to `ApiClient.post()`
2. **listProjects()** - Changed from `_dio.get()` to `ApiClient.get()`
3. **getProjectDetail()** - Changed from `_dio.get()` to `ApiClient.get()`
4. **updateProject()** - Changed from `_dio.patch()` to `ApiClient.patch()`
5. **deleteProject()** - Changed from `_dio.delete()` to `ApiClient.delete()`
6. **createAdmin()** - Changed from `_dio.post()` to `ApiClient.post()`
7. **assignAdmin()** - Changed from `_dio.post()` to `ApiClient.post()`

## How Token Injection Works Now

```
API Request
    ↓
ApiClient.get/post/patch/delete/put()
    ↓
Dio interceptor onRequest
    ↓
Check if _token is set
    ↓
Add Authorization header: "Bearer <token>"
    ↓
Send request with token
    ↓
Backend receives request with valid token
    ↓
200 OK response
```

## Token Flow

1. **Login** → `AuthRepository._saveSession()` → `ApiClient.setToken(token)`
2. **Projects API Call** → `ApiClient.get()` → Interceptor checks `_token`
3. **Token Injected** → Authorization header added automatically
4. **API Success** → 200 response with projects data

## Benefits

✅ **Automatic Token Injection** - No manual header management needed

✅ **Consistent API Calls** - All HTTP methods use the same pattern

✅ **Type Safety** - Generic type parameters for responses

✅ **Error Handling** - Proper exception handling for all requests

✅ **Logging** - All requests/responses logged automatically

## Compilation Status

✅ **No Errors** - App compiles successfully with 0 errors

✅ **163 Info-level Warnings** - Only style and asset warnings (no functional issues)

## Testing

To verify the fix works:

1. Run the app: `flutter run`
2. Login with valid credentials
3. Pull down on the home page to refresh projects
4. Verify projects list loads successfully (no 401 errors)
5. Check the API logs to confirm Bearer token is included

## API Endpoints Affected

- `GET /api/projects/` - List all projects
- `POST /api/projects/` - Create new project
- `GET /api/projects/{id}/` - Get project details
- `PATCH /api/projects/{id}/` - Update project
- `DELETE /api/projects/{id}/` - Delete project
- `POST /api/projects/{id}/create-admin/` - Create admin
- `POST /api/projects/{id}/assign-admin/` - Assign admin

All endpoints now receive the Bearer token automatically.
