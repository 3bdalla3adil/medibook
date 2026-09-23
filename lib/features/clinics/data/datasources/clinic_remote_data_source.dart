import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../models/clinic_dto.dart';

abstract interface class ClinicRemoteDataSource {
  Future<List<ClinicDto>> fetchClinics({bool activeOnly = true});
  Future<ClinicDto?> fetchClinic(String id);
  Future<List<Map<String, dynamic>>> fetchServices(String id);
}

class DioClinicRemoteDataSource implements ClinicRemoteDataSource {
  DioClinicRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<List<ClinicDto>> fetchClinics({bool activeOnly = true}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.clinics,
      queryParameters: {'active': activeOnly},
    );
    final data = response.data?['data'];
    if (data is! List) return const [];
    return data.whereType<Map<String, dynamic>>().map<ClinicDto>(
      ClinicDto.fromJson,
    ).toList(growable: false);
  }

  @override
  Future<ClinicDto?> fetchClinic(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.clinics + '/$id',
    );
    final data = response.data?['data'];
    return data is Map<String, dynamic> ? ClinicDto.fromJson(data) : null;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchServices(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.clinics + '/$id/services',
    );
    return _list(response.data)
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);
  }

  List<dynamic> _list(Map<String, dynamic>? body) =>
      body?['data'] is List ? body!['data'] as List : const [];
}
