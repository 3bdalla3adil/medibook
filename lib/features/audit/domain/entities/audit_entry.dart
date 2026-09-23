import 'package:equatable/equatable.dart';

class AuditEntry extends Equatable {
  const AuditEntry({required this.id, required this.action, required this.entityType, required this.entityId, required this.occurredAt, required this.outcome, this.actorLabel, this.correlationId});
  final String id; final String action; final String entityType; final String entityId; final DateTime occurredAt; final String outcome; final String? actorLabel; final String? correlationId;
  @override List<Object?> get props => [id, action, entityType, entityId, occurredAt, outcome, actorLabel, correlationId];
}
