import 'package:dio/dio.dart';

import '../models/prescription_dto.dart';

abstract interface class PrescriptionRemoteDataSource {
  Future<List<PrescriptionDto>> fetchPrescriptions();
}

class DioPrescriptionRemoteDataSource implements PrescriptionRemoteDataSource {
  DioPrescriptionRemoteDataSource(this._dio);
  final Dio _dio;

  @override
  Future<List<PrescriptionDto>> fetchPrescriptions() async {
    final response = await _dio.get<Map<String, dynamic>>('/prescriptions');
    final data = response.data?['data'];
    if (data is! List) return const [];
    return data.whereType<Map<String, dynamic>>()
        .map(PrescriptionDto.fromJson).toList(growable: false);
  }
}
