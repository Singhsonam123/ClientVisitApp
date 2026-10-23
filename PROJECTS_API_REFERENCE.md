# Projects API Methods Reference

## Overview
This document provides complete reference for all Project Management API methods implemented in the application.

## Project Endpoints Configuration

**File:** [`lib/core/constants/api_endpoints.dart`](lib/core/constants/api_endpoints.dart)

```dart
class ApiEndpoints {
  // Projects endpoints
  static const String projectsEndpoint = '/api/projects/';
  static const String projectDetailEndpoint = '/api/projects/{id}/';
  static const String createAdminEndpoint = '/api/projects/{id}/create-admin/';
  static const String assignAdminEndpoint = '/api/projects/{id}/assign-admin/';
}
```

---

## 1. Create Project

**Endpoint:** `POST /api/projects/`  
**Access:** Super Admin only  
**Description:** Create a new project

**Location:** [`lib/features/projects/domain/usecases/create_project_usecase.dart`](lib/features/projects/domain/usecases/create_project_usecase.dart)

**Method:**
```dart
class CreateProjectUseCase {
  final ProjectsRepository repository;

  CreateProjectUseCase(this.repository);

  Future<Project> call({
    required String name,
    required String description,
  }) async {
    return await repository.createProject(
      name: name,
      description: description,
    );
  }
}
```

**Implementation in Remote DataSource:**
```dart
Future<ProjectModel> createProject({
  required String name,
  required String description,
}) async {
  try {
    final response = await _dio.post(
      ApiEndpoints.projectsEndpoint,
      data: {
        'name': name,
        'description': description,
      },
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return ProjectModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw Exception('Failed to create project');
    }
  } on DioException catch (e) {
    final message = e.response?.data['message'] ??
        e.response?.data['error'] ??
        'Failed to create project';
    throw Exception(message);
  } catch (e) {
    throw Exception('Error: ${e.toString()}');
  }
}
```

**Request Body:**
```json
{
  "name": "Project Name",
  "description": "Project Description"
}
```

**Response Example:**
```json
{
  "id": "proj_123",
  "name": "Project Name",
  "description": "Project Description",
  "status": "active",
  "created_at": "2026-10-20T20:23:00Z",
  "updated_at": "2026-10-20T20:23:00Z",
  "created_by": "admin_user_id"
}
```

---

## 2. List Projects

**Endpoint:** `GET /api/projects/`  
**Access:** Super Admin / Admin  
**Description:** List all projects

**Location:** [`lib/features/projects/domain/usecases/list_projects_usecase.dart`](lib/features/projects/domain/usecases/list_projects_usecase.dart)

**Method:**
```dart
class ListProjectsUseCase {
  final ProjectsRepository repository;

  ListProjectsUseCase(this.repository);

  Future<List<Project>> call() async {
    return await repository.listProjects();
  }
}
```

**Implementation in Remote DataSource:**
```dart
Future<List<ProjectModel>> listProjects() async {
  try {
    final response = await _dio.get(ApiEndpoints.projectsEndpoint);

    if (response.statusCode == 200) {
      final data = response.data;
      if (data is List) {
        return data
            .map((item) => ProjectModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (data is Map && data.containsKey('results')) {
        final results = data['results'] as List;
        return results
            .map((item) => ProjectModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } else {
      throw Exception('Failed to fetch projects');
    }
  } on DioException catch (e) {
    final message = e.response?.data['message'] ??
        e.response?.data['error'] ??
        'Failed to fetch projects';
    throw Exception(message);
  } catch (e) {
    throw Exception('Error: ${e.toString()}');
  }
}
```

**Response Example:**
```json
[
  {
    "id": "proj_123",
    "name": "Project 1",
    "description": "Description 1",
    "status": "active",
    "created_at": "2026-10-20T20:23:00Z",
    "updated_at": "2026-10-20T20:23:00Z",
    "created_by": "admin_user_id"
  },
  {
    "id": "proj_124",
    "name": "Project 2",
    "description": "Description 2",
    "status": "active",
    "created_at": "2026-10-20T20:24:00Z",
    "updated_at": "2026-10-20T20:24:00Z",
    "created_by": "admin_user_id"
  }
]
```

---

## 3. Get Project Detail

**Endpoint:** `GET /api/projects/{id}/`  
**Access:** Project members  
**Description:** Get project detail

**Location:** [`lib/features/projects/domain/usecases/project_usecases.dart`](lib/features/projects/domain/usecases/project_usecases.dart)

**Method:**
```dart
class GetProjectDetailUseCase {
  final ProjectsRepository repository;

  GetProjectDetailUseCase(this.repository);

  Future<Project> call(String projectId) async {
    return await repository.getProjectDetail(projectId);
  }
}
```

**Implementation in Remote DataSource:**
```dart
Future<ProjectModel> getProjectDetail(String projectId) async {
  try {
    final endpoint = ApiEndpoints.projectDetailEndpoint.replaceFirst('{id}', projectId);
    final response = await _dio.get(endpoint);

    if (response.statusCode == 200) {
      return ProjectModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw Exception('Failed to fetch project detail');
    }
  } on DioException catch (e) {
    final message = e.response?.data['message'] ??
        e.response?.data['error'] ??
        'Failed to fetch project detail';
    throw Exception(message);
  } catch (e) {
    throw Exception('Error: ${e.toString()}');
  }
}
```

**Response Example:**
```json
{
  "id": "proj_123",
  "name": "Project Name",
  "description": "Project Description",
  "status": "active",
  "created_at": "2026-10-20T20:23:00Z",
  "updated_at": "2026-10-20T20:23:00Z",
  "created_by": "admin_user_id"
}
```

---

## 4. Update Project

**Endpoint:** `PATCH /api/projects/{id}/`  
**Access:** Super Admin only  
**Description:** Update project details

**Location:** [`lib/features/projects/domain/usecases/project_usecases.dart`](lib/features/projects/domain/usecases/project_usecases.dart)

**Method:**
```dart
class UpdateProjectUseCase {
  final ProjectsRepository repository;

  UpdateProjectUseCase(this.repository);

  Future<Project> call({
    required String projectId,
    required String name,
    required String description,
    required String status,
  }) async {
    return await repository.updateProject(
      projectId: projectId,
      name: name,
      description: description,
      status: status,
    );
  }
}
```

**Implementation in Remote DataSource:**
```dart
Future<ProjectModel> updateProject({
  required String projectId,
  required String name,
  required String description,
  required String status,
}) async {
  try {
    final endpoint = ApiEndpoints.projectDetailEndpoint.replaceFirst('{id}', projectId);
    final response = await _dio.patch(
      endpoint,
      data: {
        'name': name,
        'description': description,
        'status': status,
      },
    );

    if (response.statusCode == 200) {
      return ProjectModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw Exception('Failed to update project');
    }
  } on DioException catch (e) {
    final message = e.response?.data['message'] ??
        e.response?.data['error'] ??
        'Failed to update project';
    throw Exception(message);
  } catch (e) {
    throw Exception('Error: ${e.toString()}');
  }
}
```

**Request Body:**
```json
{
  "name": "Updated Project Name",
  "description": "Updated Description",
  "status": "active"
}
```

**Response Example:**
```json
{
  "id": "proj_123",
  "name": "Updated Project Name",
  "description": "Updated Description",
  "status": "active",
  "created_at": "2026-10-20T20:23:00Z",
  "updated_at": "2026-10-20T20:25:00Z",
  "created_by": "admin_user_id"
}
```

---

## 5. Delete/Archive Project

**Endpoint:** `DELETE /api/projects/{id}/`  
**Access:** Super Admin only  
**Description:** Archive project (soft delete)

**Location:** [`lib/features/projects/domain/usecases/project_usecases.dart`](lib/features/projects/domain/usecases/project_usecases.dart)

**Method:**
```dart
class DeleteProjectUseCase {
  final ProjectsRepository repository;

  DeleteProjectUseCase(this.repository);

  Future<void> call(String projectId) async {
    return await repository.deleteProject(projectId);
  }
}
```

**Implementation in Remote DataSource:**
```dart
Future<void> deleteProject(String projectId) async {
  try {
    final endpoint = ApiEndpoints.projectDetailEndpoint.replaceFirst('{id}', projectId);
    final response = await _dio.delete(endpoint);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to archive project');
    }
  } on DioException catch (e) {
    final message = e.response?.data['message'] ??
        e.response?.data['error'] ??
        'Failed to archive project';
    throw Exception(message);
  } catch (e) {
    throw Exception('Error: ${e.toString()}');
  }
}
```

**Response:** HTTP 204 No Content or 200 OK

---

## 6. Create Admin User and Assign to Project

**Endpoint:** `POST /api/projects/{id}/create-admin/`  
**Access:** Super Admin only  
**Description:** Create a new admin user and assign to project

**Location:** [`lib/features/projects/domain/usecases/project_usecases.dart`](lib/features/projects/domain/usecases/project_usecases.dart)

**Method:**
```dart
class CreateAdminUseCase {
  final ProjectsRepository repository;

  CreateAdminUseCase(this.repository);

  Future<AdminModel> call({
    required String projectId,
    required String email,
    required String firstName,
    required String lastName,
    required String password,
  }) async {
    return await repository.createAdmin(
      projectId: projectId,
      email: email,
      firstName: firstName,
      lastName: lastName,
      password: password,
    );
  }
}
```

**Implementation in Remote DataSource:**
```dart
Future<AdminModel> createAdmin({
  required String projectId,
  required String email,
  required String firstName,
  required String lastName,
  required String password,
}) async {
  try {
    final endpoint = ApiEndpoints.createAdminEndpoint.replaceFirst('{id}', projectId);
    final response = await _dio.post(
      endpoint,
      data: {
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'password': password,
      },
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return AdminModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw Exception('Failed to create admin');
    }
  } on DioException catch (e) {
    final message = e.response?.data['message'] ??
        e.response?.data['error'] ??
        'Failed to create admin';
    throw Exception(message);
  } catch (e) {
    throw Exception('Error: ${e.toString()}');
  }
}
```

**Request Body:**
```json
{
  "email": "admin@example.com",
  "first_name": "John",
  "last_name": "Doe",
  "password": "SecurePassword123!"
}
```

**Response Example:**
```json
{
  "id": "admin_123",
  "email": "admin@example.com",
  "first_name": "John",
  "last_name": "Doe",
  "role": "admin",
  "project_id": "proj_123",
  "created_at": "2026-10-20T20:23:00Z"
}
```

---

## 7. Assign Existing Admin to Project

**Endpoint:** `POST /api/projects/{id}/assign-admin/`  
**Access:** Super Admin only  
**Description:** Assign an existing admin user to a project

**Location:** [`lib/features/projects/domain/usecases/project_usecases.dart`](lib/features/projects/domain/usecases/project_usecases.dart)

**Method:**
```dart
class AssignAdminUseCase {
  final ProjectsRepository repository;

  AssignAdminUseCase(this.repository);

  Future<AdminModel> call({
    required String projectId,
    required String adminId,
  }) async {
    return await repository.assignAdmin(
      projectId: projectId,
      adminId: adminId,
    );
  }
}
```

**Implementation in Remote DataSource:**
```dart
Future<AdminModel> assignAdmin({
  required String projectId,
  required String adminId,
}) async {
  try {
    final endpoint = ApiEndpoints.assignAdminEndpoint.replaceFirst('{id}', projectId);
    final response = await _dio.post(
      endpoint,
      data: {
        'admin_id': adminId,
      },
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return AdminModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw Exception('Failed to assign admin');
    }
  } on DioException catch (e) {
    final message = e.response?.data['message'] ??
        e.response?.data['error'] ??
        'Failed to assign admin';
    throw Exception(message);
  } catch (e) {
    throw Exception('Error: ${e.toString()}');
  }
}
```

**Request Body:**
```json
{
  "admin_id": "admin_123"
}
```

**Response Example:**
```json
{
  "id": "admin_123",
  "email": "admin@example.com",
  "first_name": "John",
  "last_name": "Doe",
  "role": "admin",
  "project_id": "proj_123",
  "created_at": "2026-10-20T20:23:00Z"
}
```

---

## Project Models

### Project Entity
**File:** [`lib/features/projects/domain/entities/project.dart`](lib/features/projects/domain/entities/project.dart)

```dart
class Project extends Equatable {
  final String id;
  final String name;
  final String description;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  const Project({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });
}
```

### Project Model
**File:** [`lib/features/projects/data/models/project_model.dart`](lib/features/projects/data/models/project_model.dart)

Includes `fromJson()`, `toJson()`, and `toEntity()` methods for serialization.

### Admin Model
**File:** [`lib/features/projects/data/models/admin_model.dart`](lib/features/projects/data/models/admin_model.dart)

```dart
class AdminModel extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String projectId;
  final DateTime createdAt;
}
```

---

## Architecture Overview

```
Domain Layer (Business Logic)
├── entities/
│   └── project.dart
├── repositories/
│   └── projects_repository.dart
└── usecases/
    ├── create_project_usecase.dart
    ├── list_projects_usecase.dart
    └── project_usecases.dart

Data Layer (API & Storage)
├── datasources/
│   └── projects_remote_datasource.dart
├── models/
│   ├── project_model.dart
│   └── admin_model.dart
└── repositories/
    └── projects_repository_impl.dart
```

---

## Error Handling

All API methods follow this error handling pattern:

1. **Try Block:** Make API call
2. **DioException Catch:** Extract error message from response
3. **Generic Catch:** Handle unexpected errors
4. **User Feedback:** Throw exception with user-friendly message

**Example:**
```dart
try {
  final response = await _dio.post(endpoint, data: data);
  return ProjectModel.fromJson(response.data);
} on DioException catch (e) {
  final message = e.response?.data['message'] ?? 'API Error';
  throw Exception(message);
} catch (e) {
  throw Exception('Unexpected error: ${e.toString()}');
}
```

---

## Usage Example

```dart
// Inject dependencies
final projectsRepository = ProjectsRepositoryImpl(projectsRemoteDataSource);
final createProjectUseCase = CreateProjectUseCase(projectsRepository);

// Create a project
try {
  final project = await createProjectUseCase.call(
    name: 'My Project',
    description: 'Project Description',
  );
  print('Project created: ${project.name}');
} catch (e) {
  print('Error: $e');
}
```

---

## Testing Recommendations

1. **Create Project** - Test with valid/invalid data
2. **List Projects** - Verify pagination and filtering
3. **Get Detail** - Test with valid/invalid project ID
4. **Update Project** - Test partial and full updates
5. **Delete Project** - Verify soft delete behavior
6. **Create Admin** - Test password validation
7. **Assign Admin** - Test with existing admin IDs

---

## Dependencies

- **dio:** ^5.7.0 - HTTP client
- **equatable:** ^2.0.5 - Value equality
- **flutter_bloc:** ^8.1.6 - State management (for future BLoC integration)

---

## Notes

- All endpoints require valid Bearer token in Authorization header
- Token is automatically injected by `ApiClient`
- Endpoint paths use `{id}` placeholder for dynamic IDs
- Error messages are extracted from response body
- All timestamps are in ISO 8601 format
