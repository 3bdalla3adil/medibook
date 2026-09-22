import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/sync/sync_status.dart';
import '../../../appointments/domain/entities/appointment.dart';
import '../../../patients/domain/entities/patient_profile.dart';

enum DashboardStatus { initial, loading, ready, error }

class DashboardState extends Equatable {
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.profile,
    this.upcomingAppointment,
    this.appointments = const [],
    this.failure,
    this.isOffline = false,
    this.isRefreshing = false,
    this.pendingSyncCount = 0,
    this.lastSyncedAt,
  });

  final DashboardStatus status;
  final PatientProfile? profile;
  final Appointment? upcomingAppointment;
  final List<Appointment> appointments;
  final Failure? failure;
  final bool isOffline;
  final bool isRefreshing;
  final int pendingSyncCount;
  final DateTime? lastSyncedAt;

  bool get hasData => profile != null || appointments.isNotEmpty;
  bool get isEmpty =>
      status == DashboardStatus.ready &&
      appointments.isEmpty &&
      upcomingAppointment == null;

  bool get showFullScreenError =>
      status == DashboardStatus.error && !hasData;

  int get pendingCount =>
      appointments.where((a) => a.syncStatus == SyncStatus.pending).length;

  DashboardState copyWith({
    DashboardStatus? status,
    PatientProfile? profile,
    Appointment? upcomingAppointment,
    bool clearUpcoming = false,
    List<Appointment>? appointments,
    Failure? failure,
    bool clearFailure = false,
    bool? isOffline,
    bool? isRefreshing,
    int? pendingSyncCount,
    DateTime? lastSyncedAt,
  }) =>
      DashboardState(
        status: status ?? this.status,
        profile: profile ?? this.profile,
        upcomingAppointment:
            clearUpcoming ? null : (upcomingAppointment ?? this.upcomingAppointment),
        appointments: appointments ?? this.appointments,
        failure: clearFailure ? null : (failure ?? this.failure),
        isOffline: isOffline ?? this.isOffline,
        isRefreshing: isRefreshing ?? this.isRefreshing,
        pendingSyncCount: pendingSyncCount ?? this.pendingSyncCount,
        lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      );

  @override
  List<Object?> get props => [
        status, profile, upcomingAppointment, appointments, failure,
        isOffline, isRefreshing, pendingSyncCount, lastSyncedAt,
      ];
}
