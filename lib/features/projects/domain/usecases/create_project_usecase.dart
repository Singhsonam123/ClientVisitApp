import '../entities/project.dart';
import '../repositories/projects_repository.dart';

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
