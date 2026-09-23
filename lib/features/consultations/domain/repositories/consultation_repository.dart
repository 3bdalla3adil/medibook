import '../../../../core/error/result.dart';
import '../entities/consultation.dart';

abstract interface class ConsultationRepository {
  Future<Result<List<Consultation>>> getConsultations();
  Future<Result<Consultation?>> getConsultation(String id);
  Future<Result<Consultation>> startConsultation(String appointmentId);
  Future<Result<Consultation>> completeConsultation(String id);
}
