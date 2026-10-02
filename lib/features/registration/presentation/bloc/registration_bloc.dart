import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/invitation.dart';
import '../../domain/entities/registration_draft.dart';
import '../../domain/usecases/accept_invitation.dart';
import '../../domain/usecases/register_patient.dart';
import '../../domain/usecases/validate_invitation.dart';

sealed class RegistrationEvent { const RegistrationEvent(); }
final class RegistrationSubmitted extends RegistrationEvent { const RegistrationSubmitted(this.draft); final RegistrationDraft draft; }
final class InvitationLoaded extends RegistrationEvent { const InvitationLoaded(this.token); final String token; }
final class InvitationAccepted extends RegistrationEvent { const InvitationAccepted({required this.token,required this.password,required this.displayName}); final String token,password,displayName; }

enum RegistrationStatus { initial, loading, ready, success, failure }
class RegistrationState extends Equatable { const RegistrationState({this.status=RegistrationStatus.initial,this.invitation,this.errorCode}); final RegistrationStatus status; final Invitation? invitation; final String? errorCode; @override List<Object?> get props=>[status,invitation,errorCode]; }
class RegistrationBloc extends Bloc<RegistrationEvent,RegistrationState> {
  RegistrationBloc({required RegisterPatient register,required ValidateInvitation validate,required AcceptInvitation accept}):_register=register,_validate=validate,_accept=accept,super(const RegistrationState()){on<RegistrationSubmitted>(_submit);on<InvitationLoaded>(_load);on<InvitationAccepted>(_acceptInvite);}
  final RegisterPatient _register; final ValidateInvitation _validate; final AcceptInvitation _accept;
  Future<void> _submit(RegistrationSubmitted e,Emitter<RegistrationState> emit)async{emit(const RegistrationState(status:RegistrationStatus.loading));final r=await _register(e.draft);switch(r){case Ok<void>():emit(const RegistrationState(status:RegistrationStatus.success));case Err<void>(:final failure):emit(RegistrationState(status:RegistrationStatus.failure,errorCode:failure.code));}}
  Future<void> _load(InvitationLoaded e,Emitter<RegistrationState> emit)async{emit(const RegistrationState(status:RegistrationStatus.loading));final r=await _validate(e.token);switch(r){case Ok<Invitation>(:final value):emit(RegistrationState(status:RegistrationStatus.ready,invitation:value));case Err<Invitation>(:final failure):emit(RegistrationState(status:RegistrationStatus.failure,errorCode:failure.code));}}
  Future<void> _acceptInvite(InvitationAccepted e,Emitter<RegistrationState> emit)async{emit(const RegistrationState(status:RegistrationStatus.loading));final r=await _accept(token:e.token,password:e.password,displayName:e.displayName);switch(r){case Ok():emit(const RegistrationState(status:RegistrationStatus.success));case Err(:final failure):emit(RegistrationState(status:RegistrationStatus.failure,errorCode:failure.code));}}
}
