import '../../features/appointments/data/models/appointment_dto.dart';
import '../../features/doctors/data/models/doctor_dto.dart';
import '../../features/clinics/data/models/clinic_dto.dart';
import '../../features/services/data/models/medical_service_dto.dart';
import '../../features/patients/data/models/patient_dto.dart';
import '../../features/patients/data/datasources/patient_directory_remote_data_source.dart';
import '../../features/medical_records/data/models/medical_record_entry_dto.dart';
import '../../features/consultations/data/models/consultation_dto.dart';
import '../../features/prescriptions/data/models/prescription_dto.dart';

abstract final class DemoSeed {
  static const patientId = 'demo-patient-001';
  static const organizationId = 'demo-org-001';
  static const clinicId = 'demo-clinic-001';
  static const doctorId = 'demo-doctor-001';
  static const serviceId = 'demo-service-001';

  static PatientDto patient() => PatientDto({
        'id': patientId,
        'display_name': 'Demo Patient',
        'organization_id': organizationId,
        'preferred_locale': 'en',
        'date_of_birth': '1995-05-10',
      });

  static List<AppointmentDto> appointments() => [
        AppointmentDto(_appointmentJson(
          id: 'demo-appointment-001',
          doctorName: 'Dr. Demo',
          serviceName: 'General Consultation',
          startsAt: '2026-10-05T09:00:00Z',
          telehealth: true,
        )),
        AppointmentDto(_appointmentJson(
          id: 'demo-appointment-002',
          doctorName: 'Dr. Demo',
          serviceName: 'Follow-up Consultation',
          startsAt: '2026-10-20T11:00:00Z',
          telehealth: false,
        )),
      ];

  static Map<String, dynamic> _appointmentJson({
    required String id,
    required String doctorName,
    required String serviceName,
    required String startsAt,
    required bool telehealth,
  }) => {
        'id': id,
        'clinic_id': clinicId,
        'clinic_name': 'MediBook Demo Clinic',
        'patient_id': patientId,
        'doctor_id': doctorId,
        'doctor_name': doctorName,
        'service_id': serviceId,
        'service_name': serviceName,
        'starts_at': startsAt,
        'duration_minutes': 30,
        'status': 'scheduled',
        'is_telehealth': telehealth,
        'room_label': telehealth ? 'Demo Room' : 'Room 101',
        'notes': 'Deterministic demo appointment.',
        'created_at': '2026-01-01T00:00:00Z',
        'updated_at': '2026-01-01T00:00:00Z',
        'version': 1,
      };

  static List<ClinicDto> clinics() => [
        ClinicDto({
          'id': clinicId,
          'name': {'en': 'MediBook Demo Clinic', 'ar': 'عيادة ميديبوك التجريبية'},
          'address': 'Demo Street',
          'timezone': 'Africa/Khartoum',
          'phone': '+249000000000',
          'organization_id': organizationId,
          'services': [serviceId],
          'is_active': true,
        }),
      ];

  static List<MedicalServiceDto> services() => [
        MedicalServiceDto({
          'id': serviceId,
          'name': 'General Consultation',
          'description': 'Demo consultation service',
          'duration_minutes': 30,
          'price': 0,
          'currency': 'USD',
          'clinic_id': clinicId,
          'is_telehealth_available': true,
        }),
      ];

  static List<DoctorDto> doctors() => [
        DoctorDto({
          'id': doctorId,
          'display_name': 'Dr. Demo',
          'specialization': 'General Medicine',
          'license_number': 'DEMO-001',
          'bio': 'Demo clinician profile.',
          'clinic_ids': [clinicId],
          'service_ids': [serviceId],
          'languages': ['en', 'ar'],
        }),
      ];

  static List<PatientSummaryDto> patients() => [
        PatientSummaryDto({
          'id': patientId,
          'display_name': 'Demo Patient',
          'date_of_birth': '1995-05-10',
          'last_visit': '2026-09-01T10:00:00Z',
          'primary_clinic_id': clinicId,
        }),
      ];

  static List<MedicalRecordEntryDto> records() => [
        MedicalRecordEntryDto({
          'id': 'demo-record-001',
          'created_by': doctorId,
          'created_at': '2026-09-01T10:00:00Z',
          'recorded_by': doctorId,
          'recorded_at': '2026-09-01T10:00:00Z',
          'source': 'clinician_entered',
          'title': 'Demo consultation note',
          'body': 'This is deterministic demo clinical content.',
        }),
      ];

  static List<ConsultationDto> consultations() => [
        ConsultationDto({
          'id': 'demo-consultation-001',
          'appointment_id': 'demo-appointment-001',
          'patient_id': patientId,
          'doctor_id': doctorId,
          'started_at': '2026-09-01T10:00:00Z',
          'status': 'completed',
          'note': 'Demo consultation',
          'diagnosis': 'Routine follow-up',
        }),
      ];

  static List<PrescriptionDto> prescriptions() => [
        PrescriptionDto({
          'id': 'demo-prescription-001',
          'consultation_id': 'demo-consultation-001',
          'patient_id': patientId,
          'prescriber_id': doctorId,
          'issued_at': '2026-09-01T10:30:00Z',
          'status': 'issued',
          'items': [
            {
              'medication_id': 'demo-medication-001',
              'medication_name': 'Demo Medication',
              'dose': '1 tablet',
              'route': 'oral',
              'frequency': 'once daily',
              'duration': '7 days',
              'quantity': 7,
              'instructions': 'Demo instructions only.',
            },
          ],
        }),
      ];
}
