import '../../../../core/error/result.dart';
import '../entities/doctor.dart';

abstract interface class DoctorRepository {
  Future<Result<List<Doctor>>> getDoctors({String? clinicId, String? serviceId});
  Future<Result<Doctor?>> getDoctor(String id);
  Future<Result<List<Map<String, dynamic>>>> getAvailability({
    required String doctorId,
    required DateTime from,
    required DateTime to,
    String? clinicId,
    String? serviceId,
  });
}
