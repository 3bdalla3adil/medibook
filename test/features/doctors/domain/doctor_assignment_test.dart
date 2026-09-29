import 'package:flutter_test/flutter_test.dart';
import 'package:medibook/features/doctors/domain/entities/doctor_assignment.dart';

void main() {
  group('DoctorAssignment', () {
    test('providesService returns true for known service', () {
      const assignment = DoctorAssignment(
        id: 'a-1',
        doctorId: 'd-1',
        clinicId: 'c-1',
        serviceIds: {'svc-cardio', 'svc-general'},
        weeklyAvailability: {},
      );
      expect(assignment.providesService('svc-cardio'), isTrue);
      expect(assignment.providesService('svc-derma'), isFalse);
    });

    test('TimeRange.contains respects start inclusive, end exclusive', () {
      const range = TimeRange(start: 540, end: 720); // 09:00-12:00
      expect(range.contains(539), isFalse);
      expect(range.contains(540), isTrue);
      expect(range.contains(719), isTrue);
      expect(range.contains(720), isFalse);
    });

    test('TimeRange.durationMinutes is correct', () {
      const range = TimeRange(start: 540, end: 720);
      expect(range.durationMinutes, 180);
    });
  });
}
