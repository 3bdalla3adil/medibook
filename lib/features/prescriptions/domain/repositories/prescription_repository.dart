import '../../../../core/error/result.dart';
import '../entities/prescription.dart';

abstract interface class PrescriptionRepository {
  Future<Result<List<Prescription>>> getPrescriptions();
}
