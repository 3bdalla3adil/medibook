import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Initializes Firebase once.
///
/// Android/iOS use the native configuration produced by
/// `flutterfire configure` (google-services.json / GoogleService-Info.plist).
/// Web must use a FlutterFire-generated `firebase_options.dart`; this project
/// deliberately does not invent Firebase credentials in source control.
Future<void> initializeFirebase() async {
  if (Firebase.apps.isNotEmpty) return;

  if (kIsWeb) {
    throw StateError(
      'Firebase web is enabled but no FlutterFire web configuration is '
      'available. Run "flutterfire configure" and commit the generated '
      'firebase_options.dart.',
    );
  }

  try {
    await Firebase.initializeApp();
  } on FirebaseException catch (error) {
    throw StateError(
      'Firebase could not initialize. For Android/iOS, run '
      '"flutterfire configure" and ensure the generated native Firebase '
      'configuration is present. Firebase error: ${error.code}',
    );
  }
}
