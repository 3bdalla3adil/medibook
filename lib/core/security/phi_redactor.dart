abstract final class PhiRedactor {
  static const _mask = '***';

  static const _sensitiveKeys = <String>{
    'password', 'passwd', 'secret', 'token', 'access_token', 'refresh_token',
    'authorization', 'auth', 'api_key', 'apikey', 'otp', 'pin', 'cvv',
    'ssn', 'national_id', 'nationalid', 'iqama', 'emirates_id', 'mrn',
    'medical_record_number', 'dob', 'date_of_birth', 'email', 'phone',
    'mobile', 'address', 'insurance_id', 'policy_number', 'diagnosis',
    'prescription', 'medication', 'notes', 'chief_complaint', 'full_name',
    'first_name', 'last_name', 'patient_name', 'card_number', 'iban',
  };

  static final _email = RegExp(r'[\w.\-+]+@[\w\-]+\.[\w.\-]+');
  static final _jwt = RegExp(r'eyJ[A-Za-z0-9_\-]{8,}\.[A-Za-z0-9_\-]{8,}\.[A-Za-z0-9_\-]{8,}');
  static final _bearer = RegExp(r'(?i)\b(bearer|basic)\s+[A-Za-z0-9._\-+/=]{8,}');
  static final _phone = RegExp(r'(?:\+|00)?\d[\d\s\-().]{7,}\d');
  static final _uuid = RegExp(
    r'\b[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\b',
  );
  static final _querySecret =
      RegExp(r'(?i)\b(token|key|secret|password|sig|signature)=([^&\s]+)');

  static String redact(String input) {
    var out = input;
    out = out.replaceAllMapped(_bearer, (m) => '${m[1]} $_mask');
    out = out.replaceAll(_jwt, _mask);
    out = out.replaceAll(_email, _mask);
    out = out.replaceAll(_uuid, _mask);
    out = out.replaceAllMapped(_querySecret, (m) => '${m[1]}=$_mask');
    out = out.replaceAll(_phone, _mask);
    return out;
  }

  static Object? redactValue(Object? value, {String? key, int depth = 0}) {
    if (depth > 8) return _mask;
    if (key != null && _sensitiveKeys.contains(key.toLowerCase())) {
      return value == null ? null : _mask;
    }
    return switch (value) {
      null => null,
      String s => redact(s),
      num || bool => value,
      Map m => m.map(
          (k, v) => MapEntry(
            k.toString(),
            redactValue(v, key: k.toString(), depth: depth + 1),
          ),
        ),
      Iterable it => it.map((e) => redactValue(e, depth: depth + 1)).toList(),
      _ => _mask,
    };
  }

  static String redactUri(Uri uri) {
    final safeQuery = uri.queryParameters.map(
      (k, v) => MapEntry(k, _sensitiveKeys.contains(k.toLowerCase()) ? _mask : redact(v)),
    );
    return Uri(
      scheme: uri.scheme,
      host: uri.host,
      path: uri.pathSegments.map((s) => _uuid.hasMatch(s) ? _mask : s).join('/'),
      queryParameters: safeQuery.isEmpty ? null : safeQuery,
    ).toString();
  }
}
