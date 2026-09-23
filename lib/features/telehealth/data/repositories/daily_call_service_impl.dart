import 'package:daily_flutter/daily_flutter.dart';

import '../../domain/entities/telehealth_session.dart';
import '../../domain/repositories/daily_call_service.dart';

class DailyCallServiceImpl implements DailyCallService {
  CallClient? _client;

  @override
  Future<void> initialize() async {
    _client ??= await CallClient.create();
  }

  @override
  Future<void> join(TelehealthSession session) async {
    await initialize();
    final url = session.roomUrl;
    if (url == null || url.isEmpty) {
      throw StateError('daily_room_url_missing');
    }
    await _client!.join(url: Uri.parse(url), token: session.joinToken);
  }

  @override
  Future<void> leave() async {
    await _client?.leave();
  }

  @override
  Future<void> dispose() async {
    await _client?.dispose();
    _client = null;
  }

  @override
  Stream<TelehealthConnectionState> get connectionStates async* {
    final client = _client;
    if (client == null) {
      yield TelehealthConnectionState.idle;
      return;
    }
    await for (final event in client.events) {
      yield event.map(
        callStateUpdated: (e) => switch (e.stateData.state) {
          CallState.initialized => TelehealthConnectionState.idle,
          CallState.joining => TelehealthConnectionState.connecting,
          CallState.joined => TelehealthConnectionState.connected,
          CallState.leaving => TelehealthConnectionState.ended,
          CallState.left => TelehealthConnectionState.ended,
        },
        error: (_) => TelehealthConnectionState.failed,
        orElse: () => TelehealthConnectionState.connected,
      );
    }
  }
}
