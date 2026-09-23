import 'dart:async';

import 'package:daily_flutter/daily_flutter.dart';

import '../../domain/entities/telehealth_session.dart';
import '../../domain/repositories/daily_call_service.dart';

class DailyCallServiceImpl implements DailyCallService {
  CallClient? _client;
  final StreamController<TelehealthConnectionState> _states =
      StreamController<TelehealthConnectionState>.broadcast();

  TelehealthConnectionState _state = TelehealthConnectionState.idle;

  @override
  Future<void> initialize() async {
    _client ??= await CallClient.create();
    _emit(TelehealthConnectionState.idle);
  }

  @override
  Future<void> join(TelehealthSession session) async {
    await initialize();
    final url = session.roomUrl;
    if (url == null || url.isEmpty) {
      throw StateError('daily_room_url_missing');
    }

    _emit(TelehealthConnectionState.connecting);
    try {
      await _client!.join(url: Uri.parse(url), token: session.joinToken);
      _emit(TelehealthConnectionState.connected);
    } catch (_) {
      _emit(TelehealthConnectionState.failed);
      rethrow;
    }
  }

  @override
  Future<void> leave() async {
    await _client?.leave();
    _emit(TelehealthConnectionState.ended);
  }

  @override
  Future<void> dispose() async {
    await _client?.dispose();
    _client = null;
    await _states.close();
  }

  @override
  Stream<TelehealthConnectionState> get connectionStates async* {
    yield _state;
    yield* _states.stream;
  }

  void _emit(TelehealthConnectionState state) {
    _state = state;
    if (!_states.isClosed) {
      _states.add(state);
    }
  }
}
