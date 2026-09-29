import '../../../../core/error/result.dart';
import '../../domain/entities/availability_slot.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/entities/doctor_assignment.dart';
import '../../domain/repositories/doctor_repository.dart';
import '../datasources/doctor_remote_data_source.dart';

class DoctorRepositoryImpl implements DoctorRepository {
  DoctorRepositoryImpl({required DoctorRemoteDataSource remote})
      : _remote = remote;

  final DoctorRemoteDataSource _remote;

  @override
  Future<Result<List<Doctor>>> getDoctors({
    String? clinicId,
    String? serviceId,
  }) async {
    final result = await guard(() => _remote.fetchDoctors(
          clinicId: clinicId,
          serviceId: serviceId,
        ));

    return result.map((list) => list
        .map((json) => Doctor(
              id: json['id'].toString(),
              displayName: json['display_name'] as String? ?? '',
              specialization: json['specialization'] as String?,
              avatarUrl: json['avatar_url'] as String?,
              bio: json['bio'] as String?,
              languages: ((json['languages'] as List?) ?? const [])
                  .map((e) => e.toString())
                  .toSet(),
            ))
        .toList(growable: false));
  }

  @override
  Future<Result<Doctor?>> getDoctor(String id) async {
    final result = await guard(() => _remote.fetchDoctor(id));
    return result.map((json) {
      if (json == null) return null;
      return Doctor(
        id: json['id'].toString(),
        displayName: json['display_name'] as String? ?? '',
        specialization: json['specialization'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        bio: json['bio'] as String?,
      );
    });
  }

  @override
  Future<Result<List<DoctorAssignment>>> getAssignments(String doctorId) async {
    final result = await guard(() => _remote.fetchAssignments(doctorId));
    return result.map((dtos) =>
        dtos.map((dto) => dto.toDomain()).toList(growable: false));
  }

  @override
  Future<Result<List<AvailabilitySlot>>> getAvailability({
    required String doctorId,
    required String clinicId,
    required String serviceId,
    required DateTime from,
    required DateTime to,
  }) async {
    final result = await guard(() => _remote.fetchAvailability(
          doctorId: doctorId,
          clinicId: clinicId,
          serviceId: serviceId,
          from: from,
          to: to,
        ));
    return result.map((dtos) =>
        dtos.map((dto) => dto.toDomain()).toList(growable: false));
  }
}
