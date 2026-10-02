import 'package:equatable/equatable.dart';
enum CallStateStatus { ringing, connecting, connected, ended, failed }
class CallStateValue extends Equatable { const CallStateValue(this.status,{this.reason}); final CallStateStatus status; final String? reason; @override List<Object?> get props=>[status,reason]; }
