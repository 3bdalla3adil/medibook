import '../../../../core/error/result.dart';
import '../entities/medication.dart';
abstract interface class MedicationRepository { Future<Result<List<PatientMedication>>> getPatientMedications(); Future<Result<void>> logDoseTaken(String id); Future<Result<void>> logDoseSkipped(String id); }
