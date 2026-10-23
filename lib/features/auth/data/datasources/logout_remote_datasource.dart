import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';

/// Abstract data source for remote logout operations
abstract class LogoutRemoteDataSource {
  /// Calls POST /api/auth/logout/ endpoint
  /// Throws [DioException] on failure
  Future<void> logout();
}

/// Implementation of [LogoutRemoteDataSource]
class LogoutRemoteDataSourceImpl implements LogoutRemoteDataSource {
  final Dio dio;

  LogoutRemoteDataSourceImpl(this.dio);

  @override
  Future<void> logout() async {
    try {
      final response = await dio.post(ApiEndpoints.logoutEndpoint);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Logout failed with status code: ${response.statusCode}',
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiEndpoints.logoutEndpoint),
        type: DioExceptionType.unknown,
        error: e.toString(),
      );
    }
  }
}
