part of 'doctor_availability_bloc.dart';

enum DoctorAvailabilityStatus { idle, loading, ready, error }

class DoctorAvailabilityState extends Equatable {
  const DoctorAvailabilityState({
    this.status = DoctorAvailabilityStatus.idle,
    this.doctorId,
    this.clinicId,
    this.serviceId,
    this.selectedDate,
    this.slots = const [],
    this.failure,
  });

  final DoctorAvailabilityStatus status;
  final String? doctorId;
  final String? clinicId;
  final String? serviceId;
  final DateTime? selectedDate;
  final List<AvailabilitySlot> slots;
  final Failure? failure;

  List<AvailabilitySlot> get bookableSlots =>
      slots.where((s) => s.isBookable).toList(growable: false);

  bool get isEmpty =>
      status == DoctorAvailabilityStatus.ready && slots.isEmpty;

  DoctorAvailabilityState copyWith({
    DoctorAvailabilityStatus? status,
    String? doctorId,
    String? clinicId,
    String? serviceId,
    DateTime? selectedDate,
    List<AvailabilitySlot>? slots,
    Failure? failure,
    bool clearFailure = false,
  }) =>
      DoctorAvailabilityState(
        status: status ?? this.status,
        doctorId: doctorId ?? this.doctorId,
        clinicId: clinicId ?? this.clinicId,
        serviceId: serviceId ?? this.serviceId,
        selectedDate: selectedDate ?? this.selectedDate,
        slots: slots ?? this.slots,
        failure: clearFailure ? null : (failure ?? this.failure),
      );

  @override
  List<Object?> get props =>
      [status, doctorId, clinicId, serviceId, selectedDate, slots, failure];
}
