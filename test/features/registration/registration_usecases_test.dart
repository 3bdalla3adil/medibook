import 'package:flutter_test/flutter_test.dart';
import 'package:medibook/core/error/result.dart';
import 'package:medibook/features/registration/domain/entities/registration_draft.dart';
import 'package:medibook/features/registration/domain/entities/invitation.dart';
import 'package:medibook/features/auth/domain/entities/auth_user.dart';
import 'package:medibook/features/registration/domain/repositories/registration_repository.dart';
import 'package:medibook/features/registration/domain/usecases/register_patient.dart';
import 'package:medibook/features/registration/domain/usecases/validate_invitation.dart';

class _FakeRegistrationRepository implements RegistrationRepository { RegistrationDraft? draft; @override Future<Result<void>> registerPatient(RegistrationDraft value) async { draft=value; return const Ok(null); } @override Future<Result<Invitation>> validateInvitation(String token) async => throw UnimplementedError(); @override Future<Result<AuthUser>> acceptInvitation({required String token,required String password,required String displayName}) async=>throw UnimplementedError(); }
void main(){test('patient registration rejects weak credentials',()async{final repo=_FakeRegistrationRepository();final result=await RegisterPatient(repo)(const RegistrationDraft(email:'',password:'short',displayName:''));expect(result,isA<Err<void>>());expect(repo.draft,isNull);});}
