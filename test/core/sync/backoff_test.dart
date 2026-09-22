import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:medibook/core/sync/backoff.dart';

void main() {
  group('Backoff.forAttempt', () {
    test('respects exponential cap growth', () {
      final seedA = Random(1);
      final seedB = Random(1);
      final d0 = Backoff.forAttempt(0, random: seedA);
      final d5 = Backoff.forAttempt(5, random: seedB);
      expect(d0.inMilliseconds, lessThanOrEqualTo(2000));
      expect(d5.inMilliseconds, lessThanOrEqualTo(64000));
    });

    test('never returns below the 500ms floor', () {
      final rnd = Random(42);
      for (var i = 0; i < 200; i++) {
        final d = Backoff.forAttempt(0, random: rnd);
        expect(d.inMilliseconds, greaterThanOrEqualTo(500));
      }
    });

    test('respects hard cap', () {
      final rnd = Random(7);
      for (var attempt = 0; attempt < 30; attempt++) {
        final d = Backoff.forAttempt(
          attempt,
          random: rnd,
          cap: const Duration(seconds: 5),
        );
        expect(d.inSeconds, lessThanOrEqualTo(5));
      }
    });
  });
}
