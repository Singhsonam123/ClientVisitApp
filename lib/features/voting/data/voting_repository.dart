import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class VotingRepository {
  final Dio _dio = ApiClient.instance;

  /// Returns a map of { candidateId → voteCount } from the server.
  Future<Map<String, int>> fetchVoteCounts() async {
    final response = await _dio.get('/api/votes');
    final raw = response.data['voteCounts'] as Map<String, dynamic>? ?? {};
    return raw.map((k, v) => MapEntry(k, (v as num).toInt()));
  }

  /// Returns the candidateId the [employeeId] already voted for, or null.
  Future<String?> checkVote(String employeeId) async {
    final response = await _dio.get('/api/votes/check/$employeeId');
    return response.data['votedFor'] as String?;
  }

  /// Cast a vote for [candidateId] by [employeeId].
  /// Returns updated { candidateId → voteCount } map.
  /// Throws [DioException] with statusCode 409 if already voted.
  Future<Map<String, int>> castVote({
    required String employeeId,
    required String candidateId,
  }) async {
    final response = await _dio.post(
      '/api/votes/cast',
      data: {'employeeId': employeeId, 'candidateId': candidateId},
    );
    final raw = response.data['voteCounts'] as Map<String, dynamic>? ?? {};
    return raw.map((k, v) => MapEntry(k, (v as num).toInt()));
  }
}