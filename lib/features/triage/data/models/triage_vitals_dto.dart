import '../../domain/entities/triage_vitals.dart';

class TriageVitalsDto {
  const TriageVitalsDto({required this.data});
  factory TriageVitalsDto.fromJson(Map<String, dynamic> json) {
    double? d(dynamic v) => v is num ? v.toDouble() : null;
    int? i(dynamic v) => v is num ? v.toInt() : null;
    return TriageVitalsDto(data: TriageVitals(
      bloodPressureSystolic:i(json['blood_pressure_systolic']),
      bloodPressureDiastolic:i(json['blood_pressure_diastolic']),
      heartRate:i(json['heart_rate']),
      temperatureC:d(json['temperature_c']),
      spo2:i(json['spo2']),
      weightKg:d(json['weight_kg']),
      heightCm:d(json['height_cm']),
      respiratoryRate:i(json['respiratory_rate']),
      painScore:i(json['pain_score']),
      note:json['note'] as String?,
      urgent:json['urgent'] == true,
    ));
  }
  final TriageVitals data;
  Map<String,dynamic> toJson()=> {
    'blood_pressure_systolic':data.bloodPressureSystolic,
    'blood_pressure_diastolic':data.bloodPressureDiastolic,
    'heart_rate':data.heartRate,
    'temperature_c':data.temperatureC,
    'spo2':data.spo2,
    'weight_kg':data.weightKg,
    'height_cm':data.heightCm,
    'respiratory_rate':data.respiratoryRate,
    'pain_score':data.painScore,
    'note':data.note,
    'urgent':data.urgent,
  };
}
