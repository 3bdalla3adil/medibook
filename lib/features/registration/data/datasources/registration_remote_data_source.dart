import '../../../../core/error/result.dart';
import '../../../auth/domain/entities/auth_user.dart';
import '../../domain/entities/invitation.dart';
import '../../domain/entities/registration_draft.dart';

abstract interface class RegistrationRemoteDataSource { Future<Result<void>> registerPatient(RegistrationDraft draft); Future<Result<Invitation>> validateInvitation(String token); Future<Result<AuthUser>> acceptInvitation({required String token, required String password, required String displayName}); }
