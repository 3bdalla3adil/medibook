import '../../../../core/error/result.dart';
import '../entities/booking_option.dart';
import '../entities/booking_slot.dart';

abstract interface class BookingRepository {
  Future<Result<List<BookingOption>>> getClinics();
  Future<Result<List<BookingOption>>> getServices(String clinicId);
  Future<Result<List<BookingOption>>> getDoctors({required String clinicId, required String serviceId});
  Future<Result<List<BookingSlot>>> getAvailableSlots({
    required String clinicId,
    required String serviceId,
    required String doctorId,
    required DateTime day,
  });
}
