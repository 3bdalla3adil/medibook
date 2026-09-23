import '../../../../core/error/result.dart';
import '../entities/consultation.dart';
import '../repositories/consultation_repository.dart';

class GetConsultationsUseCase {
  const GetConsultationsUseCase(this._repository);
  final ConsultationRepository _repository;
  Future<Result<List<Consultation>>> call() => _repository.getConsultations();
}
