import '../../../../core/demo/demo_seed.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/booking_option.dart';
import '../../domain/entities/booking_slot.dart';
import '../../domain/repositories/booking_repository.dart';

class DemoBookingRepository implements BookingRepository {
  const DemoBookingRepository();

  @override
  Future<Result<List<BookingOption>>> getClinics() async => Ok(
        DemoSeed.clinics().map((e) => BookingOption(
          id: e.json['id'].toString(),
          name: (e.json['name'] as Map)['en'].toString(),
        )).toList(growable: false),
      );

  @override
  Future<Result<List<BookingOption>>> getServices(String clinicId) async => Ok(
        DemoSeed.services().map((e) => BookingOption(
          id: e.json['id'].toString(),
          name: e.json['name'].toString(),
          description: e.json['description']?.toString(),
        )).toList(growable: false),
      );

  @override
  Future<Result<List<BookingOption>>> getDoctors({
    required String clinicId,
    required String serviceId,
  }) async => Ok(
        DemoSeed.doctors().map((e) => BookingOption(
          id: e.json['id'].toString(),
          name: e.json['display_name'].toString(),
          description: e.json['specialization']?.toString(),
        )).toList(growable: false),
      );

  @override
  Future<Result<List<BookingSlot>>> getAvailableSlots({
    required String clinicId,
    required String serviceId,
    required String doctorId,
    required DateTime day,
  }) async {
    final base = DateTime.utc(day.year, day.month, day.day, 9);
    return Ok([
      BookingSlot(startsAt: base, duration: const Duration(minutes: 30)),
      BookingSlot(startsAt: base.add(const Duration(hours: 1)), duration: const Duration(minutes: 30)),
      BookingSlot(startsAt: base.add(const Duration(hours: 2)), duration: const Duration(minutes: 30)),
    ]);
  }
}
