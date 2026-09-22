import 'package:flutter_test/flutter_test.dart';
import 'package:medibook/core/security/phi_redactor.dart';

void main() {
  group('PhiRedactor.redact', () {
    test('masks email addresses', () {
      expect(
        PhiRedactor.redact('contact sara@example.com today'),
        'contact *** today',
      );
    });

    test('masks JWTs regardless of position', () {
      const token =
          'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c';
      expect(PhiRedactor.redact('Bearer $token'), 'Bearer ***');
    });

    test('masks query-string secrets but keeps the key', () {
      final out = PhiRedactor.redact('https://x.test/a?token=abcd&page=2');
      expect(out, contains('token=***'));
      expect(out, contains('page=2'));
    });

    test('masks UUIDs', () {
      expect(
        PhiRedactor.redact('id=550e8400-e29b-41d4-a716-446655440000'),
        'id=***',
      );
    });

    test('leaves benign text untouched', () {
      expect(
        PhiRedactor.redact('Appointment booked successfully'),
        'Appointment booked successfully',
      );
    });
  });

  group('PhiRedactor.redactValue', () {
    test('masks known sensitive keys', () {
      final result = PhiRedactor.redactValue({
        'email': 'sara@example.com',
        'mrn': 'MRN-00123',
        'page': 3,
      }) as Map;
      expect(result['email'], '***');
      expect(result['mrn'], '***');
      expect(result['page'], 3);
    });

    test('recurses into nested structures', () {
      final result = PhiRedactor.redactValue({
        'patient': {'full_name': 'Sara Al-Fahad', 'age': 34},
      }) as Map;
      final patient = result['patient'] as Map;
      expect(patient['full_name'], '***');
      expect(patient['age'], 34);
    });

    test('stops recursing at depth limit', () {
      Object? deep = 'leaf';
      for (var i = 0; i < 20; i++) {
        deep = {'nested': deep};
      }
      expect(() => PhiRedactor.redactValue(deep), returnsNormally);
    });
  });
}
