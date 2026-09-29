import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/availability_slot.dart';
import '../../domain/usecases/get_doctor_availability.dart';

part 'doctor_availability_event.dart';
part 'doctor_availability_state.dart';

class DoctorAvailabilityBloc
    extends Bloc<DoctorAvailabilityEvent, DoctorAvailabilityState> {
  DoctorAvailabilityBloc({
    required GetDoctorAvailabilityUseCase getAvailability,
  })  : _getAvailability = getAvailability,
        super(const DoctorAvailabilityState()) {
    on<DoctorAvailabilityRequested>(_onRequested);
    on<DoctorAvailabilityDateChanged>(_onDateChanged);
  }

  final GetDoctorAvailabilityUseCase _getAvailability;

  Future<void> _onRequested(
    DoctorAvailabilityRequested event,
    Emitter<DoctorAvailabilityState> emit,
  ) async {
    emit(state.copyWith(
      status: DoctorAvailabilityStatus.loading,
      doctorId: event.doctorId,
      clinicId: event.clinicId,
      serviceId: event.serviceId,
      selectedDate: event.date,
      clearFailure: true,
    ));

    final result = await _getAvailability(
      doctorId: event.doctorId,
      clinicId: event.clinicId,
      serviceId: event.serviceId,
      from: DateTime.utc(event.date.year, event.date.month, event.date.day),
      to: DateTime.utc(event.date.year, event.date.month, event.date.day)
          .add(const Duration(days: 1)),
    );

    switch (result) {
      case Ok(value: final slots):
        emit(state.copyWith(
          status: DoctorAvailabilityStatus.ready,
          slots: slots,
        ));
      case Err(:final failure):
        emit(state.copyWith(
          status: DoctorAvailabilityStatus.error,
          failure: failure,
        ));
    }
  }

  Future<void> _onDateChanged(
    DoctorAvailabilityDateChanged event,
    Emitter<DoctorAvailabilityState> emit,
  ) async {
    if (state.doctorId == null ||
        state.clinicId == null ||
        state.serviceId == null) {
      return;
    }
    add(DoctorAvailabilityRequested(
      doctorId: state.doctorId!,
      clinicId: state.clinicId!,
      serviceId: state.serviceId!,
      date: event.date,
    ));
  }
}
