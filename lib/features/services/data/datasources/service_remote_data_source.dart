import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../models/medical_service_dto.dart';

abstract interface class ServiceRemoteDataSource {
  Future<List<MedicalServiceDto>> fetchServices({String? clinicId});
  Future<MedicalServiceDto?> fetchService(String id);
}

class DioServiceRemoteDataSource implements ServiceRemoteDataSource {
  DioServiceRemoteDataSource(this._dio);
  final Dio _dio;

  @override
  Future<List<MedicalServiceDto>> fetchServices({String? clinicId}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.services,
      queryParameters: {if (clinicId != null) 'clinic_id': clinicId},
    );
    final data = response.data?['data'];
    if (data is! List) return const [];
    return data.whereType<Map<String, dynamic>>()
        .map(MedicalServiceDto.fromJson).toList(growable: false);
  }

  @override
  Future<MedicalServiceDto?> fetchService(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.services + '/' + id,
    );
    final data = response.data?['data'];
    return data is Map<String, dynamic> ? MedicalServiceDto.fromJson(data) : null;
  }
}
