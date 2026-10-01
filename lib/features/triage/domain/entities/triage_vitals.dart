import 'package:equatable/equatable.dart';

class TriageVitals extends Equatable {
  const TriageVitals({
    this.bloodPressureSystolic,
    this.bloodPressureDiastolic,
    this.heartRate,
    this.temperatureC,
    this.spo2,
    this.weightKg,
    this.heightCm,
    this.respiratoryRate,
    this.painScore,
    this.note,
    this.urgent = false,
  });
  final int? bloodPressureSystolic;
  final int? bloodPressureDiastolic;
  final int? heartRate;
  final double? temperatureC;
  final int? spo2;
  final double? weightKg;
  final double? heightCm;
  final int? respiratoryRate;
  final int? painScore;
  final String? note;
  final bool urgent;
  @override
  List<Object?> get props => [bloodPressureSystolic,bloodPressureDiastolic,heartRate,temperatureC,spo2,weightKg,heightCm,respiratoryRate,painScore,note,urgent];
}
