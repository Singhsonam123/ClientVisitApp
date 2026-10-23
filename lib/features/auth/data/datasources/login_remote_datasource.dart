import 'package:dio/dio.dart';
import '../models/login_response_model.dart';
import '../../../../core/constants/api_endpoints.dart';

/// Abstract data source for remote login operations
abstract class LoginRemoteDataSource {
  /// Calls POST /api/auth/login/ endpoint
  /// Returns [LoginResponseModel] on success
  /// Throws [DioException] on failure
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  });
}

/// Implementation of [LoginRemoteDataSource]
class LoginRemoteDataSourceImpl implements LoginRemoteDataSource {
  final Dio dio;

  LoginRemoteDataSourceImpl(this.dio);

  @override
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.loginEndpoint,
        data: {
          'email': email.trim().toLowerCase(),
          'password': password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return LoginResponseModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Login failed with status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      // Handle server errors (5xx) with better error messages
      if (e.response?.statusCode != null && e.response!.statusCode! >= 500) {
        throw DioException(
          requestOptions: e.requestOptions,
          response: e.response,
          type: e.type,
          error: 'Server error: Please try again later',
        );
      }
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/auth/login/'),
        type: DioExceptionType.unknown,
        error: e.toString(),
      );
    }
  }
}
