import 'package:equatable/equatable.dart';

enum TelehealthConnectionState {
  idle,
  connecting,
  connected,
  reconnecting,
  ended,
  failed,
}

class TelehealthSession extends Equatable {
  const TelehealthSession({
    required this.id,
    required this.appointmentId,
    required this.provider,
    required this.joinToken,
    required this.expiresAt,
    this.roomUrl,
    this.roomId,
    this.hostUserId,
  });

  final String id;
  final String appointmentId;
  final String provider;
  final String joinToken;
  final DateTime expiresAt;
  final String? roomUrl;
  final String? roomId;
  final String? hostUserId;

  bool isExpired(DateTime now) => now.isAfter(expiresAt);

  @override
  List<Object?> get props => [id, appointmentId, provider, expiresAt];
}
