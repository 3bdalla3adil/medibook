import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/usecases/get_doctors.dart';

enum DoctorListStatus { initial, loading, ready, error }

class DoctorListState extends Equatable {
  const DoctorListState({
    this.status = DoctorListStatus.initial,
    this.items = const [],
    this.failure,
  });
  final DoctorListStatus status;
  final List<Doctor> items;
  final Failure? failure;
  @override
  List<Object?> get props => [status, items, failure];
}

class DoctorListCubit extends Cubit<DoctorListState> {
  DoctorListCubit(this._getDoctors) : super(const DoctorListState());
  final GetDoctorsUseCase _getDoctors;

  Future<void> load() async {
    emit(DoctorListState(status: DoctorListStatus.loading, items: state.items));
    final result = await _getDoctors();
    switch (result) {
      case Ok(value: final items):
        emit(DoctorListState(status: DoctorListStatus.ready, items: items));
      case Err(:final failure):
        emit(
          DoctorListState(
          status: DoctorListStatus.error,
          items: state.items,
          failure: failure,
        ));
    }
  }
}
