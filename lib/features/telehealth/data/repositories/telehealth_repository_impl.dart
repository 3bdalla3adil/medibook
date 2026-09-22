import 'package:dio/dio.dart';

import '../../../../core/error/result.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/telehealth_session.dart';
import '../../domain/repositories/telehealth_repository.dart';

class DioTelehealthRepository implements TelehealthRepository {
  DioTelehealthRepository(this._dio);
  final Dio _dio;

  @override
  Future<Result<TelehealthSession>> createSession(String appointmentId) async {
    final result = await guard(() => _dio.post<Map<String, dynamic>>(
          ApiEndpoints.telehealthSession,
          data: {'appointment_id': appointmentId},
          options: Options(
            headers: {'Idempotency-Key': 'telehealth:$appointmentId'},
            extra: {'idempotent': true},
          ),
        ));

    return result.map((res) {
      final d = res.data!['data'] as Map<String, dynamic>;
      return TelehealthSession(
        id: d['id'].toString(),
        appointmentId: appointmentId,
        provider: d['provider'] as String,
        joinToken: d['join_token'] as String,
        expiresAt: DateTime.parse(d['expires_at'] as String).toUtc(),
        roomUrl: d['room_url'] as String?,
        roomId: d['room_id'] as String?,
        hostUserId: d['host_user_id']?.toString(),
      );
    });
  }

  @override
  Future<Result<String>> refreshJoinToken(String sessionId) async {
    final result = await guard(() => _dio.post<Map<String, dynamic>>(
          ApiEndpoints.telehealthJoin(sessionId),
        ));
    return result.map((res) => res.data!['data']['join_token'] as String);
  }

  @override
  Future<Result<void>> markJoined(String sessionId) =>
      guard(() => _dio.post<void>('${ApiEndpoints.telehealthSession}/$sessionId/joined'));

  @override
  Future<Result<void>> endSession(String sessionId) =>
      guard(() => _dio.post<void>('${ApiEndpoints.telehealthSession}/$sessionId/end'));
}
