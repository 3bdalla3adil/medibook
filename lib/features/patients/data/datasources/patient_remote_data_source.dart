import 'package:dio/dio.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/patient_dto.dart';

abstract interface class PatientRemoteDataSource {
  Future<PatientDto?> fetchCurrent();
  Future<PatientDto?> fetchById(String id);
}

class DioPatientRemoteDataSource implements PatientRemoteDataSource {
  DioPatientRemoteDataSource(this._dio);
  final Dio _dio;

  @override
  Future<PatientDto?> fetchCurrent() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(ApiEndpoints.me);
      final data = res.data?['data'] as Map<String, dynamic>?;
      return data == null ? null : PatientDto.fromJson(data);
    } on DioException catch (e) {
      throw _asException(e);
    }
  }

  @override
  Future<PatientDto?> fetchById(String id) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(ApiEndpoints.me);
      final data = res.data?['data'] as Map<String, dynamic>?;
      return data == null ? null : PatientDto.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _asException(e);
    }
  }

  AppException _asException(DioException e) {
    final f = ErrorMapper.fromDio(e);
    return switch (f) {
      UnauthorizedFailure() => const AuthException('unauthorized'),
      NotFoundFailure() => const ServerException('not_found', statusCode: 404),
      NetworkFailure() || TimeoutFailure() => const NetworkException('network'),
      _ => const ServerException('unknown'),
    };
  }
}
