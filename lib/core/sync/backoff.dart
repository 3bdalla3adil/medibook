import 'dart:math';

abstract final class Backoff {
  static Duration forAttempt(
    int attempt, {
    Duration base = const Duration(seconds: 2),
    Duration cap = const Duration(minutes: 15),
    Random? random,
  }) {
    final rnd = random ?? Random();
    final expMs = base.inMilliseconds * pow(2, attempt.clamp(0, 20)).toInt();
    final cappedMs = min(expMs, cap.inMilliseconds);
    final jitteredMs = rnd.nextInt(cappedMs + 1);
    return Duration(milliseconds: max(jitteredMs, 500));
  }
}
