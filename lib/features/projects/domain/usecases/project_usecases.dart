import '../entities/project.dart';
import '../repositories/projects_repository.dart';
import '../../data/models/admin_model.dart';

class GetProjectDetailUseCase {
  final ProjectsRepository repository;

  GetProjectDetailUseCase(this.repository);

  Future<Project> call(String projectId) async {
    return await repository.getProjectDetail(projectId);
  }
}

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

class DeleteProjectUseCase {
  final ProjectsRepository repository;

  DeleteProjectUseCase(this.repository);

  Future<void> call(String projectId) async {
    return await repository.deleteProject(projectId);
  }
}

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
