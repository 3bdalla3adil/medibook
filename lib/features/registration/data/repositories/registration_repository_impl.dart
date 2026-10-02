import '../../../../core/error/result.dart';
import '../../../auth/domain/entities/auth_user.dart';
import '../../domain/entities/invitation.dart';
import '../../domain/entities/registration_draft.dart';
import '../../domain/repositories/registration_repository.dart';
import '../datasources/registration_remote_data_source.dart';

class RegistrationRepositoryImpl implements RegistrationRepository { const RegistrationRepositoryImpl(this._remote); final RegistrationRemoteDataSource _remote; @override Future<Result<void>> registerPatient(RegistrationDraft draft)=>_remote.registerPatient(draft); @override Future<Result<Invitation>> validateInvitation(String token)=>_remote.validateInvitation(token); @override Future<Result<AuthUser>> acceptInvitation({required String token,required String password,required String displayName})=>_remote.acceptInvitation(token:token,password:password,displayName:displayName); }
