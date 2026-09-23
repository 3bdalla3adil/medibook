# Production Release Hardening

## Signing

### Android
- Generate a release keystore outside source control.
- Store keystore material and passwords only in CI secrets.
- Configure the release signing configuration in the generated Android project.
- Never commit the keystore or signing passwords.

### iOS
- Requires an Apple Developer account and distribution signing assets.
- Store certificates/profiles securely in CI.
- Keep ExportOptions.plist environment-specific.

## Environments

Staging and production must use separate Firebase projects and separate backend infrastructure.

Production promotion requires tests, integration tests against the test backend, security checks, a signed build, staging promotion and a documented rollback artifact/procedure.

Backend deployment should use blue/green or canary rollout where supported.
