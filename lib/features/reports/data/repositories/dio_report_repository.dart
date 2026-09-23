import 'package:dio/dio.dart';
import '../../../../core/error/result.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/report.dart';
import '../../domain/repositories/report_repository.dart';

class DioReportRepository implements ReportRepository {
  DioReportRepository(this._dio); final Dio _dio;
  @override Future<Result<ReportResult>> getReport(String reportId, ReportQuery query) async {
    final result = await guard(() => _dio.get<Map<String, dynamic>>(ApiEndpoints.reports + '/' + reportId, queryParameters:{'from':query.from.toUtc().toIso8601String(),'to':query.to.toUtc().toIso8601String(),if(query.clinicId != null)'clinic_id':query.clinicId}));
    return result.map((response){ final data=response.data!['data'] as Map<String,dynamic>; final values=<String,num>{}; final raw=data['values']; if(raw is Map){raw.forEach((k,v){if(v is num) values[k.toString()]=v;});} return ReportResult(reportId:reportId,generatedAt:DateTime.parse(data['generated_at'].toString()).toUtc(),values:values); });
  }
}
