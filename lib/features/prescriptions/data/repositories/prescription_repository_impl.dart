import '../../../../core/error/result.dart';
import '../../domain/entities/prescription.dart';
import '../../domain/repositories/prescription_repository.dart';
import '../datasources/prescription_remote_data_source.dart';

class PrescriptionRepositoryImpl implements PrescriptionRepository {
  const PrescriptionRepositoryImpl(this._remote);
  final PrescriptionRemoteDataSource _remote;

  @override
  Future<Result<List<Prescription>>> getPrescriptions() async {
    final result = await guard(_remote.fetchPrescriptions);
    return result.map((items) => items.map((e) => e.toDomain()).toList(growable: false));
  }
}
