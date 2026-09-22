import 'package:dio/dio.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/appointment_dto.dart';

abstract interface class AppointmentRemoteDataSource {
  Future<List<AppointmentDto>> fetchAppointments({DateTime? from, DateTime? to});
  Future<AppointmentDto?> fetchAppointment(String id);
  Future<AppointmentDto> create(Map<String, dynamic> body, {required String idempotencyKey});
  Future<AppointmentDto> update(String id, Map<String, dynamic> body, {int? version});
  Future<AppointmentDto> cancel(String id, {String? reason});
  Future<AppointmentDto> reschedule(String id, DateTime newStart);
}

class DioAppointmentRemoteDataSource implements AppointmentRemoteDataSource {
  DioAppointmentRemoteDataSource(this._dio);
  final Dio _dio;

  @override
  Future<List<AppointmentDto>> fetchAppointments({DateTime? from, DateTime? to}) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.appointments,
        queryParameters: {
          if (from != null) 'from': from.toUtc().toIso8601String(),
          if (to != null) 'to': to.toUtc().toIso8601String(),
        },
      );
      final list = (res.data?['data'] as List?) ?? const [];
      return list
          .cast<Map<String, dynamic>>()
          .map(AppointmentDto.fromJson)
          .toList(growable: false);
    } on DioException catch (e) {
      throw _asException(e);
    }
  }

  @override
  Future<AppointmentDto?> fetchAppointment(String id) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(ApiEndpoints.appointment(id));
      final data = res.data?['data'] as Map<String, dynamic>?;
      return data == null ? null : AppointmentDto.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _asException(e);
    }
  }

  @override
  Future<AppointmentDto> create(
    Map<String, dynamic> body, {
    required String idempotencyKey,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.appointments,
        data: body,
        options: Options(
          headers: {'Idempotency-Key': idempotencyKey},
          extra: {'idempotent': true},
        ),
      );
      return AppointmentDto.fromJson(res.data!['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _asException(e);
    }
  }

  @override
  Future<AppointmentDto> update(String id, Map<String, dynamic> body, {int? version}) async {
    try {
      final res = await _dio.patch<Map<String, dynamic>>(
        ApiEndpoints.appointment(id),
        data: body,
        options: Options(headers: {if (version != null) 'If-Match': '"$version"'}),
      );
      return AppointmentDto.fromJson(res.data!['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _asException(e);
    }
  }

  @override
  Future<AppointmentDto> cancel(String id, {String? reason}) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.cancelAppointment(id),
        data: {if (reason != null) 'reason': reason},
        options: Options(
          headers: {'Idempotency-Key': 'cancel:$id'},
          extra: {'idempotent': true},
        ),
      );
      return AppointmentDto.fromJson(res.data!['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _asException(e);
    }
  }

  @override
  Future<AppointmentDto> reschedule(String id, DateTime newStart) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.rescheduleAppointment(id),
        data: {'starts_at': newStart.toUtc().toIso8601String()},
        options: Options(
          headers: {'Idempotency-Key': 'reschedule:$id:${newStart.toUtc().toIso8601String()}'},
          extra: {'idempotent': true},
        ),
      );
      return AppointmentDto.fromJson(res.data!['data'] as Map<String, dynamic>);
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
      ConflictFailure(:final code) => const ConflictException('conflict', code: code),
      ValidationFailure() => const ServerException('validation', statusCode: 422),
      ServerFailure(:final statusCode) => const ServerException('server', statusCode: statusCode),
      NetworkFailure() || TimeoutFailure() => const NetworkException('network'),
      _ => const ServerException('unknown'),
    };
  }
}
