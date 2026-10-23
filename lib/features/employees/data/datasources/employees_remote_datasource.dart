import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/employee_model.dart';

abstract class EmployeesRemoteDataSource {
  /// Get list of all employees
  Future<List<EmployeeModel>> listEmployees();
}

class EmployeesRemoteDataSourceImpl implements EmployeesRemoteDataSource {
  @override
  Future<List<EmployeeModel>> listEmployees() async {
    try {
      final response = await ApiClient.get(ApiEndpoints.employeesEndpoint);

      if (response.statusCode == 200) {
        final data = response.data;
        List<EmployeeModel> employees = [];

        print('[EMPLOYEES] Raw response data: $data');

        if (data is List) {
          print('[EMPLOYEES] Response is List with ${data.length} items');
          employees = data
              .map((item) => EmployeeModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (data is Map && data.containsKey('results')) {
          final results = data['results'] as List;
          print('[EMPLOYEES] Response is Map with results key, ${results.length} items');
          employees = results
              .map((item) => EmployeeModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }

        print('[EMPLOYEES] Total employees: ${employees.length}');
        return employees;
      } else {
        throw Exception('Failed to fetch employees');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ??
          e.response?.data['error'] ??
          'Failed to fetch employees';
      throw Exception(message);
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }
}
