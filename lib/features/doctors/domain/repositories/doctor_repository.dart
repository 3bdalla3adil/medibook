import '../../../../core/error/result.dart';
import '../entities/availability_slot.dart';
import '../entities/doctor.dart';
import '../entities/doctor_assignment.dart';

abstract interface class DoctorRepository {
  Future<Result<List<Doctor>>> getDoctors({
    String? clinicId,
    String? serviceId,
  });

  Future<Result<Doctor?>> getDoctor(String id);

  /// Returns the doctor's assignments. The client uses this to show
  /// "Dr. X works at Clinic A (cardiology) and Clinic B (general)".
  Future<Result<List<DoctorAssignment>>> getAssignments(String doctorId);

  /// The authoritative availability query.
  ///
  /// The client must NOT compute slots locally — bookings, timezone,
  /// and exceptions are all server-owned. This method returns what the
  /// server says is bookable right now.
  Future<Result<List<AvailabilitySlot>>> getAvailability({
    required String doctorId,
    required String clinicId,
    required String serviceId,
    required DateTime from,
    required DateTime to,
  });
}
