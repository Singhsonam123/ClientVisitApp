import '../../domain/entities/project.dart';
import '../../domain/repositories/projects_repository.dart';
import '../datasources/projects_remote_datasource.dart';
import '../models/admin_model.dart';

class ProjectsRepositoryImpl implements ProjectsRepository {
  final ProjectsRemoteDataSource _remoteDataSource;

  ProjectsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Project> createProject({
    required String name,
    required String description,
  }) async {
    final projectModel = await _remoteDataSource.createProject(
      name: name,
      description: description,
    );
    return projectModel.toEntity();
  }

  @override
  Future<List<Project>> listProjects() async {
    final projectModels = await _remoteDataSource.listProjects();
    return projectModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Project> getProjectDetail(String projectId) async {
    final projectModel = await _remoteDataSource.getProjectDetail(projectId);
    return projectModel.toEntity();
  }

  @override
  Future<Project> updateProject({
    required String projectId,
    required String name,
    required String description,
    required String status,
  }) async {
    final projectModel = await _remoteDataSource.updateProject(
      projectId: projectId,
      name: name,
      description: description,
      status: status,
    );
    return projectModel.toEntity();
  }

  @override
  Future<void> deleteProject(String projectId) async {
    await _remoteDataSource.deleteProject(projectId);
  }

  @override
  Future<AdminModel> createAdmin({
    required String projectId,
    required String email,
    required String firstName,
    required String lastName,
    required String password,
  }) async {
    return await _remoteDataSource.createAdmin(
      projectId: projectId,
      email: email,
      firstName: firstName,
      lastName: lastName,
      password: password,
    );
  }

  @override
  Future<AdminModel> assignAdmin({
    required String projectId,
    required String adminId,
  }) async {
    return await _remoteDataSource.assignAdmin(
      projectId: projectId,
      adminId: adminId,
    );
  }
}
