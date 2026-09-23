import '../../../../core/error/result.dart';
import '../entities/clinic.dart';

abstract interface class ClinicRepository {
  Future<Result<List<Clinic>>> getClinics({bool activeOnly = true});
  Future<Result<Clinic?>> getClinic(String id);
  Future<Result<List<Map<String, dynamic>>>> getClinicServices(String id);
}
