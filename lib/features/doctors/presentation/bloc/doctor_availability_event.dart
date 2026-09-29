part of 'doctor_availability_bloc.dart';

sealed class DoctorAvailabilityEvent extends Equatable {
  const DoctorAvailabilityEvent();
  @override
  List<Object?> get props => const [];
}

final class DoctorAvailabilityRequested extends DoctorAvailabilityEvent {
  const DoctorAvailabilityRequested({
    required this.doctorId,
    required this.clinicId,
    required this.serviceId,
    required this.date,
  });

  final String doctorId;
  final String clinicId;
  final String serviceId;
  final DateTime date;

  @override
  List<Object?> get props => [doctorId, clinicId, serviceId, date];
}

final class DoctorAvailabilityDateChanged extends DoctorAvailabilityEvent {
  const DoctorAvailabilityDateChanged(this.date);
  final DateTime date;
  @override
  List<Object?> get props => [date];
}
