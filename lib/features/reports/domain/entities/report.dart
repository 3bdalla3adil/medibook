import 'package:equatable/equatable.dart';

class ReportQuery extends Equatable {
  const ReportQuery({required this.from, required this.to, this.clinicId});
  final DateTime from; final DateTime to; final String? clinicId;
  @override List<Object?> get props => [from, to, clinicId];
}

class ReportResult extends Equatable {
  const ReportResult({required this.reportId, required this.generatedAt, required this.values});
  final String reportId; final DateTime generatedAt; final Map<String, num> values;
  @override List<Object?> get props => [reportId, generatedAt, values];
}
