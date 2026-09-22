import 'package:flutter_test/flutter_test.dart';
import 'package:medibook/features/appointments/domain/entities/appointment_status.dart';

import '../../../_fixtures/fixtures.dart';

void main() {
  group('Appointment', () {
    test('endsAt = startsAt + duration', () {
      final a = testAppointment();
      expect(a.endsAt, a.startsAt.add(const Duration(minutes: 30)));
    });

    test('isUpcoming is false for terminal statuses', () {
      final future = DateTime.utc(2099);
      final a = testAppointment(
        status: AppointmentStatus.completed,
        startsAt: future,
      );
      expect(a.isUpcoming(DateTime.utc(2026)), isFalse);
    });

    test('isWithinJoinWindow behaves around the 15-minute window', () {
      final start = DateTime.utc(2026, 3, 15, 9, 30);
      final a = testAppointment(telehealth: true, startsAt: start);
      expect(a.isWithinJoinWindow(start.subtract(const Duration(minutes: 20))), isFalse);
      expect(a.isWithinJoinWindow(start.subtract(const Duration(minutes: 10))), isTrue);
      expect(a.isWithinJoinWindow(start), isTrue);
      expect(a.isWithinJoinWindow(a.endsAt.add(const Duration(minutes: 1))), isFalse);
    });

    test('isWithinJoinWindow requires telehealth', () {
      final start = DateTime.utc(2026, 3, 15, 9, 30);
      final a = testAppointment(telehealth: false, startsAt: start);
      expect(a.isWithinJoinWindow(start), isFalse);
    });

    test('copyWith preserves identity fields', () {
      final a = testAppointment();
      final b = a.copyWith(status: AppointmentStatus.checkedIn);
      expect(b.id, a.id);
      expect(b.patientId, a.patientId);
      expect(b.status, AppointmentStatus.checkedIn);
    });
  });
}
