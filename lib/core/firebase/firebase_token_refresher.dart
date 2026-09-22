import 'package:firebase_auth/firebase_auth.dart';

import '../security/token_store.dart';

class FirebaseTokenRefresher {
  const FirebaseTokenRefresher();

  Future<AuthTokens?> refresh() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final result = await user.getIdTokenResult(true);
    final token = result.token;
    if (token == null || token.isEmpty) return null;

    final now = DateTime.now().toUtc();
    return AuthTokens(
      accessToken: token,
      accessExpiresAt:
          (result.expirationTime ?? now.add(const Duration(hours: 1))).toUtc(),
      refreshExpiresAt: now.add(const Duration(days: 30)),
      sessionId: user.uid,
    );
  }
}
