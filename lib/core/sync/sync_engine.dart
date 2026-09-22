import 'dart:async';

import '../error/failure.dart';
import '../error/result.dart';
import '../network/network_info.dart';
import '../security/secure_logger.dart';
import '../storage/boxes.dart';
import '../storage/local_store.dart';
import '../utils/clock.dart';
import 'backoff.dart';
import 'outbox.dart';

abstract interface class OutboxHandler {
  String get entityType;
  Future<void> push(OutboxEntry entry);
}

class SyncEngine {
  SyncEngine({
    required LocalStore store,
    required NetworkInfo networkInfo,
    required Clock clock,
    int maxAttempts = 8,
  })  : _store = store,
        _network = networkInfo,
        _clock = clock,
        _maxAttempts = maxAttempts;

  final LocalStore _store;
  final NetworkInfo _network;
  final Clock _clock;
  final int _maxAttempts;
  final _log = SecureLogger('SyncEngine');

  final Map<String, OutboxHandler> _handlers = {};
  StreamSubscription<bool>? _connectivitySub;
  bool _draining = false;
  final _conflictController = StreamController<OutboxEntry>.broadcast();

  Stream<OutboxEntry> get conflicts => _conflictController.stream;

  void register(OutboxHandler handler) => _handlers[handler.entityType] = handler;

  Future<void> start() async {
    _connectivitySub = _network.onStatusChange.listen((online) {
      if (online) unawaited(drain());
    });
    if (await _network.isOnline()) unawaited(drain());
  }

  Future<void> dispose() async {
    await _connectivitySub?.cancel();
    await _conflictController.close();
  }

  Future<void> enqueue(OutboxEntry entry) async {
    await _store.write(Boxes.outbox, entry.id, entry.toJson());
    _log.info('Outbox enqueued', data: {
      'entity': entry.entityType,
      'op': entry.op.name,
    });
    if (await _network.isOnline()) unawaited(drain());
  }

  Future<void> drain() async {
    if (_draining) return;
    _draining = true;
    try {
      final raw = await _store.readAll<Map<String, dynamic>>(Boxes.outbox);
      final entries = raw.map(OutboxEntry.fromJson).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

      for (final entry in entries) {
        if (entry.nextAttemptAt != null &&
            _clock.now().isBefore(entry.nextAttemptAt!)) {
          continue;
        }

        final handler = _handlers[entry.entityType];
        if (handler == null) {
          _log.warn('No outbox handler', data: {'entity': entry.entityType});
          continue;
        }

        final result = await guard(() => handler.push(entry));

        switch (result) {
          case Ok():
            await _store.delete(Boxes.outbox, entry.id);
            _log.info('Outbox entry synced', data: {'entity': entry.entityType});
          case Err(:final failure):
            await _onFailure(entry, failure);
        }
      }
    } finally {
      _draining = false;
    }
  }

  Future<void> _onFailure(OutboxEntry entry, Failure failure) async {
    final permanent = failure is ConflictFailure ||
        failure is ValidationFailure ||
        failure is ForbiddenFailure ||
        failure is UnauthorizedFailure;

    final attempts = entry.attempts + 1;

    if (permanent || attempts >= _maxAttempts) {
      await _store.write(
        Boxes.outbox,
        entry.id,
        entry.copyWith(attempts: attempts, lastErrorCode: failure.code).toJson(),
      );
      if (failure is ConflictFailure) {
        _conflictController.add(entry.copyWith(lastErrorCode: failure.code));
      }
      _log.warn('Outbox entry parked', data: {
        'entity': entry.entityType,
        'code': failure.code,
        'permanent': permanent,
      });
      return;
    }

    final delay = Backoff.forAttempt(attempts);
    await _store.write(
      Boxes.outbox,
      entry.id,
      entry
          .copyWith(
            attempts: attempts,
            nextAttemptAt: _clock.now().add(delay),
            lastErrorCode: failure.code,
          )
          .toJson(),
    );
  }
}
