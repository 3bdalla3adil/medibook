import '../entities/telehealth_session.dart';

abstract interface class DailyCallService {
  Future<void> initialize();
  Future<void> join(TelehealthSession session);
  Future<void> leave();
  Future<void> dispose();
  Stream<TelehealthConnectionState> get connectionStates;
}
