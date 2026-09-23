import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/prescription.dart';
import '../../domain/usecases/get_prescriptions.dart';

enum PrescriptionListStatus { initial, loading, ready, error }

class PrescriptionListState extends Equatable {
  const PrescriptionListState({
    this.status = PrescriptionListStatus.initial,
    this.items = const [],
    this.failure,
  });
  final PrescriptionListStatus status;
  final List<Prescription> items;
  final Failure? failure;
  @override
  List<Object?> get props => [status, items, failure];
}

class PrescriptionListCubit extends Cubit<PrescriptionListState> {
  PrescriptionListCubit(this._getPrescriptions) : super(const PrescriptionListState());
  final GetPrescriptionsUseCase _getPrescriptions;

  Future<void> load() async {
    emit(PrescriptionListState(status: PrescriptionListStatus.loading, items: state.items));
    final result = await _getPrescriptions();
    switch (result) {
      case Ok(value: final items):
        emit(PrescriptionListState(status: PrescriptionListStatus.ready, items: items));
      case Err(:final failure):
        emit(
          PrescriptionListState(
          status: PrescriptionListStatus.error,
          items: state.items,
          failure: failure,
        ));
    }
  }
}
