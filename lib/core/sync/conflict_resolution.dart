import '../error/result.dart';

class LocalVersion<T>{const LocalVersion({required this.value,required this.version,required this.updatedAt});final T value;final int version;final DateTime updatedAt;}
class RemoteVersion<T>{const RemoteVersion({required this.value,required this.version,required this.updatedAt});final T value;final int version;final DateTime updatedAt;}
sealed class ConflictResolution<T>{const ConflictResolution();}
class UseRemote<T> extends ConflictResolution<T>{const UseRemote(this.value);final T value;}
class UseLocal<T> extends ConflictResolution<T>{const UseLocal(this.value);final T value;}
class RequireHumanReview<T> extends ConflictResolution<T>{const RequireHumanReview(this.local,this.remote);final T local;final T remote;}
abstract interface class ConflictResolver<T>{Future<ConflictResolution<T>> resolve(LocalVersion<T> local,RemoteVersion<T> remote);}
class AppointmentConflictResolver implements ConflictResolver<Map<String,dynamic>>{const AppointmentConflictResolver();@override Future<ConflictResolution<Map<String,dynamic>>> resolve(LocalVersion<Map<String,dynamic>> local,RemoteVersion<Map<String,dynamic>> remote) async=>UseRemote(remote.value);}
class ClinicalNoteConflictResolver implements ConflictResolver<Map<String,dynamic>>{const ClinicalNoteConflictResolver();@override Future<ConflictResolution<Map<String,dynamic>>> resolve(LocalVersion<Map<String,dynamic>> local,RemoteVersion<Map<String,dynamic>> remote) async=>RequireHumanReview(local.value,remote.value);}
class PrescriptionConflictResolver implements ConflictResolver<Map<String,dynamic>>{const PrescriptionConflictResolver();@override Future<ConflictResolution<Map<String,dynamic>>> resolve(LocalVersion<Map<String,dynamic>> local,RemoteVersion<Map<String,dynamic>> remote) async=>UseRemote(remote.value);}
