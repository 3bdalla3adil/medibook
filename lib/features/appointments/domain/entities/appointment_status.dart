enum AppointmentStatus {
  scheduled,
  checkedIn,
  inConsultation,
  completed,
  cancelled,
  noShow;

  static AppointmentStatus fromWire(String value) => switch (value) {
        'scheduled' => AppointmentStatus.scheduled,
        'checked_in' => AppointmentStatus.checkedIn,
        'in_consultation' => AppointmentStatus.inConsultation,
        'completed' => AppointmentStatus.completed,
        'cancelled' => AppointmentStatus.cancelled,
        'no_show' => AppointmentStatus.noShow,
        _ => throw ArgumentError('Unknown appointment status: $value'),
      };

  String toWire() => switch (this) {
        AppointmentStatus.scheduled => 'scheduled',
        AppointmentStatus.checkedIn => 'checked_in',
        AppointmentStatus.inConsultation => 'in_consultation',
        AppointmentStatus.completed => 'completed',
        AppointmentStatus.cancelled => 'cancelled',
        AppointmentStatus.noShow => 'no_show',
      };

  bool get isTerminal =>
      this == AppointmentStatus.completed ||
      this == AppointmentStatus.cancelled ||
      this == AppointmentStatus.noShow;

  bool get isActive => !isTerminal;

  bool get isJoinable =>
      this == AppointmentStatus.scheduled || this == AppointmentStatus.checkedIn;

  Set<AppointmentStatus> get allowedNext => switch (this) {
        AppointmentStatus.scheduled => {
            AppointmentStatus.checkedIn,
            AppointmentStatus.cancelled,
            AppointmentStatus.noShow,
          },
        AppointmentStatus.checkedIn => {
            AppointmentStatus.inConsultation,
            AppointmentStatus.cancelled,
            AppointmentStatus.noShow,
          },
        AppointmentStatus.inConsultation => {AppointmentStatus.completed},
        AppointmentStatus.completed => const {},
        AppointmentStatus.cancelled => const {},
        AppointmentStatus.noShow => const {},
      };

  bool canTransitionTo(AppointmentStatus next) => allowedNext.contains(next);
}
