# MediBook User Manual v1.0

**Version:** 1.0  
**Application:** MediBook  
**Platform:** Android / iOS  
**Audience:** Patients, doctors, administrators, QA/demo users

## 1. Purpose

MediBook is an Arabic-first mobile foundation for multi-clinic medical appointments and telehealth. This manual explains the workflows currently available in the application and distinguishes demo workflows from backend-dependent production workflows.

> **Important:** This release is an engineering foundation. It is not a declaration of HIPAA, GDPR, PDPL, or other regulatory compliance. Do not use demo accounts or staging data as real clinical records.

## 2. Language and interface

- Arabic is the default application locale.
- English localization is supported.
- The interface is designed for RTL/LTR use.
- The application uses Material 3 UI.
- The application supports light/dark themes according to the device/system setting.

## 3. Starting the application

1. Install the APK supplied by the development/QA team.
2. Launch **MediBook**.
3. The application restores an existing session when possible.
4. If no session is available, the login screen is displayed.

For a staging/demo build, demo authentication must be enabled in the build configuration.

## 4. Demo accounts

Demo authentication provides three deterministic accounts.

| Role | Email | Password |
|---|---|---|
| Patient | `demo.patient@medibook.app` | `Demo@2026!` |
| Doctor | `demo.doctor@medibook.app` | `Demo@2026!` |
| Administrator | `demo.admin@medibook.app` | `Demo@2026!` |

### Quick login

On the login screen:

1. Select **Continue as Patient**, **Continue as Doctor**, or **Continue as Administrator**.
2. The demo credentials are populated automatically.
3. Submit the login form.
4. The authenticated role dashboard should open.

The demo identity is selected from the local demo authentication provider. Demo users are not real Firebase users.

## 5. Patient demo workflow

After patient demo login, the dashboard provides local workflow entry points for:

- Book Appointment
- Appointments
- Services
- Medical Records
- Telehealth

The demo dashboard is deliberately kept independent of a clinical backend so that authentication can be demonstrated without immediately calling a missing production API.

### Demo workflow pages

Selecting a workflow opens a demo-safe page instead of silently failing on an unavailable backend.

This is intentional for v1.0: a demo account should demonstrate navigation and role behavior without pretending that real clinical data exists.

## 6. Doctor demo workflow

The doctor dashboard provides entry points for:

- Doctor schedule
- Patients
- Consultations
- Prescriptions
- Telehealth

The doctor identity has doctor-specific permissions in the demo authentication model. Backend enforcement is still required in a real deployment.

## 7. Administrator demo workflow

The administrator dashboard provides entry points for:

- Appointment management
- Patient management
- Doctor management
- Clinic management

Billing and organization administration remain backend-dependent capabilities and are not presented as completed demo functionality.

## 8. Real registration and authentication

Registration is implemented through the Firebase authentication adapter when Firebase authentication is enabled.

A real deployment requires:

- a configured Firebase project,
- Firebase Authentication with the required sign-in method,
- Firestore configuration,
- production backend authorization,
- separate staging and production infrastructure.

Firebase authentication establishes identity; it does not replace backend business authorization.

## 9. Appointments and booking

The appointment feature supports:

- appointment list,
- appointment details,
- appointment cancellation,
- booking flow with clinic, service, doctor, date and available slots.

The mobile application must not be treated as authoritative for availability, price, duration, permissions, or double-booking prevention. The backend must revalidate those values before accepting a booking.

## 10. Telehealth

MediBook uses a Daily-based telehealth integration foundation.

The intended flow is:

1. Open a telehealth session from an eligible appointment.
2. Request a short-lived join token from the backend.
3. Join the Daily room.
4. Mark the appointment/consultation as joined/in progress according to the backend contract.
5. Leave the room when finished.

Join tokens must be short-lived and single-use and must never be logged.

Recording is not enabled by default. If recording is introduced, explicit patient consent and a backend-persisted consent event are required.

## 11. Notifications

The notification architecture supports:

- in-app notifications through Firestore,
- push notifications through FCM,
- backend-triggered SMS/email.

Clinical content must not be placed directly in push payloads. A push should identify the notification and the application should retrieve the content through an authenticated connection.

## 12. Security behavior

Users should:

- never share passwords,
- never use real patient data in demo builds,
- report unexpected exposure of patient information,
- keep the device and operating system updated,
- use production builds only with approved backend infrastructure.

The application contains secure token storage, encrypted local-storage foundations, security controls and PHI-safe logging boundaries. Operational security and backend authorization are still required.

## 13. Signing out

Use the logout icon in the dashboard app bar.

The application clears the local authenticated session and returns to the authentication flow.

## 14. Known v1.0 limitations

The following are not represented as complete production features:

- real backend clinical CRUD for every role,
- production billing/payment processing,
- production notification infrastructure,
- full medical-record workflows,
- full consultation and prescription workflows,
- complete telehealth provider UI/recording workflow,
- production release signing,
- full device-integrity enforcement,
- complete App Check/Play Integrity/App Attest deployment,
- penetration testing,
- production observability configuration,
- full integration-test environment.

## 15. Support / QA reporting

When reporting a problem, include:

- application version/build,
- device and OS version,
- role used,
- exact workflow,
- whether demo or real authentication was used,
- screenshot or screen recording when safe,
- error message or timestamp.

Never include passwords, access tokens, production secrets, or real patient data in a bug report.
