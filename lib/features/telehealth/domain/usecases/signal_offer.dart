import '../../../../core/error/result.dart';
abstract interface class TelehealthSignaling { Future<Result<void>> send(String kind,Map<String,dynamic> payload); Stream<Map<String,dynamic>> get messages; }
class SignalOffer { const SignalOffer(this._signaling); final TelehealthSignaling _signaling; Future<Result<void>> call(Map<String,dynamic> offer)=>_signaling.send('call:offer',offer); }
