import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/triage_vitals.dart';
import '../../domain/repositories/triage_repository.dart';

enum TriageStatus { idle, loading, ready, saving, error }

class TriageState {
  const TriageState({this.status=TriageStatus.idle,this.vitals,this.failure});
  final TriageStatus status;
  final TriageVitals? vitals;
  final Failure? failure;
  TriageState copyWith({TriageStatus? status,TriageVitals? vitals,Failure? failure,bool clearFailure=false})=>TriageState(
    status:status??this.status,vitals:vitals??this.vitals,failure:clearFailure?null:(failure??this.failure));
}

class TriageCubit extends Cubit<TriageState> {
  TriageCubit(this._repository,this.appointmentId):super(const TriageState());
  final TriageRepository _repository;
  final String appointmentId;
  Future<void> load() async {
    emit(state.copyWith(status:TriageStatus.loading,clearFailure:true));
    final result=await _repository.getForAppointment(appointmentId);
    if(result.isOk) {
      emit(TriageState(status:TriageStatus.ready,vitals:result.valueOrNull));
    } else {
      emit(state.copyWith(status:TriageStatus.error,failure:result.failureOrNull));
    }
  }
  Future<bool> save(TriageVitals vitals) async {
    emit(state.copyWith(status:TriageStatus.saving,clearFailure:true));
    final result=await _repository.save(appointmentId,vitals);
    if(result.isOk) {
      emit(TriageState(status:TriageStatus.ready,vitals:result.valueOrNull));
      return true;
    }
    emit(state.copyWith(status:TriageStatus.error,failure:result.failureOrNull));
    return false;
  }
}
