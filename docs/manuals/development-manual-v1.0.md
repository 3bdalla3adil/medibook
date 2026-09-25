# MediBook Development Manual v1.0

**Version:** 1.0  
**Repository:** `3bdalla3adil/medibook`  
**Stack:** Flutter / Dart / Firebase adapters / REST-ready architecture  
**Audience:** Developers, reviewers, QA engineers, DevOps engineers

## 1. Development principles

MediBook uses feature-first Clean Architecture.

Dependency direction:

`Presentation -> Domain -> Data -> infrastructure`

Presentation and domain code must not import infrastructure packages such as Dio, Hive, secure storage, or Firebase SDKs directly.

Backend implementations remain behind domain repository contracts so the application can use REST, Odoo REST/RPC, Firebase, or another backend adapter without coupling the UI to infrastructure.

## 2. Repository structure

```
lib/
  app/
    router/
    theme/
  core/
    config/
    di/
    error/
    network/
    security/
    storage/
    sync/
  features/
    auth/
    appointments/
    dashboard/
    patients/
    doctors/
    clinics/
    services/
    consultations/
    medical_records/
    prescriptions/
    notifications/
    billing/
    reports/
    audit/
    telehealth/
  l10n/
```

A feature should own its data, domain and presentation layers.

## 3. Local setup

Install Flutter and the project dependencies, then run:

```bash
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
flutter run
```

The exact Flutter SDK should be the version selected by CI for the repository. Do not silently change the toolchain when diagnosing a build problem.

## 4. Environment configuration

Configuration is supplied through Dart defines.

Important configuration areas include:

- `APP_ENV`
- `API_BASE_URL`
- `API_VERSION`
- `ENABLE_DEMO_AUTH`
- `ENABLE_FIREBASE_AUTH`
- certificate-pinning configuration
- device-integrity configuration
- screen-guard configuration
- offline/outbox configuration

Production configuration rejects unsafe values such as demo authentication and non-HTTPS API endpoints.

Never commit production secrets, Firebase service-account credentials, signing keys or private certificates.

## 5. Demo authentication

The demo provider contains three deterministic identities:

- `demo-patient-001`
- `demo-doctor-001`
- `demo-admin-001`

The provider supports local login and can delegate non-demo authentication to Firebase when Firebase authentication is enabled.

Demo access tokens are generated locally with role-specific identifiers. They are development/staging credentials and must not be used as real authentication credentials.

## 6. Demo dashboard design

Demo users must not be sent into a dashboard that immediately requires an unavailable clinical backend.

`RoleDashboardPage` accepts an optional authenticated user for deterministic widget testing. In production routing it reads the current user from `AuthBloc`.

Demo identities are detected by their controlled `demo-` IDs and use a local role dashboard.

Workflow cards in the demo dashboard open demo-safe workflow pages. This prevents the demo from appearing to authenticate successfully and then becoming a blank/dead screen because a backend endpoint is unavailable.

This behavior is intentionally separate from production clinical workflows.

## 7. Authentication lifecycle

`AuthBloc` manages:

- bootstrap/session restoration,
- login,
- registration,
- logout,
- session expiry.

`AuthGuard` controls routing based on authentication state and route requirements.

Authentication is not authorization. The backend must independently enforce:

- identity,
- organization/tenant scope,
- role,
- object ownership,
- clinical permissions,
- billing permissions,
- audit requirements.

## 8. Routing

Routes are centralized in:

`lib/app/router/routes.dart`

The router is configured in:

`lib/app/router/app_router.dart`

When adding a route:

1. define its route constant,
2. add the presentation implementation,
3. define authorization requirements,
4. add loading/error/empty/offline states where applicable,
5. add tests,
6. avoid adding a placeholder route merely to make the navigation tree look complete.

## 9. Appointments

The appointment architecture contains domain entities, repository contracts, data implementations and presentation flows.

The booking client can request:

- clinics,
- medical services,
- doctors,
- availability.

The backend must revalidate all booking-critical values. Never rely on a client-provided slot, price, duration, doctor, clinic, patient identity or permission.

## 10. Offline synchronization

The application contains local caching and an outbox/synchronization foundation.

Conflict policy:

- appointments: server authoritative / re-fetch,
- patient profile: field-level merge with user prompt,
- clinical notes: human review; no automatic merge,
- prescriptions: server authoritative; no client mutation after issue.

Clinical data must not be automatically merged using generic last-write-wins semantics.

## 11. Telehealth

The telehealth contract is documented in `docs/api/telehealth-contract.md`.

Provider: Daily.

Expected backend lifecycle:

```
POST /telehealth/sessions
POST /telehealth/sessions/{id}/joined
POST /telehealth/sessions/{id}/end
POST /telehealth/sessions/{id}/join
```

Join tokens:

- must be single-use,
- must expire in less than 15 minutes,
- must never be logged,
- must not be stored as ordinary application data.

The backend decides whether the actor can join the appointment.

Leaving a telehealth room must not automatically complete a clinical consultation.

## 12. Notifications

Notification responsibilities are split deliberately:

- Firestore: in-app notification data,
- FCM: push delivery,
- backend: SMS/email delivery.

Push payloads must not contain clinical content. Send a notification identifier and retrieve the protected content after authentication.

The client must never create audit records or clinical notification records by pretending to be the authoritative backend.

## 13. Billing, reports and audit

Billing has domain contracts for:

- invoices,
- invoice lines,
- payments,
- refunds,
- payment methods.

Do not implement client-side payment authority or PCI-sensitive behavior without a defined backend payment model.

Reports should consume backend aggregations rather than calculate business analytics from incomplete mobile lists.

Audit logs are read-only from the mobile client. Audit entries must be written by the authoritative backend.

## 14. Firestore

Firestore is used as an infrastructure adapter, not as a replacement for backend authorization.

Notification rules allow an authenticated user to read their own notifications and restrict mutation to the notification read state.

Review Firestore rules whenever a new collection is introduced.

## 15. Security rules

Non-negotiable rules:

1. Client authorization is advisory; the server decides.
2. Do not log PHI.
3. Do not put PHI in URLs.
4. Do not put clinical content in push payloads.
5. Do not persist plaintext tokens.
6. Do not automatically merge clinical records.
7. Do not calculate authoritative availability/pricing/permissions on the client.
8. Do not expose production demo credentials.
9. Do not claim regulatory compliance without the required organizational, technical and legal controls.

## 16. Testing

Minimum local verification:

```bash
flutter analyze --fatal-warnings
flutter test --coverage
```

Tests should cover:

- demo patient login,
- demo doctor login,
- demo administrator login,
- role-specific dashboard rendering,
- authentication state transitions,
- authorization/route guards,
- appointment workflows,
- conflict resolution,
- telehealth token policy.

The repository CI also checks layer boundaries and hardcoded user-facing strings.

## 17. CI/CD

The CI pipeline validates analysis and tests and builds Android/iOS artifacts.

Android/iOS platform scaffolding is regenerated during CI because the repository's native platform trees are intentionally created as part of the build process.

Android builds require the generated project to use a compile SDK compatible with the installed plugins.

Release signing is intentionally not committed to source control.

## 18. Firebase setup

For a real Firebase environment:

1. Install Firebase CLI.
2. Authenticate with Firebase.
3. Create/select the appropriate Firebase project.
4. Run FlutterFire configuration.
5. Enable the required Firebase Authentication provider.
6. Create Firestore.
7. Deploy reviewed Firestore rules.
8. Use separate staging and production projects.
9. Enable Firebase authentication only through environment configuration.

Do not place generated production credentials or service-account files in the repository.

## 19. Adding a new feature

Follow this sequence:

1. Define the business requirement.
2. Define backend/API contract.
3. Define domain entities.
4. Define repository interface.
5. Implement data sources/repository.
6. Add use cases.
7. Add BLoC/Cubit.
8. Add pages/widgets.
9. Add localization.
10. Add authorization requirements.
11. Add audit requirements for clinical/financial operations.
12. Add unit/BLoC/widget tests.
13. Add integration tests where backend behavior matters.
14. Run static analysis and tests.
15. Review security and PHI handling.
16. Update the user/development documentation.

## 20. Production readiness checklist

Before real patient use, verify all of the following:

- production backend implemented and independently authorized,
- tenant isolation tested,
- audit logging implemented,
- backups and recovery tested,
- key management implemented,
- App Check/device-integrity controls configured,
- certificate pins are real, tested and rotatable if enabled,
- penetration/security testing completed,
- crash reporting with PHI scrubbing configured,
- performance monitoring configured,
- release signing configured,
- staging and production are separated,
- integration tests pass against a test backend,
- rollback procedure documented,
- privacy/legal review completed.

## 21. Current limitations

As of v1.0, the repository is an engineering foundation rather than a finished clinical production system.

Backend-dependent capabilities still require real server implementations and verification. In particular, do not represent the following as complete merely because a route or repository contract exists:

- full medical-record CRUD,
- complete consultation workflow,
- complete prescription workflow,
- production billing/payment processing,
- production SMS/email notification delivery,
- full telehealth room/recording workflow,
- production device-integrity enforcement,
- production App Check enforcement,
- signed release distribution,
- penetration testing,
- full production observability,
- compliance certification/attestation.

## 22. Documentation map

- `README.md` — project overview
- `docs/architecture.md` — architecture and dependency rules
- `docs/feature-roadmap.md` — feature development sequence
- `docs/api/admin-crud-contract.md` — administrative API contract
- `docs/api/telehealth-contract.md` — telehealth API contract
- `docs/deployment/release-hardening.md` — release and deployment hardening
- `docs/manuals/user-manual-v1.0.md` — end-user guide
- `docs/manuals/development-manual-v1.0.md` — engineering guide
