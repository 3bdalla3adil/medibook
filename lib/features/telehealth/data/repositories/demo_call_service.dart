import 'dart:async';

import '../../domain/entities/telehealth_session.dart';
import '../../domain/repositories/daily_call_service.dart';

/// Local telehealth simulation for the demo environment.
/// No camera, microphone, network, or provider SDK is contacted.
class DemoCallService implements DailyCallService {
  final _states = StreamController<TelehealthConnectionState>.broadcast();
  bool _joined = false;

  @override
  Future<void> initialize() async {
    if (!_states.isClosed) {
      _states.add(TelehealthConnectionState.disconnected);
    }
  }

  @override
  Future<void> join(TelehealthSession session) async {
    _joined = true;
    _states.add(TelehealthConnectionState.connecting);
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (!_states.isClosed) {
      _states.add(TelehealthConnectionState.connected);
    }
  }

  @override
  Future<void> leave() async {
    if (!_joined) return;
    _joined = false;
    if (!_states.isClosed) {
      _states.add(TelehealthConnectionState.disconnected);
    }
  }

  @override
  Future<void> dispose() async {
    await _states.close();
  }

  @override
  Stream<TelehealthConnectionState> get connectionStates => _states.stream;
}
