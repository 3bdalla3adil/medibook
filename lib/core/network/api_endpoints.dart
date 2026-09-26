abstract final class ApiEndpoints {
  static const firebaseExchange = '/medibook/api/auth/exchange';
  static const login = '/medibook/api/auth/exchange';
  static const register = '/medibook/api/auth/exchange';
  static const refresh = '/medibook/api/auth/exchange';
  static const logout = '/medibook/api/auth/logout';
  static const me = '/medibook/api/auth/me';
  static const profile = '/medibook/api/profile';

  static const appointments = '/medibook/api/appointments';
  static const clinics = '/medibook/api/clinics';
  static const services = '/medibook/api/medical-services';
  static const doctors = '/medibook/api/doctors';
  static const availability = '/medibook/api/appointments/availability';
  static const patients = '/medibook/api/patients';
  static const consultations = '/medibook/api/consultations';
  static const prescriptions = '/medibook/api/prescriptions';
  static const medicalRecords = '/medibook/api/medical-records';
  static const billingInvoices = '/medibook/api/billing/invoices';
  static const billingPayments = '/medibook/api/billing/payments';
  static const audit = '/medibook/api/audit';
  static const reports = '/medibook/api/reports';
  static String appointment(String id) => '/medibook/api/appointments/$id';
  static String cancelAppointment(String id) => '/medibook/api/appointments/$id/cancel';
  static String rescheduleAppointment(String id) => '/medibook/api/appointments/$id/reschedule';
  static String doctor(String id) => '/medibook/api/doctors/$id';
  static String doctorAvailability(String id) => '/medibook/api/doctors/$id/availability';
  static String clinic(String id) => '/medibook/api/clinics/$id';
  static String clinicServices(String id) => '/medibook/api/clinics/$id/services';
  static String service(String id) => '/medibook/api/medical-services/$id';
  static String patientRecord(String id) => '/medibook/api/patients/$id/medical-record';

  static const telehealthSession = '/medibook/api/telehealth/sessions';
  static String telehealthJoin(String sessionId) => '/medibook/api/telehealth/sessions/$sessionId/join';
}
