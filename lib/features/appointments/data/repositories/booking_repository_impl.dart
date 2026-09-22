import '../../../../core/error/result.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/booking_option.dart';
import '../../domain/entities/booking_slot.dart';
import '../../domain/repositories/booking_repository.dart';
import 'package:dio/dio.dart';

class DioBookingRepository implements BookingRepository {
  const DioBookingRepository(this._dio);
  final Dio _dio;

  @override
  Future<Result<List<BookingOption>>> getClinics() => _getOptions(ApiEndpoints.clinics);

  @override
  Future<Result<List<BookingOption>>> getServices(String clinicId) =>
      _getOptions(ApiEndpoints.services, query: {'clinic_id': clinicId});

  @override
  Future<Result<List<BookingOption>>> getDoctors({required String clinicId, required String serviceId}) =>
      _getOptions(ApiEndpoints.doctors, query: {'clinic_id': clinicId, 'service_id': serviceId});

  @override
  Future<Result<List<BookingSlot>>> getAvailableSlots({
    required String clinicId,
    required String serviceId,
    required String doctorId,
    required DateTime day,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.availability,
        queryParameters: {
          'clinic_id': clinicId,
          'service_id': serviceId,
          'doctor_id': doctorId,
          'date': day.toUtc().toIso8601String(),
        },
      );
      final raw = (response.data?['data'] as List?) ?? const [];
      return Ok(raw.map((item) {
        final json = item as Map<String, dynamic>;
        return BookingSlot(
          startsAt: DateTime.parse(json['starts_at'] as String).toUtc(),
          duration: Duration(minutes: (json['duration_minutes'] as num?)?.toInt() ?? 30),
        );
      }).toList(growable: false));
    } catch (e, st) {
      return Err(UnknownFailure(cause: e, stackTrace: st));
    }
  }

  Future<Result<List<BookingOption>>> _getOptions(String path, {Map<String, dynamic>? query}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(path, queryParameters: query);
      final raw = (response.data?['data'] as List?) ?? const [];
      return Ok(raw.map((item) {
        final json = item as Map<String, dynamic>;
        return BookingOption(
          id: json['id'].toString(),
          name: json['name'] as String? ?? '',
          description: json['description'] as String?,
        );
      }).toList(growable: false));
    } catch (e, st) {
      return Err(UnknownFailure(cause: e, stackTrace: st));
    }
  }
}
