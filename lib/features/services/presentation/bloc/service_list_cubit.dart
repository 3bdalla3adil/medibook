import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/medical_service.dart';
import '../../domain/usecases/get_services.dart';

enum ServiceListStatus { initial, loading, ready, error }

class ServiceListState extends Equatable {
  const ServiceListState({
    this.status = ServiceListStatus.initial,
    this.items = const [],
    this.failure,
  });
  final ServiceListStatus status;
  final List<MedicalService> items;
  final Failure? failure;
  @override
  List<Object?> get props => [status, items, failure];
}

class ServiceListCubit extends Cubit<ServiceListState> {
  ServiceListCubit(this._getServices) : super(const ServiceListState());
  final GetServicesUseCase _getServices;

  Future<void> load() async {
    emit(ServiceListState(status: ServiceListStatus.loading, items: state.items));
    final result = await _getServices();
    switch (result) {
      case Ok(value: final items):
        emit(ServiceListState(status: ServiceListStatus.ready, items: items));
      case Err(:final failure):
        emit(ServiceListState(
          status: ServiceListStatus.error,
          items: state.items,
          failure: failure,
        ));
    }
  }
}
