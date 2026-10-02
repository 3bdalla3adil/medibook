import 'package:equatable/equatable.dart';
class CallParticipant extends Equatable { const CallParticipant({required this.id,required this.displayName,required this.isHost}); final String id,displayName; final bool isHost; @override List<Object?> get props=>[id,displayName,isHost]; }
