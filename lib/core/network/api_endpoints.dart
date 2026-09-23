abstract final class ApiEndpoints {
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const refresh = '/auth/refresh';
  static const logout = '/auth/logout';
  static const me = '/auth/me';

  static const appointments = '/appointments';
  static const clinics = '/clinics';
  static const services = '/medical-services';
  static const doctors = '/doctors';
  static const availability = '/appointments/availability';
  static const patients = '/patients';
  static const consultations = '/consultations';
  static const prescriptions = '/prescriptions';
  static const medicalRecords = '/medical-records';
  static String appointment(String id) => '/appointments/$id';
  static String cancelAppointment(String id) => '/appointments/$id/cancel';
  static String rescheduleAppointment(String id) => '/appointments/$id/reschedule';
  static String doctor(String id) => '/doctors/$id';
  static String doctorAvailability(String id) => '/doctors/$id/availability';
  static String clinic(String id) => '/clinics/$id';
  static String clinicServices(String id) => '/clinics/$id/services';
  static String service(String id) => '/medical-services/$id';
  static String patientRecord(String id) => '/patients/$id/medical-record';

  static const telehealthSession = '/telehealth/sessions';
  static String telehealthJoin(String sessionId) => '/telehealth/sessions/$sessionId/join';
}
