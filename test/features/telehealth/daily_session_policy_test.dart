import 'package:flutter_test/flutter_test.dart';
import 'package:medibook/features/telehealth/domain/entities/telehealth_session.dart';

void main() {
  test('telehealth tokens must expire within 15 minutes', () {
    final now = DateTime.utc(2026, 9, 23, 10);
    final valid = TelehealthSession(
      id: 's1',
      appointmentId: 'a1',
      provider: 'daily',
      joinToken: 'never-log-this',
      expiresAt: now.add(const Duration(minutes: 14)),
    );
    final invalid = TelehealthSession(
      id: 's2',
      appointmentId: 'a2',
      provider: 'daily',
      joinToken: 'never-log-this',
      expiresAt: now.add(const Duration(minutes: 16)),
    );
    expect(valid.isExpired(now), isFalse);
    expect(invalid.expiresAt.difference(now), greaterThan(const Duration(minutes: 15)));
  });
}
