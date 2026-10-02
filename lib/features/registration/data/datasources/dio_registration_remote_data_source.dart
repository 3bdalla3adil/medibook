import 'package:dio/dio.dart';
import '../../../../core/error/result.dart';
import '../../../auth/domain/entities/auth_user.dart';
import '../../domain/entities/invitation.dart';
import '../../domain/entities/registration_draft.dart';
import '../models/invitation_dto.dart';
import '../models/registration_dto.dart';
import 'registration_remote_data_source.dart';

class DioRegistrationRemoteDataSource implements RegistrationRemoteDataSource {
  const DioRegistrationRemoteDataSource(this._dio); final Dio _dio;
  Future<Result<T>> _request<T>(Future<T> Function() call) async { try { return Ok(await call()); } on DioException catch (e) { return Err(ServerFailure(statusCode: e.response?.statusCode, cause: e)); } }
  @override Future<Result<void>> registerPatient(RegistrationDraft draft)=>_request(() async {await _dio.post('/registration/register',data:RegistrationDto.fromDomain(draft).toJson());});
  @override Future<Result<Invitation>> validateInvitation(String token)=>_request(() async {final r=await _dio.get('/registration/invitation/$token');return InvitationDto.fromJson(r.data['data'] as Map<String,dynamic>).value;});
  @override Future<Result<AuthUser>> acceptInvitation({required String token,required String password,required String displayName})=>_request(() async {final r=await _dio.post('/registration/invitation/$token/accept',data:{'password':password,'display_name':displayName});final j=r.data['data'] as Map<String,dynamic>;return AuthUser(id:j['user_id'].toString(),displayName:displayName,roles:{UserRole.values.firstWhere((x)=>x.name==j['role'],orElse:()=>UserRole.patient)},permissions:const {},organizationId:'0');});
}
