import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../../../core/security/screen_guard.dart';
import '../../../../core/utils/clock.dart';
import '../../../consultations/domain/repositories/consultation_repository.dart';
import '../../domain/entities/telehealth_session.dart';
import '../../domain/repositories/daily_call_service.dart';
import '../../domain/repositories/telehealth_repository.dart';

enum TelehealthSessionStatus { idle, loading, connecting, connected, ending, ended, error }

class TelehealthSessionState {
  const TelehealthSessionState({this.status=TelehealthSessionStatus.idle,this.session,this.message});
  final TelehealthSessionStatus status;
  final TelehealthSession? session;
  final String? message;
}

sealed class TelehealthSessionEvent {
  const TelehealthSessionEvent();
}
class TelehealthStartRequested extends TelehealthSessionEvent {
  const TelehealthStartRequested(this.appointmentId);
  final String appointmentId;
}
class TelehealthLeaveRequested extends TelehealthSessionEvent {
  const TelehealthLeaveRequested();
}
class TelehealthConnectionChanged extends TelehealthSessionEvent {
  const TelehealthConnectionChanged(this.state);
  final TelehealthConnectionState state;
}

class TelehealthSessionBloc extends Bloc<TelehealthSessionEvent, TelehealthSessionState> {
  TelehealthSessionBloc({required TelehealthRepository repository,required DailyCallService callService,required ConsultationRepository consultations,required ScreenGuard screenGuard,required Clock clock})
      : _repository=repository,_call=callService,_consultations=consultations,_screenGuard=screenGuard,_clock=clock,super(const TelehealthSessionState()){
    on<TelehealthStartRequested>(_start);
    on<TelehealthLeaveRequested>(_leave);
    on<TelehealthConnectionChanged>(_connectionChanged);
  }
  final TelehealthRepository _repository; final DailyCallService _call; final ConsultationRepository _consultations; final ScreenGuard _screenGuard; final Clock _clock;
  StreamSubscription<TelehealthConnectionState>? _sub;

  Future<void> _start(TelehealthStartRequested event, Emitter<TelehealthSessionState> emit) async {
    emit(const TelehealthSessionState(status:TelehealthSessionStatus.loading));
    final result=await _repository.createSession(event.appointmentId);
    if(result case Err(:final failure)){emit(TelehealthSessionState(status:TelehealthSessionStatus.error,message:failure.code));return;}
    final session=(result as Ok<TelehealthSession>).value;
    if(session.isExpired(_clock.now()) || session.expiresAt.difference(_clock.now()) > const Duration(minutes:15)){emit(const TelehealthSessionState(status:TelehealthSessionStatus.error,message:'invalid_join_token_expiration'));return;}
    emit(TelehealthSessionState(status:TelehealthSessionStatus.connecting,session:session));
    await _screenGuard.enable();
    try {
      await _call.join(session);
      await _repository.markJoined(session.id);
      await _consultations.startConsultation(session.appointmentId);
      await _sub?.cancel();
      _sub=_call.connectionStates.listen((s)=>add(TelehealthConnectionChanged(s)));
    } catch(e) {
      await _screenGuard.disable();
      emit(TelehealthSessionState(status:TelehealthSessionStatus.error,session:session,message:e.toString()));
    }
  }

  Future<void> _connectionChanged(TelehealthConnectionChanged event, Emitter<TelehealthSessionState> emit) {
    final session=state.session;
    if(event.state==TelehealthConnectionState.connected){emit(TelehealthSessionState(status:TelehealthSessionStatus.connected,session:session));}
    if(event.state==TelehealthConnectionState.ended){emit(TelehealthSessionState(status:TelehealthSessionStatus.ended,session:session));}
    if(event.state==TelehealthConnectionState.failed){emit(TelehealthSessionState(status:TelehealthSessionStatus.error,session:session,message:'telehealth_connection_failed'));}
    return Future.value();
  }

  Future<void> _leave(TelehealthLeaveRequested event, Emitter<TelehealthSessionState> emit) async {
    final session=state.session;
    emit(TelehealthSessionState(status:TelehealthSessionStatus.ending,session:session));
    try { await _call.leave(); if(session!=null) await _repository.endSession(session.id); }
    finally { await _screenGuard.disable(); emit(TelehealthSessionState(status:TelehealthSessionStatus.ended,session:session)); }
  }

  @override Future<void> close() async {await _sub?.cancel(); await _call.dispose(); await _screenGuard.disable(); return super.close();}
}
