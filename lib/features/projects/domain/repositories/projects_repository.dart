import '../entities/project.dart';
import '../../data/models/admin_model.dart';

abstract class ProjectsRepository {
  /// Create a new project (Super Admin only)
  Future<Project> createProject({
    required String name,
    required String description,
  });

  /// List all projects (Super Admin / Admin)
  Future<List<Project>> listProjects();

  /// Get project detail (Project members)
  Future<Project> getProjectDetail(String projectId);

  /// Update project (Super Admin only)
  Future<Project> updateProject({
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
