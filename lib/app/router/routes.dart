abstract final class Routes {
  static const splash = '/splash';
  static const login = '/login';

  static const dashboard = '/';
  static const appointments = '/appointments';
  static const bookAppointment = '/appointments/book';
  static const services = '/services';
  static const medicalRecords = '/records';

  static const telehealthLobby = '/telehealth';
  static String telehealthSession(String appointmentId) => '/telehealth/$appointmentId';

  static String appointmentDetails(String id) => '/appointments/$id';

  static const settings = '/settings';
}
