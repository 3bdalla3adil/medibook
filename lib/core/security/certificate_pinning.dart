import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

class CertificatePinning {
  const CertificatePinning({required this.enabled, required this.pinsByHost});

  final bool enabled;
  final Map<String, Set<String>> pinsByHost;

  void apply(Dio dio) {
    if (!enabled) return;

    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) {
          final pins = pinsByHost[host];
          if (pins == null || pins.isEmpty) return false;
          final spki = _spkiSha256(cert);
          return pins.contains(spki);
        };
        return client;
      },
    );
  }

  String _spkiSha256(X509Certificate cert) =>
      throw UnimplementedError('Wire ASN.1 SPKI extraction before enabling.');
}
