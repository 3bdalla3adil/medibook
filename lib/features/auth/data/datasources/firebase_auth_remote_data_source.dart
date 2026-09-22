import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/security/token_store.dart';
import '../../domain/entities/auth_user.dart';
import 'auth_remote_data_source.dart';

/// Firebase Authentication + Cloud Firestore implementation.
///
/// Authentication is handled by Firebase Auth. The `users/{uid}` document
/// stores the application profile and authorization metadata used by MediBook.
class FirebaseAuthRemoteDataSource implements AuthRemoteDataSource {
  FirebaseAuthRemoteDataSource({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  static const _defaultOrganizationId = 'default';

  static const _patientPermissions = <Permission>{
    Permission.viewOwnAppointments,
    Permission.bookAppointment,
    Permission.cancelOwnAppointment,
    Permission.viewOwnMedicalRecord,
    Permission.joinTelehealth,
  };

  @override
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException('unauthorized');
      }

      return _responseFor(user);
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException('firebase_auth', payload: {'error': e.toString()});
    }
  }

  @override
  Future<LoginResponse> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException('registration_failed');
      }

      await user.updateDisplayName(displayName.trim());
      await user.reload();

      final currentUser = _auth.currentUser ?? user;
      await _writeDefaultProfile(
        currentUser,
        displayName: displayName.trim(),
      );

      // Email verification is enabled as part of the registration flow, but
      // account verification is not enforced by the client.
      try {
        await currentUser.sendEmailVerification();
      } on FirebaseAuthException {
        // Registration itself remains successful if the verification email
        // cannot be sent; the user can request verification again later.
      }

      return _responseFor(currentUser);
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException('firebase_registration', payload: {'error': e.toString()});
    }
  }

  @override
  Future<AuthUser> me() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException('unauthorized');
    }

    final snapshot = await _firestore.collection('users').doc(user.uid).get();
    if (!snapshot.exists || snapshot.data() == null) {
      await _writeDefaultProfile(user, displayName: user.displayName ?? '');
      return _profileFrom(user, const {});
    }

    return _profileFrom(user, snapshot.data()!);
  }

  @override
  Future<void> logout() => _auth.signOut();

  Future<LoginResponse> _responseFor(User user) async {
    final snapshot = await _firestore.collection('users').doc(user.uid).get();
    final profile = snapshot.data() ?? <String, dynamic>{};

    if (!snapshot.exists) {
      await _writeDefaultProfile(user, displayName: user.displayName ?? '');
    }

    final tokenResult = await user.getIdTokenResult(true);
    final now = DateTime.now().toUtc();
    final expiresAt = tokenResult.expirationTime ?? now.add(const Duration(hours: 1));

    return LoginResponse(
      tokens: AuthTokens(
        accessToken: tokenResult.token ?? await user.getIdToken() ?? '',
        accessExpiresAt: expiresAt.toUtc(),
        refreshExpiresAt: now.add(const Duration(days: 30)),
        sessionId: user.uid,
      ),
      user: _profileFrom(user, profile),
    );
  }

  Future<void> _writeDefaultProfile(
    User user, {
    required String displayName,
  }) async {
    await _firestore.collection('users').doc(user.uid).set(
      {
        'id': user.uid,
        'display_name': displayName,
        'email': user.email,
        'roles': ['patient'],
        'permissions': _patientPermissions.map((p) => p.name).toList(),
        'organization_id': _defaultOrganizationId,
        'clinic_ids': <String>[],
        'locale': 'ar',
        'email_verified': user.emailVerified,
        'updated_at': FieldValue.serverTimestamp(),
        'created_at': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  AuthUser _profileFrom(User user, Map<String, dynamic> json) {
    final roleNames = (json['roles'] as List?)?.whereType<String>() ?? const <String>[];
    final permissionNames =
        (json['permissions'] as List?)?.whereType<String>() ?? const <String>[];

    final roles = roleNames.map(_parseRole).whereType<UserRole>().toSet();
    final permissions =
        permissionNames.map(_parsePermission).whereType<Permission>().toSet();

    return AuthUser(
      id: user.uid,
      displayName: (json['display_name'] as String?)?.trim().isNotEmpty == true
          ? json['display_name'] as String
          : (user.displayName ?? ''),
      roles: roles.isEmpty ? {UserRole.patient} : roles,
      permissions: permissions.isEmpty ? _patientPermissions : permissions,
      organizationId: json['organization_id'] as String? ?? _defaultOrganizationId,
      clinicIds: ((json['clinic_ids'] as List?)?.whereType<String>() ?? const <String>[]).toSet(),
      avatarUrl: json['avatar_url'] as String?,
      email: user.email,
      localeCode: json['locale'] as String? ?? 'ar',
    );
  }

  UserRole? _parseRole(String value) {
    for (final role in UserRole.values) {
      if (role.name == value) return role;
    }
    return null;
  }

  Permission? _parsePermission(String value) {
    for (final permission in Permission.values) {
      if (permission.name == value) return permission;
    }
    return null;
  }

  AppException _mapAuthException(FirebaseAuthException e) {
    return switch (e.code) {
      'invalid-email' => const AuthException('invalid_email'),
      'user-not-found' => const AuthException('user_not_found'),
      'wrong-password' || 'invalid-credential' => const AuthException('unauthorized'),
      'user-disabled' => const AuthException('user_disabled'),
      'email-already-in-use' => const AuthException('email_already_in_use'),
      'weak-password' => const AuthException('weak_password'),
      'operation-not-allowed' => const AuthException('operation_not_allowed'),
      'too-many-requests' => const AuthException('too_many_requests'),
      'network-request-failed' => const NetworkException('network'),
      _ => AuthException(e.code.isEmpty ? 'firebase_auth' : e.code),
    };
  }
}
