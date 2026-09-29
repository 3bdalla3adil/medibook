import 'package:dio/dio.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../models/availability_slot_dto.dart';
import '../models/doctor_assignment_dto.dart';

abstract interface class DoctorRemoteDataSource {
  Future<List<Map<String, dynamic>>> fetchDoctors({
    String? clinicId,
    String? serviceId,
  });

  Future<Map<String, dynamic>?> fetchDoctor(String id);

  Future<List<DoctorAssignmentDto>> fetchAssignments(String doctorId);

  Future<List<AvailabilitySlotDto>> fetchAvailability({
    required String doctorId,
    required String clinicId,
    required String serviceId,
    required DateTime from,
    required DateTime to,
  });
}

class DioDoctorRemoteDataSource implements DoctorRemoteDataSource {
  DioDoctorRemoteDataSource(this._dio);
  final Dio _dio;

  @override
  Future<List<Map<String, dynamic>>> fetchDoctors({
    String? clinicId,
    String? serviceId,
  }) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/medibook/api/doctors',
        queryParameters: {
          if (clinicId != null) 'clinic_id': clinicId,
          if (serviceId != null) 'service_id': serviceId,
        },
      );
      final list = (res.data?['data'] as List?) ?? const [];
      return list.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw _asException(e);
    }
  }

  @override
  Future<Map<String, dynamic>?> fetchDoctor(String id) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/medibook/api/doctors/$id',
      );
      return res.data?['data'] as Map<String, dynamic>?;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _asException(e);
    }
  }

  @override
  Future<List<DoctorAssignmentDto>> fetchAssignments(String doctorId) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/medibook/api/doctors/$doctorId/assignments',
      );
      final list = (res.data?['data'] as List?) ?? const [];
      return list
          .cast<Map<String, dynamic>>()
          .map(DoctorAssignmentDto.fromJson)
          .toList(growable: false);
    } on DioException catch (e) {
      throw _asException(e);
    }
  }

  @override
  Future<List<AvailabilitySlotDto>> fetchAvailability({
    required String doctorId,
    required String clinicId,
    required String serviceId,
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/medibook/api/doctors/$doctorId/availability',
        queryParameters: {
          'clinic_id': clinicId,
          'service_id': serviceId,
          'from': from.toUtc().toIso8601String(),
          'to': to.toUtc().toIso8601String(),
        },
      );
      final list = (res.data?['data'] as List?) ?? const [];
      return list
          .cast<Map<String, dynamic>>()
          .map(AvailabilitySlotDto.fromJson)
          .toList(growable: false);
    } on DioException catch (e) {
      throw _asException(e);
    }
  }

  AppException _asException(DioException e) {
    final failure = ErrorMapper.fromDio(e);
    return switch (failure) {
      UnauthorizedFailure() => const AuthException('unauthorized'),
      ForbiddenFailure() => const ServerException('forbidden', statusCode: 403),
      NotFoundFailure() => const ServerException('not_found', statusCode: 404),
      ConflictFailure(:final code) => ConflictException('conflict', code: code),
      ValidationFailure() => const ServerException('validation', statusCode: 422),
      ServerFailure(:final statusCode) =>
        ServerException('server', statusCode: statusCode),
      NetworkFailure() || TimeoutFailure() => const NetworkException('network'),
      _ => const ServerException('unknown'),
    };
  }
}
