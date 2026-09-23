import 'package:flutter_test/flutter_test.dart';
import 'package:medibook/core/sync/conflict_policy_registry.dart';
import 'package:medibook/core/sync/conflict_resolution.dart';

void main() {
  final now = DateTime.utc(2026, 9, 23);

  test('appointments are server authoritative', () async {
    const resolver = AppointmentConflictResolver();
    final result = await resolver.resolve(
      LocalVersion(value: {'status': 'pending'}, version: 1, updatedAt: now),
      RemoteVersion(value: {'status': 'confirmed'}, version: 2, updatedAt: now),
    );
    expect(result, isA<UseRemote<Map<String, dynamic>>>());
  });

  test('clinical notes always require human review', () async {
    const resolver = ClinicalNoteConflictResolver();
    final result = await resolver.resolve(
      LocalVersion(value: {'body': 'local'}, version: 2, updatedAt: now),
      RemoteVersion(value: {'body': 'remote'}, version: 3, updatedAt: now),
    );
    expect(result, isA<RequireHumanReview<Map<String, dynamic>>>());
  });

  test('policy registry covers required clinical strategies', () {
    const registry = ConflictPolicyRegistry();
    expect(registry.strategyFor('appointment'), ConflictStrategy.serverAuthoritative);
    expect(registry.strategyFor('patient_profile'), ConflictStrategy.fieldMergeRequiresPrompt);
    expect(registry.strategyFor('clinical_note'), ConflictStrategy.humanReview);
    expect(registry.strategyFor('prescription'), ConflictStrategy.serverAuthoritative);
  });
}
