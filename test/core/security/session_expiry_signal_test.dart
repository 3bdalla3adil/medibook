import 'package:flutter_test/flutter_test.dart';
import 'package:medibook/core/security/session_expiry_signal.dart';

void main() {
  test('publishes session expiry events', () async {
    final signal = SessionExpirySignal();
    final future = signal.stream.first;
    signal.notify();
    await future;
    await signal.dispose();
  });
}
