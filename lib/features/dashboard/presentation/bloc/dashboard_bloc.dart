import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/result.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/security/secure_logger.dart';
import '../../../../core/utils/clock.dart';
import '../../../appointments/domain/entities/appointment.dart';
import '../../../appointments/domain/repositories/appointment_repository.dart';
import '../../../appointments/domain/usecases/get_appointments.dart';
import '../../../appointments/domain/usecases/get_upcoming_appointment.dart';
import '../../../patients/domain/entities/patient_profile.dart';
import '../../../patients/domain/usecases/get_patient_profile.dart';
import 'dashboard_state.dart';

sealed class DashboardEvent extends Equatable {
  const DashboardEvent();
  @override
  List<Object?> get props => const [];
}

final class DashboardStarted extends DashboardEvent {
  const DashboardStarted();
}

final class DashboardRefreshed extends DashboardEvent {
  const DashboardRefreshed();
}

final class DashboardConnectivityChanged extends DashboardEvent {
  const DashboardConnectivityChanged(this.isOnline);
  final bool isOnline;
  @override
  List<Object?> get props => [isOnline];
}

/// Internal — fired when the appointment repository's cache stream emits.
/// Routing through an event keeps `emit` inside a proper Bloc handler,
/// which is what the analyzer requires.
final class _AppointmentsCacheChanged extends DashboardEvent {
  const _AppointmentsCacheChanged(this.appointments);
  final List<Appointment> appointments;
  @override
  List<Object?> get props => [appointments];
}

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc({
    required GetPatientProfileUseCase getProfile,
    required GetAppointmentsUseCase getAppointments,
    required GetUpcomingAppointmentUseCase getUpcoming,
    required AppointmentRepository appointmentRepository,
    required NetworkInfo networkInfo,
    required Clock clock,
  })  : _getProfile = getProfile,
        _getAppointments = getAppointments,
        _getUpcoming = getUpcoming,
        _appointmentsRepo = appointmentRepository,
        _network = networkInfo,
        _clock = clock,
        super(const DashboardState()) {
    on<DashboardStarted>(_onStarted);
    on<DashboardRefreshed>(_onRefreshed);
    on<DashboardConnectivityChanged>(_onConnectivity);
    on<_AppointmentsCacheChanged>(_onCacheChanged);

    _appointmentsSub = _appointmentsRepo
        .watchAppointments()
        .listen(_onAppointmentsChanged);
  }

  final GetPatientProfileUseCase _getProfile;
  final GetAppointmentsUseCase _getAppointments;
  final GetUpcomingAppointmentUseCase _getUpcoming;
  final AppointmentRepository _appointmentsRepo;
  final NetworkInfo _network;
  final Clock _clock;

  final _log = SecureLogger('DashboardBloc');
  StreamSubscription<List<Appointment>>? _appointmentsSub;
  StreamSubscription<bool>? _connectivitySub;

  Future<void> _onStarted(DashboardStarted event, Emitter<DashboardState> emit) async {
    emit(state.copyWith(status: DashboardStatus.loading, clearFailure: true));

    _connectivitySub ??= _network.onStatusChange.listen(
      (online) => add(DashboardConnectivityChanged(online)),
    );

    await _load(emit, isRefresh: false);
  }

  Future<void> _onRefreshed(DashboardRefreshed event, Emitter<DashboardState> emit) async {
    if (state.isRefreshing) return;
    emit(state.copyWith(isRefreshing: true, clearFailure: true));
    await _load(emit, isRefresh: true);
  }

  Future<void> _onConnectivity(
    DashboardConnectivityChanged event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(isOffline: !event.isOnline));
    if (event.isOnline && state.status == DashboardStatus.error) {
      await _load(emit, isRefresh: true);
    }
  }

  Future<void> _load(Emitter<DashboardState> emit, {required bool isRefresh}) async {
    final online = await _network.isOnline();

    final results = await Future.wait<Object>([
      _getProfile(),
      _getAppointments(forceRefresh: isRefresh),
      _getUpcoming(),
    ]);

    final profileResult = results[0] as Result<PatientProfile?>;
    final listResult = results[1] as Result<List<Appointment>>;
    final upcomingResult = results[2] as Result<Appointment?>;

    if (profileResult case Err(:final failure)) {
      if (!state.hasData) {
        emit(state.copyWith(
          status: DashboardStatus.error,
          failure: failure,
          isOffline: !online,
          isRefreshing: false,
        ));
        return;
      }
      _log.warn('Profile refresh failed, showing cached dashboard');
    }

    final appointments = listResult.valueOrNull ?? state.appointments;
    final upcoming = upcomingResult.valueOrNull;
    final profile = profileResult.valueOrNull ?? state.profile;

    final failure = listResult.failureOrNull;
    final shouldShowError = failure != null && appointments.isEmpty;

    emit(state.copyWith(
      status: shouldShowError ? DashboardStatus.error : DashboardStatus.ready,
      profile: profile,
      appointments: appointments,
      upcomingAppointment: upcoming,
      clearUpcoming: upcoming == null,
      failure: shouldShowError ? failure : null,
      clearFailure: !shouldShowError,
      isOffline: !online,
      isRefreshing: false,
      lastSyncedAt: online ? _clock.now() : state.lastSyncedAt,
    ));
  }

  void _onAppointmentsChanged(List<Appointment> appointments) {
    if (isClosed) return;
    add(_AppointmentsCacheChanged(appointments));
  }

  void _onCacheChanged(
    _AppointmentsCacheChanged event,
    Emitter<DashboardState> emit,
  ) {
    emit(state.copyWith(
      appointments: event.appointments,
      status: DashboardStatus.ready,
    ));
  }

  @override
  Future<void> close() async {
    await _appointmentsSub?.cancel();
    await _connectivitySub?.cancel();
    return super.close();
  }
}
