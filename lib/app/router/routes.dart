abstract final class Routes {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const forbidden = '/forbidden';

  static const dashboard = '/';
  static const appointments = '/appointments';
  static const bookAppointment = '/appointments/book';
  static const services = '/services';
  static const medicalRecords = '/records';

  static const telehealthLobby = '/telehealth';
  static String telehealthSession(String appointmentId) => '/telehealth/$appointmentId';

  static String appointmentDetails(String id) => '/appointments/$id';

  static const settings = '/settings';
  static const doctors = '/doctors';
  static const clinics = '/clinics';
  static const consultations = '/consultations';
  static const prescriptions = '/prescriptions';
  static const doctorPatients = '/doctor/patients';
  static const adminPatients = '/admin/patients';
  static const billing = '/billing';
}
