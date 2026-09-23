import '../../../../core/error/result.dart';
import '../entities/report.dart';

abstract interface class ReportRepository {
  /// [SERVER-ENFORCED] Backend computes and authorizes aggregations.
  Future<Result<ReportResult>> getReport(String reportId, ReportQuery query);
}
