import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

/// Optional certificate fingerprint pinning.
///
/// Configure pins as SHA-256 fingerprints of the complete DER certificate,
/// encoded as lowercase hexadecimal. Keep at least one backup certificate
/// during certificate rotation. Never enable pinning without testing rotation
/// and recovery procedures on every supported platform.
class CertificatePinning {
  const CertificatePinning({
    required this.enabled,
    required this.pinsByHost,
  });

  final bool enabled;
  final Map<String, Set<String>> pinsByHost;

  bool get isConfigured => pinsByHost.values.any((pins) => pins.isNotEmpty);

  void apply(Dio dio) {
    if (!enabled || !isConfigured) return;

    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) {
          final pins = pinsByHost[host];
          if (pins == null || pins.isEmpty) {
            return false;
          }

          final fingerprint = sha256
              .convert(cert.der)
              .toString()
              .toLowerCase();

          return pins.map(_normalize).contains(fingerprint);
        };
        return client;
      },
    );
  }

  String _normalize(String value) =>
      value.replaceAll(':', '').replaceAll(' ', '').toLowerCase();
}
