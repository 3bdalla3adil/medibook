import 'dart:convert';

import 'package:equatable/equatable.dart';

enum OutboxOp { create, update, delete }

class OutboxEntry extends Equatable {
  const OutboxEntry({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.op,
    required this.payload,
    required this.createdAt,
    this.attempts = 0,
    this.nextAttemptAt,
    this.lastErrorCode,
    this.localVersion,
  });

  final String id;
  final String entityType;
  final String entityId;
  final OutboxOp op;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int attempts;
  final DateTime? nextAttemptAt;
  final String? lastErrorCode;
  final int? localVersion;

  Map<String, dynamic> toJson() => {
        'id': id,
        'entity_type': entityType,
        'entity_id': entityId,
        'op': op.name,
        'payload': payload,
        'created_at': createdAt.toUtc().toIso8601String(),
        'attempts': attempts,
        'next_attempt_at': nextAttemptAt?.toUtc().toIso8601String(),
        'last_error_code': lastErrorCode,
        'local_version': localVersion,
      };

  static OutboxEntry fromJson(Map<String, dynamic> j) => OutboxEntry(
        id: j['id'] as String,
        entityType: j['entity_type'] as String,
        entityId: j['entity_id'] as String,
        op: OutboxOp.values.byName(j['op'] as String),
        payload: Map<String, dynamic>.from(j['payload'] as Map),
        createdAt: DateTime.parse(j['created_at'] as String),
        attempts: (j['attempts'] as num?)?.toInt() ?? 0,
        nextAttemptAt: j['next_attempt_at'] == null
            ? null
            : DateTime.parse(j['next_attempt_at'] as String),
        lastErrorCode: j['last_error_code'] as String?,
        localVersion: (j['local_version'] as num?)?.toInt(),
      );

  OutboxEntry copyWith({
    int? attempts,
    DateTime? nextAttemptAt,
    String? lastErrorCode,
    bool clearNextAttempt = false,
  }) =>
      OutboxEntry(
        id: id,
        entityType: entityType,
        entityId: entityId,
        op: op,
        payload: payload,
        createdAt: createdAt,
        attempts: attempts ?? this.attempts,
        nextAttemptAt: clearNextAttempt ? null : (nextAttemptAt ?? this.nextAttemptAt),
        lastErrorCode: lastErrorCode ?? this.lastErrorCode,
        localVersion: localVersion,
      );

  String encode() => jsonEncode(toJson());

  @override
  List<Object?> get props => [id, entityType, entityId, op, attempts];
}
