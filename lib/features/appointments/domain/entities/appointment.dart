import 'package:equatable/equatable.dart';

import '../../../../core/sync/sync_status.dart';
import 'appointment_status.dart';

class Appointment extends Equatable {
  const Appointment({
    required this.id,
    required this.clinicId,
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    required this.serviceId,
    required this.serviceName,
    required this.startsAt,
    required this.duration,
    required this.status,
    required this.isTelehealth,
    required this.createdAt,
    required this.updatedAt,
    this.clinicName,
    this.doctorAvatarUrl,
    this.roomLabel,
    this.cancellationReason,
    this.cancelledAt,
    this.notes,
    this.version,
    this.syncStatus = SyncStatus.synced,
  });

  final String id;
  final String clinicId;
  final String? clinicName;
  final String patientId;
  final String doctorId;
  final String doctorName;
  final String? doctorAvatarUrl;
  final String serviceId;
  final String serviceName;
  final DateTime startsAt;
  final Duration duration;
  final AppointmentStatus status;
  final bool isTelehealth;
  final String? roomLabel;
  final String? cancellationReason;
  final DateTime? cancelledAt;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? version;
  final SyncStatus syncStatus;

  DateTime get endsAt => startsAt.add(duration);

  bool isUpcoming(DateTime now) => status.isActive && startsAt.isAfter(now);

  bool isWithinJoinWindow(DateTime now, {Duration window = const Duration(minutes: 15)}) =>
      isTelehealth &&
      status.isJoinable &&
      now.isAfter(startsAt.subtract(window)) &&
      now.isBefore(endsAt);

  Appointment copyWith({
    AppointmentStatus? status,
    DateTime? startsAt,
    Duration? duration,
    String? cancellationReason,
    DateTime? cancelledAt,
    String? roomLabel,
    int? version,
    SyncStatus? syncStatus,
    DateTime? updatedAt,
  }) =>
      Appointment(
        id: id,
        clinicId: clinicId,
        clinicName: clinicName,
        patientId: patientId,
        doctorId: doctorId,
        doctorName: doctorName,
        doctorAvatarUrl: doctorAvatarUrl,
        serviceId: serviceId,
        serviceName: serviceName,
        startsAt: startsAt ?? this.startsAt,
        duration: duration ?? this.duration,
        status: status ?? this.status,
        isTelehealth: isTelehealth,
        roomLabel: roomLabel ?? this.roomLabel,
        cancellationReason: cancellationReason ?? this.cancellationReason,
        cancelledAt: cancelledAt ?? this.cancelledAt,
        notes: notes,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        version: version ?? this.version,
        syncStatus: syncStatus ?? this.syncStatus,
      );

  @override
  List<Object?> get props => [
        id, clinicId, patientId, doctorId, serviceId, startsAt, duration,
        status, isTelehealth, version, syncStatus, updatedAt,
      ];
}
