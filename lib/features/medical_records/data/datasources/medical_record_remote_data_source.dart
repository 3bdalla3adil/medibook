import 'package:dio/dio.dart';

import '../models/medical_record_entry_dto.dart';

abstract interface class MedicalRecordRemoteDataSource {
  Future<List<MedicalRecordEntryDto>> fetchEntries(String patientId);
}

class DioMedicalRecordRemoteDataSource implements MedicalRecordRemoteDataSource {
  DioMedicalRecordRemoteDataSource(this._dio);
  final Dio _dio;

  @override
  Future<List<MedicalRecordEntryDto>> fetchEntries(String patientId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/patients/' + patientId + '/medical-record',
    );
    final data = response.data?['data'];
    if (data is! List) return const [];
    return data.whereType<Map<String, dynamic>>()
        .map(MedicalRecordEntryDto.fromJson).toList(growable: false);
  }
}
