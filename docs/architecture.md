# MediBook Architecture

MediBook is a feature-first Flutter application for multi-clinic medical appointments and telehealth.

## Dependency direction

Presentation -> Domain -> Data -> Remote/Local infrastructure.

Presentation must not import Dio, Hive, secure storage, or other infrastructure packages directly.

## Feature boundary

Each business capability owns its presentation, domain, and data code:

lib/features/<feature>/
- data/
  - datasources/
  - models/
  - repositories/
- domain/
  - entities/
  - repositories/
  - usecases/
- presentation/
  - bloc/
  - pages/
  - widgets/

Core contains cross-cutting infrastructure only: configuration, dependency injection, errors, networking, security, local storage, synchronization, utilities, and reusable widgets.

## Backend independence

Domain repository contracts are backend-neutral. Data implementations can target REST API, Odoo REST/RPC, Firebase, or another backend adapter. The presentation layer must not depend on the selected backend.

## Offline-first flow

UI -> BLoC -> Use Case -> Repository -> Local cache / Remote API.

Writes can enter the encrypted local store and outbox when offline, then synchronize when connectivity returns. Server-side validation remains authoritative for clinical operations such as appointment availability and double-booking prevention.

## Security boundary

Authentication tokens belong in secure storage. Clinical data cached locally must use encrypted storage and explicit retention policies. Logs must be PHI-safe. Production must use HTTPS and must not rely on Flutter assert statements for security validation.

Certificate pinning is an optional operational control and must be configured with tested certificate rotation and recovery procedures before production enablement.

## Current foundation

- Authentication
- Patient dashboard
- Appointment repository with cache/offline outbox
- Patient profile
- Telehealth repository abstraction
- Arabic/English localization foundation
- RTL-aware Material 3 UI
- Secure token storage
- Dio networking and interceptors
- Hive-based local store
- Synchronization engine
- Security extension points
- Unit/widget tests
- CI analysis, tests, Android build, and unsigned iOS build

Additional clinical capabilities should be added as independent features rather than expanding a global service/controller layer.
