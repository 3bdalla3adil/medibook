import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/patient_summary.dart';
import '../../domain/usecases/get_patient_directory.dart';

enum PatientDirectoryStatus { initial, loading, ready, error }

class PatientDirectoryState extends Equatable {
  const PatientDirectoryState({
    this.status = PatientDirectoryStatus.initial,
    this.items = const [],
    this.failure,
  });
  final PatientDirectoryStatus status;
  final List<PatientSummary> items;
  final Failure? failure;
  @override
  List<Object?> get props => [status, items, failure];
}

class PatientDirectoryCubit extends Cubit<PatientDirectoryState> {
  PatientDirectoryCubit(this._getPatients) : super(const PatientDirectoryState());
  final GetPatientDirectoryUseCase _getPatients;

  Future<void> load() async {
    emit(PatientDirectoryState(status: PatientDirectoryStatus.loading, items: state.items));
    final result = await _getPatients();
    switch (result) {
      case Ok(value: final items):
        emit(PatientDirectoryState(status: PatientDirectoryStatus.ready, items: items));
      case Err(:final failure):
        emit(
          PatientDirectoryState(
            status: PatientDirectoryStatus.error,
            items: state.items,
            failure: failure,
          ),
        );
    }
  }
}
