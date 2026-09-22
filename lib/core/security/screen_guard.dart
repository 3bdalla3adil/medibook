abstract interface class ScreenGuard {
  Future<void> enable();
  Future<void> disable();
}

class NoopScreenGuard implements ScreenGuard {
  const NoopScreenGuard();
  @override
  Future<void> enable() async {}
  @override
  Future<void> disable() async {}
}
