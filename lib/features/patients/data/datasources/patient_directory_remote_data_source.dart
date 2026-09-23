import 'package:dio/dio.dart';

import '../../domain/entities/patient_summary.dart';

class PatientSummaryDto {
  const PatientSummaryDto(this.json);
  final Map<String, dynamic> json;

  PatientSummary toDomain() => PatientSummary(
        id: json['id'].toString(),
        displayName: json['display_name']?.toString() ?? '',
        dateOfBirth: json['date_of_birth'] == null
            ? null
            : DateTime.tryParse(json['date_of_birth'].toString()),
        lastVisit: json['last_visit'] == null
            ? null
            : DateTime.tryParse(json['last_visit'].toString()),
        primaryClinicId: json['primary_clinic_id']?.toString(),
      );
}

abstract interface class PatientDirectoryRemoteDataSource {
  Future<List<PatientSummaryDto>> fetchPatients();
}

class DioPatientDirectoryRemoteDataSource implements PatientDirectoryRemoteDataSource {
  DioPatientDirectoryRemoteDataSource(this._dio);
  final Dio _dio;

  @override
  Future<List<PatientSummaryDto>> fetchPatients() async {
    final response = await _dio.get<Map<String, dynamic>>('/patients');
    final data = response.data?['data'];
    if (data is! List) return const [];
    return data.whereType<Map<String, dynamic>>()
        .map(PatientSummaryDto.new).toList(growable: false);
  }
}
