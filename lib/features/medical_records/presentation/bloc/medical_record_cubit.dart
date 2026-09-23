import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/medical_record.dart';
import '../../domain/usecases/get_medical_record.dart';

enum MedicalRecordStatus { initial, loading, ready, error }

class MedicalRecordState extends Equatable {
  const MedicalRecordState({
    this.status = MedicalRecordStatus.initial,
    this.entries = const [],
    this.failure,
  });
  final MedicalRecordStatus status;
  final List<MedicalRecordEntry> entries;
  final Failure? failure;
  @override
  List<Object?> get props => [status, entries, failure];
}

class MedicalRecordCubit extends Cubit<MedicalRecordState> {
  MedicalRecordCubit(this._getRecord) : super(const MedicalRecordState());
  final GetMedicalRecordUseCase _getRecord;

  Future<void> load(String patientId) async {
    emit(MedicalRecordState(status: MedicalRecordStatus.loading, entries: state.entries));
    final result = await _getRecord(patientId);
    switch (result) {
      case Ok(value: final entries):
        emit(MedicalRecordState(status: MedicalRecordStatus.ready, entries: entries));
      case Err(:final failure):
        emit(
          MedicalRecordState(
            status: MedicalRecordStatus.error,
            entries: state.entries,
            failure: failure,
          ),
        );
    }
  }
}
