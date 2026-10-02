import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/medication.dart';
import '../../domain/repositories/medication_repository.dart';

class MedicationListState extends Equatable { const MedicationListState({this.loading=false,this.items=const [],this.error}); final bool loading; final List<PatientMedication> items; final String? error; @override List<Object?> get props=>[loading,items,error]; }
class MedicationListBloc extends Cubit<MedicationListState> { MedicationListBloc(this._repo):super(const MedicationListState()); final MedicationRepository _repo; Future<void> load()async{emit(MedicationListState(loading:true,items:state.items));final r=await _repo.getPatientMedications();switch(r){case Ok<List<PatientMedication>>(:final value):emit(MedicationListState(items:value));case Err<List<PatientMedication>>(:final failure):emit(MedicationListState(items:state.items,error:failure.code));}} }
