abstract interface class DeviceIntegrityService {
  Future<DeviceIntegrityResult> check();
}

enum DeviceIntegrityVerdict { trusted, compromised, unavailable }

class DeviceIntegrityResult {
  const DeviceIntegrityResult(this.verdict, {this.reason});
  final DeviceIntegrityVerdict verdict;
  final String? reason;
}

class UnavailableDeviceIntegrityService implements DeviceIntegrityService {
  const UnavailableDeviceIntegrityService();

  @override
  Future<DeviceIntegrityResult> check() async =>
      const DeviceIntegrityResult(
        DeviceIntegrityVerdict.unavailable,
        reason: 'no_platform_implementation',
      );
}
