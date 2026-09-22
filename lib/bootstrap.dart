import 'dart:async';

import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/config/config_loader.dart';
import 'core/firebase/firebase_initializer.dart';
import 'core/di/register_core.dart';
import 'core/di/register_features.dart';
import 'core/security/secure_logger.dart';

Future<void> bootstrap() async {
  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (details) {
        SecureLogger('FlutterError').error(
          'Uncaught UI error',
          error: details.exception,
          st: details.stack,
        );
      };

      final config = ConfigLoader.load();
      if (config.enableFirebaseAuth) {
        await initializeFirebase();
      }

      Future<void> onSessionExpired() async {
        // AuthBloc observes the token clear via its stream listener.
      }

      await registerCore(config, onSessionExpired: onSessionExpired);
      await registerFeatures();

      runApp(const MediBookApp());
    },
    (error, stack) {
      SecureLogger('Zone').error('Uncaught async error', error: error, st: stack);
    },
  );
}
