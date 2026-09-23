import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/consultation.dart';
import '../../domain/usecases/get_consultations.dart';

enum ConsultationListStatus { initial, loading, ready, error }

class ConsultationListState extends Equatable {
  const ConsultationListState({
    this.status = ConsultationListStatus.initial,
    this.items = const [],
    this.failure,
  });
  final ConsultationListStatus status;
  final List<Consultation> items;
  final Failure? failure;
  @override
  List<Object?> get props => [status, items, failure];
}

class ConsultationListCubit extends Cubit<ConsultationListState> {
  ConsultationListCubit(this._getConsultations) : super(const ConsultationListState());
  final GetConsultationsUseCase _getConsultations;

  Future<void> load() async {
    emit(ConsultationListState(status: ConsultationListStatus.loading, items: state.items));
    final result = await _getConsultations();
    switch (result) {
      case Ok(value: final items):
        emit(ConsultationListState(status: ConsultationListStatus.ready, items: items));
      case Err(:final failure):
        emit(
          ConsultationListState(
          status: ConsultationListStatus.error,
          items: state.items,
          failure: failure,
        ));
    }
  }
}
