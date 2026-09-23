import 'package:equatable/equatable.dart';

import '../../../../core/error/result.dart';
import '../repositories/doctor_repository.dart';

class DoctorScheduleSlot extends Equatable {
  const DoctorScheduleSlot({
    required this.start,
    required this.end,
    required this.isAvailable,
    this.reason,
  });

  final DateTime start;
  final DateTime end;
  final bool isAvailable;
  final String? reason;

  @override
  List<Object?> get props => [start, end, isAvailable, reason];
}

class GetDoctorScheduleUseCase {
  const GetDoctorScheduleUseCase(this._repository);
  final DoctorRepository _repository;

  Future<Result<List<DoctorScheduleSlot>>> call({
    required String doctorId,
    required DateTime from,
    required DateTime to,
    String? clinicId,
    String? serviceId,
  }) async {
    // Availability is server-owned. Never calculate or infer slots on the client.
    final result = await _repository.getAvailability(
      doctorId: doctorId,
      from: from,
      to: to,
      clinicId: clinicId,
      serviceId: serviceId,
    );
    return result.map(
      (items) => items.map((item) {
        return DoctorScheduleSlot(
          start: DateTime.parse(item['start'].toString()).toUtc(),
          end: DateTime.parse(item['end'].toString()).toUtc(),
          isAvailable: item['is_available'] as bool? ?? false,
          reason: item['reason']?.toString(),
        );
      }).toList(growable: false),
    );
  }
}
