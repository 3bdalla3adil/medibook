import 'package:dio/dio.dart';

import '../models/consultation_dto.dart';

abstract interface class ConsultationRemoteDataSource {
  Future<List<ConsultationDto>> fetchConsultations();
  Future<ConsultationDto?> fetchConsultation(String id);
  Future<ConsultationDto> start(String appointmentId);
  Future<ConsultationDto> complete(String id);
}

class DioConsultationRemoteDataSource implements ConsultationRemoteDataSource {
  DioConsultationRemoteDataSource(this._dio);
  final Dio _dio;

  @override
  Future<List<ConsultationDto>> fetchConsultations() async {
    final response = await _dio.get<Map<String, dynamic>>('/consultations');
    return _list(response.data).map(ConsultationDto.fromJson).toList(growable: false);
  }

  @override
  Future<ConsultationDto?> fetchConsultation(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/consultations/' + id);
    final data = response.data?['data'];
    return data is Map<String, dynamic> ? ConsultationDto.fromJson(data) : null;
  }

  @override
  Future<ConsultationDto> start(String appointmentId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/consultations',
      data: {'appointment_id': appointmentId},
    );
    return ConsultationDto.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  @override
  Future<ConsultationDto> complete(String id) async {
    final response = await _dio.post<Map<String, dynamic>>('/consultations/' + id + '/complete');
    return ConsultationDto.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  List<Map<String, dynamic>> _list(Map<String, dynamic>? body) {
    final data = body?['data'];
    return data is List ? data.whereType<Map<String, dynamic>>().toList() : const [];
  }
}
