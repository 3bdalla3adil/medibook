import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../models/doctor_dto.dart';
abstract interface class DoctorRemoteDataSource {
  Future<List<DoctorDto>> fetchDoctors({String? clinicId, String? serviceId});
  Future<DoctorDto?> fetchDoctor(String id);
  Future<List<Map<String, dynamic>>> fetchAvailability({
    required String doctorId,
    required DateTime from,
    required DateTime to,
    String? clinicId,
    String? serviceId,
  });
}

class DioDoctorRemoteDataSource implements DoctorRemoteDataSource {
  DioDoctorRemoteDataSource(this._dio);
  final Dio _dio;

  @override
  Future<List<DoctorDto>> fetchDoctors({String? clinicId, String? serviceId}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.doctors,
      queryParameters: {
        if (clinicId != null) 'clinic_id': clinicId,
        if (serviceId != null) 'service_id': serviceId,
      },
    );
    final data = response.data?['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(DoctorDto.fromJson)
        .toList(growable: false);
  }

  @override
  Future<DoctorDto?> fetchDoctor(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.doctors + '/$id',
    );
    final data = response.data?['data'];
    return data is Map<String, dynamic> ? DoctorDto.fromJson(data) : null;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAvailability({
    required String doctorId,
    required DateTime from,
    required DateTime to,
    String? clinicId,
    String? serviceId,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.doctors + '/$doctorId/availability',
      queryParameters: {
        'from': from.toUtc().toIso8601String(),
        'to': to.toUtc().toIso8601String(),
        if (clinicId != null) 'clinic_id': clinicId,
        if (serviceId != null) 'service_id': serviceId,
      },
    );
    final data = response.data?['data'];
    if (data is! List) return const [];
    return data.whereType<Map<String, dynamic>>().toList(growable: false);
  }
}
