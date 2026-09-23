import 'package:dio/dio.dart';

import '../../../../core/error/result.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/telehealth_session.dart';
import '../../domain/repositories/telehealth_repository.dart';

class DailyTelehealthRepository implements TelehealthRepository {
  DailyTelehealthRepository(this._dio);
  final Dio _dio;

  @override
  Future<Result<TelehealthSession>> createSession(String appointmentId) async {
    final result = await guard(() => _dio.post<Map<String, dynamic>>(
      ApiEndpoints.telehealthSession,
      data: {'appointment_id': appointmentId, 'provider': 'daily'},
      options: Options(headers: {'Idempotency-Key': 'daily:$appointmentId'}, extra: {'idempotent': true}),
    ));
    return result.map((response) {
      final data = response.data!['data'] as Map<String, dynamic>;
      final expires = DateTime.parse(data['expires_at'].toString()).toUtc();
      if (expires.isAfter(DateTime.now().toUtc().add(const Duration(minutes: 15)))) {
        throw StateError('telehealth_token_expiration_exceeds_15_minutes');
      }
      return TelehealthSession(
        id: data['id'].toString(),
        appointmentId: appointmentId,
        provider: 'daily',
        joinToken: data['join_token'].toString(),
        expiresAt: expires,
        roomUrl: data['room_url']?.toString(),
        roomId: data['room_id']?.toString(),
        hostUserId: data['host_user_id']?.toString(),
      );
    });
  }

  @override
  Future<Result<String>> refreshJoinToken(String sessionId) async {
    final result = await guard(() => _dio.post<Map<String, dynamic>>(ApiEndpoints.telehealthJoin(sessionId)));
    return result.map((response) => response.data!['data']['join_token'].toString());
  }

  @override
  Future<Result<void>> markJoined(String sessionId) => guard(
    () => _dio.post<void>(ApiEndpoints.telehealthSession + '/' + sessionId + '/joined'),
  );

  @override
  Future<Result<void>> endSession(String sessionId) => guard(
    () => _dio.post<void>(ApiEndpoints.telehealthSession + '/' + sessionId + '/end'),
  );
}
