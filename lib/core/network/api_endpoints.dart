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
  static String appointment(String id) => '/appointments/$id';
  static String cancelAppointment(String id) => '/appointments/$id/cancel';
  static String rescheduleAppointment(String id) => '/appointments/$id/reschedule';

  static const telehealthSession = '/telehealth/sessions';
  static String telehealthJoin(String sessionId) => '/telehealth/sessions/$sessionId/join';
}
