import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/data/datasources/login_remote_datasource.dart';
import '../../features/auth/data/datasources/logout_remote_datasource.dart';
import '../../features/auth/data/repositories/login_repository_impl.dart';
import '../../features/auth/data/repositories/logout_repository_impl.dart';
import '../../features/auth/domain/repositories/login_repository.dart';
import '../../features/auth/domain/repositories/logout_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../network/api_client.dart';

/// Service Locator for dependency injection
/// Initialize this in main() before running the app
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();

  factory ServiceLocator() {
    return _instance;
  }

  ServiceLocator._internal();

  /// Initialize all dependencies
  static Future<void> init() async {
    // Get SharedPreferences instance
    final prefs = await SharedPreferences.getInstance();

    // Register API Client (Dio)
    final dio = ApiClient.instance;

    // Register Data Sources
    _registerDataSources(dio);

    // Register Repositories
    _registerRepositories(prefs);

    // Register Use Cases
    _registerUseCases();
  }

  /// Register all data sources
  static void _registerDataSources(Dio dio) {
    _serviceLocator[LoginRemoteDataSource] = LoginRemoteDataSourceImpl(dio);
    _serviceLocator[LogoutRemoteDataSource] = LogoutRemoteDataSourceImpl(dio);
  }

  /// Register all repositories
  static void _registerRepositories(SharedPreferences prefs) {
    _serviceLocator[LoginRepository] = LoginRepositoryImpl(
      remoteDataSource: _serviceLocator[LoginRemoteDataSource]!,
      prefs: prefs,
    );
    _serviceLocator[LogoutRepository] = LogoutRepositoryImpl(
      remoteDataSource: _serviceLocator[LogoutRemoteDataSource]!,
      prefs: prefs,
    );
  }

  /// Register all use cases
  static void _registerUseCases() {
    _serviceLocator[LoginUseCase] = LoginUseCase(
      _serviceLocator[LoginRepository]!,
    );
    _serviceLocator[LogoutUseCase] = LogoutUseCase(
      _serviceLocator[LogoutRepository]!,
    );
  }

  // Simple service locator map
  static final Map<Type, dynamic> _serviceLocator = {};

  /// Get a registered service by type
  static T get<T>() {
    final service = _serviceLocator[T];
    if (service == null) {
      throw Exception('Service of type $T not found in ServiceLocator');
    }
    return service as T;
  }

  /// Register a service manually
  static void register<T>(T service) {
    _serviceLocator[T] = service;
  }
}
