import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/project_model.dart';
import '../models/admin_model.dart';

abstract class ProjectsRemoteDataSource {
  /// Create a new project (Super Admin only)
  Future<ProjectModel> createProject({
    required String name,
    required String description,
  });

  /// List all projects (Super Admin / Admin)
  Future<List<ProjectModel>> listProjects();

  /// Get project detail (Project members)
  Future<ProjectModel> getProjectDetail(String projectId);

  /// Update project (Super Admin only)
  Future<ProjectModel> updateProject({
    required String projectId,
    required String name,
    required String description,
    required String status,
  });

  /// Archive project (Super Admin only)
  Future<void> deleteProject(String projectId);

  /// Create Admin user and assign to project (Super Admin only)
  Future<AdminModel> createAdmin({
    required String projectId,
    required String email,
    required String firstName,
    required String lastName,
    required String password,
  });

  /// Assign existing Admin to project (Super Admin only)
  Future<AdminModel> assignAdmin({
    required String projectId,
    required String adminId,
  });
}

class ProjectsRemoteDataSourceImpl implements ProjectsRemoteDataSource {
  @override
  Future<ProjectModel> createProject({
    required String name,
    required String description,
  }) async {
    try {
      final response = await ApiClient.post(
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

  @override
  Future<List<ProjectModel>> listProjects() async {
    try {
      final response = await ApiClient.get(ApiEndpoints.projectsEndpoint);

      if (response.statusCode == 200) {
        final data = response.data;
        List<ProjectModel> projects = [];
        
        print('[PROJECTS] Raw response data: $data');
        
        if (data is List) {
          print('[PROJECTS] Response is List with ${data.length} items');
          projects = data
              .map((item) => ProjectModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (data is Map && data.containsKey('results')) {
          final results = data['results'] as List;
          print('[PROJECTS] Response is Map with results key, ${results.length} items');
          projects = results
              .map((item) => ProjectModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        
        print('[PROJECTS] Total projects before dedup: ${projects.length}');
        for (var i = 0; i < projects.length; i++) {
          print('[PROJECTS] Project $i: id=${projects[i].id}, name=${projects[i].name}');
        }
        
        // Remove duplicates: use composite key of (id + name) to identify true duplicates
        // This handles cases where ID might be empty or null
        final seen = <String>{};
        final uniqueProjects = <ProjectModel>[];
        
        for (final project in projects) {
          // Create a composite key: if ID is empty, use name as key, otherwise use ID
          final key = project.id.isNotEmpty
              ? project.id
              : '${project.name}_${project.createdAt}';
          
          if (!seen.contains(key)) {
            seen.add(key);
            uniqueProjects.add(project);
            print('[PROJECTS] Added project: id=${project.id}, name=${project.name}');
          } else {
            print('[PROJECTS] Skipped duplicate: id=${project.id}, name=${project.name}');
          }
        }
        
        print('[PROJECTS] Total projects after dedup: ${uniqueProjects.length}');
        return uniqueProjects;
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

  @override
  Future<ProjectModel> getProjectDetail(String projectId) async {
    try {
      final endpoint = ApiEndpoints.projectDetailEndpoint.replaceFirst('{id}', projectId);
      final response = await ApiClient.get(endpoint);

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

  @override
  Future<ProjectModel> updateProject({
    required String projectId,
    required String name,
    required String description,
    required String status,
  }) async {
    try {
      final endpoint = ApiEndpoints.projectDetailEndpoint.replaceFirst('{id}', projectId);
      final response = await ApiClient.patch(
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

  @override
  Future<void> deleteProject(String projectId) async {
    try {
      final endpoint = ApiEndpoints.projectDetailEndpoint.replaceFirst('{id}', projectId);
      final response = await ApiClient.delete(endpoint);

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

  @override
  Future<AdminModel> createAdmin({
    required String projectId,
    required String email,
    required String firstName,
    required String lastName,
    required String password,
  }) async {
    try {
      final endpoint = ApiEndpoints.createAdminEndpoint.replaceFirst('{id}', projectId);
      final response = await ApiClient.post(
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

  @override
  Future<AdminModel> assignAdmin({
    required String projectId,
    required String adminId,
  }) async {
    try {
      final endpoint = ApiEndpoints.assignAdminEndpoint.replaceFirst('{id}', projectId);
      final response = await ApiClient.post(
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
}
