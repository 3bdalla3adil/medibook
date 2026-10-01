import 'package:dio/dio.dart';
import '../models/triage_vitals_dto.dart';

abstract interface class TriageRemoteDataSource {
  Future<TriageVitalsDto?> fetch(String appointmentId);
  Future<TriageVitalsDto> save(String appointmentId, TriageVitalsDto dto);
}

class DioTriageRemoteDataSource implements TriageRemoteDataSource {
  DioTriageRemoteDataSource(this._dio);
  final Dio _dio;
  @override
  Future<TriageVitalsDto?> fetch(String appointmentId) async {
    final response = await _dio.get<Map<String,dynamic>>('/appointments/$appointmentId/triage');
    final data=response.data?['data'];
    if(data is! Map<String,dynamic>) return null;
    return TriageVitalsDto.fromJson(data);
  }
  @override
  Future<TriageVitalsDto> save(String appointmentId,TriageVitalsDto dto) async {
    final response=await _dio.patch<Map<String,dynamic>>('/appointments/$appointmentId/triage',data:dto.toJson());
    final data=response.data?['data'];
    if(data is! Map<String,dynamic>) throw StateError('Invalid triage response');
    return TriageVitalsDto.fromJson(data);
  }
}
