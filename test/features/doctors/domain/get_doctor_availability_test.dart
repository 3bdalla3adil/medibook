import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:medibook/core/error/failure.dart';
import 'package:medibook/core/error/result.dart';
import 'package:medibook/features/doctors/domain/entities/availability_slot.dart';
import 'package:medibook/features/doctors/domain/repositories/doctor_repository.dart';
import 'package:medibook/features/doctors/domain/usecases/get_doctor_availability.dart';

class _MockRepo extends Mock implements DoctorRepository {}

void main() {
  late _MockRepo repo;
  late GetDoctorAvailabilityUseCase useCase;

  setUp(() {
    repo = _MockRepo();
    useCase = GetDoctorAvailabilityUseCase(repo);
  });

  test('returns ValidationFailure when ids are empty', () async {
    final result = await useCase(
      doctorId: '',
      clinicId: 'c-1',
      serviceId: 's-1',
      from: DateTime(2026, 1, 1),
      to: DateTime(2026, 1, 2),
    );
    expect(result, isA<Err<List<AvailabilitySlot>>>());
    expect(result.failureOrNull, isA<ValidationFailure>());
  });

  test('returns ValidationFailure when range is inverted', () async {
    final result = await useCase(
      doctorId: 'd-1',
      clinicId: 'c-1',
      serviceId: 's-1',
      from: DateTime(2026, 1, 2),
      to: DateTime(2026, 1, 1),
    );
    expect(result.failureOrNull, isA<ValidationFailure>());
  });

  test('returns ValidationFailure when range exceeds 60 days', () async {
    final result = await useCase(
      doctorId: 'd-1',
      clinicId: 'c-1',
      serviceId: 's-1',
      from: DateTime(2026, 1, 1),
      to: DateTime(2026, 6, 1),
    );
    expect(result.failureOrNull, isA<ValidationFailure>());
  });

  test('delegates to repository on valid input', () async {
    when(() => repo.getAvailability(
          doctorId: any(named: 'doctorId'),
          clinicId: any(named: 'clinicId'),
          serviceId: any(named: 'serviceId'),
          from: any(named: 'from'),
          to: any(named: 'to'),
        )).thenAnswer((_) async => const Ok(<AvailabilitySlot>[]));

    final result = await useCase(
      doctorId: 'd-1',
      clinicId: 'c-1',
      serviceId: 's-1',
      from: DateTime(2026, 1, 1),
      to: DateTime(2026, 1, 5),
    );
    expect(result.isOk, isTrue);
  });
}
