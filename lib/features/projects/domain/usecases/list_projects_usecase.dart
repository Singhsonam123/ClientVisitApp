import '../entities/project.dart';
import '../repositories/projects_repository.dart';

class ListProjectsUseCase {
  final ProjectsRepository repository;

  ListProjectsUseCase(this.repository);

  Future<List<Project>> call() async {
    return await repository.listProjects();
  }
}
