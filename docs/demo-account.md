# MediBook demo accounts

MediBook supports three development/staging-only demo roles. Demo accounts are
local to the application and are not Firebase Authentication users.

## Credentials

All demo accounts use:

Password: `Demo@2026!`

| Role | Email | Demo identity |
|---|---|---|
| Patient | `demo.patient@medibook.app` | Patient booking, records, appointments and telehealth workflow |
| Doctor | `demo.doctor@medibook.app` | Schedule, patients, consultations, prescriptions and telehealth workflow |
| Administrator | `demo.admin@medibook.app` | Appointment, patient, doctor, clinic and billing administration |

The login page displays all three demo roles when `ENABLE_DEMO_AUTH=true`.

## Standard demo workflow

### Patient

`Login → Patient dashboard → Services → Book appointment → Appointments → Medical records → Telehealth → Settings → Sign out`

### Doctor

`Login → Doctor dashboard → Schedule → Patients → Consultations → Prescriptions → Telehealth → Settings → Sign out`

### Administrator

`Login → Administrator dashboard → Appointments → Patients → Doctors → Clinics → Billing → Administration settings → Sign out`

The role dashboard is intentionally usable without a clinical backend so that
reviewers can explore the application's navigation and authorization-oriented
workflow.

Clinical CRUD operations still require their corresponding backend feature
implementation. The demo must not be interpreted as seeded clinical data.

## Registration

The **Create account** action is always visible on the login page, including
when demo authentication is enabled.

When Firebase authentication is enabled, registration creates a Firebase
Authentication account and a patient profile under `users/{uid}` in
Firestore.

Demo mode does not allow registration because demo identities are fixed and
public.

## Production boundary

Demo authentication is rejected by production configuration validation.
Never use demo credentials against real patient data or production services.
