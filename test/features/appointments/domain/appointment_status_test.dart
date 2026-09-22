import 'package:flutter_test/flutter_test.dart';
import 'package:medibook/features/appointments/domain/entities/appointment_status.dart';

void main() {
  group('AppointmentStatus transitions', () {
    test('scheduled can move to checkedIn, cancelled, or noShow', () {
      expect(
        AppointmentStatus.scheduled.allowedNext,
        {
          AppointmentStatus.checkedIn,
          AppointmentStatus.cancelled,
          AppointmentStatus.noShow,
        },
      );
    });

    test('completed is terminal', () {
      expect(AppointmentStatus.completed.allowedNext, isEmpty);
      expect(AppointmentStatus.completed.isTerminal, isTrue);
    });

    test('cannot jump from scheduled to completed', () {
      expect(
        AppointmentStatus.scheduled.canTransitionTo(AppointmentStatus.completed),
        isFalse,
      );
    });

    test('isJoinable only for scheduled and checkedIn', () {
      expect(AppointmentStatus.scheduled.isJoinable, isTrue);
      expect(AppointmentStatus.checkedIn.isJoinable, isTrue);
      expect(AppointmentStatus.inConsultation.isJoinable, isFalse);
      expect(AppointmentStatus.completed.isJoinable, isFalse);
    });

    test('wire round-trip preserves value', () {
      for (final status in AppointmentStatus.values) {
        expect(AppointmentStatus.fromWire(status.toWire()), status);
      }
    });

    test('unknown wire value throws', () {
      expect(() => AppointmentStatus.fromWire('bogus'), throwsArgumentError);
    });
  });
}
