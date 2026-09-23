import '../../../../core/error/result.dart';
import '../../domain/entities/telehealth_session.dart';
import '../../domain/repositories/telehealth_repository.dart';
class DemoTelehealthRepository implements TelehealthRepository {
  const DemoTelehealthRepository();

  @override
  Future<Result<TelehealthSession>> createSession(String appointmentId) async =>
      Ok(
        TelehealthSession(
          id: 'demo-session-$appointmentId',
          appointmentId: appointmentId,
          provider: 'demo',
          joinToken: 'demo-join-token',
          expiresAt: DateTime.utc(2026, 12, 31, 23, 59),
          roomUrl: 'https://demo.medibook.app/room/$appointmentId',
          roomId: 'demo-room-$appointmentId',
          hostUserId: 'demo-doctor-001',
        ),
      );

  @override
  Future<Result<String>> refreshJoinToken(String sessionId) async =>
      const Ok('demo-join-token');

  @override
  Future<Result<void>> markJoined(String sessionId) async => const Ok(null);

  @override
  Future<Result<void>> endSession(String sessionId) async => const Ok(null);
}
