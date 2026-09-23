import '../../../../core/error/result.dart';
import '../entities/medical_service.dart';

abstract interface class ServiceRepository {
  Future<Result<List<MedicalService>>> getServices({String? clinicId});
  Future<Result<MedicalService?>> getService(String id);
}
