import '../../../../core/error/result.dart';
import '../entities/telehealth_session.dart';

abstract interface class TelehealthRepository {
  Future<Result<TelehealthSession>> createSession(String appointmentId);
  Future<Result<String>> refreshJoinToken(String sessionId);
  Future<Result<void>> markJoined(String sessionId);
  Future<Result<void>> endSession(String sessionId);
}
