# Device Integrity

The current repository exposes DeviceIntegrityService but uses UnavailableDeviceIntegrityService.

Production activation requires Android Play Integrity with server-side token verification and iOS App Attest with server-side attestation verification, plus a backend decision endpoint and an approved failure policy.

Do not treat a client-only integrity verdict as authorization.
