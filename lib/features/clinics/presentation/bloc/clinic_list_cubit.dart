import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/clinic.dart';
import '../../domain/usecases/get_clinics.dart';

enum ClinicListStatus { initial, loading, ready, error }

class ClinicListState extends Equatable {
  const ClinicListState({
    this.status = ClinicListStatus.initial,
    this.items = const [],
    this.failure,
  });

  final ClinicListStatus status;
  final List<Clinic> items;
  final Failure? failure;

  @override
  List<Object?> get props => [status, items, failure];
}

class ClinicListCubit extends Cubit<ClinicListState> {
  ClinicListCubit(this._getClinics) : super(const ClinicListState());

  final GetClinicsUseCase _getClinics;

  Future<void> load() async {
    emit(ClinicListState(status: ClinicListStatus.loading, items: state.items));
    final result = await _getClinics();
    switch (result) {
      case Ok(value: final items):
        emit(ClinicListState(status: ClinicListStatus.ready, items: items));
      case Err(:final failure):
        emit(
          ClinicListState(
            status: ClinicListStatus.error,
            items: state.items,
            failure: failure,
          ),
        );
    }
  }
}
