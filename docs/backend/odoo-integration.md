# MediBook ↔ Odoo REST integration

## Purpose
The Flutter application is backend-neutral. The production Odoo integration uses a REST controller layer in Odoo rather than putting Odoo model names or JSON-RPC calls into Flutter presentation/domain code.

The mobile client already uses Dio data sources for this contract:

- POST /auth/login
- POST /auth/register
- GET /auth/me
- POST /auth/logout
- GET /appointments
- GET /appointments/{id}
- POST /appointments
- PATCH /appointments/{id}
- POST /appointments/{id}/cancel
- POST /appointments/{id}/reschedule
- GET /clinics
- GET /clinics/{id}
- GET /clinics/{id}/services
- GET /medical-services
- GET /medical-services/{id}
- GET /doctors
- GET /doctors/{id}
- GET /doctors/{id}/availability
- GET /patients/{id}
- GET /consultations
- GET /prescriptions
- GET /medical-records
- billing, reports, audit and telehealth endpoints documented separately.

## Authentication contract
Login must return a data object containing access_token, optional refresh_token, access_expires_at, refresh_expires_at, session_id and a user object.
The user object must contain id, display_name, email, roles, permissions, organization_id, clinic_ids and locale.

The mobile client sends the access token as a bearer token through its existing authentication interceptor. The Odoo server must validate it on every protected request and enforce authorization server-side.

## Date/time
All API timestamps exchanged with the mobile client are UTC ISO-8601 timestamps. Odoo must convert from/to its configured business timezone at the API boundary.

## Appointment creation
The server, not Flutter, must validate authenticated patient identity, clinic, doctor, service, schedule, availability, conflicts, duration, price, timezone and authorization.
The client must never be treated as the source of truth for these values.

## Odoo implementation boundary
The Flutter repository does not assume Odoo model names such as calendar.event, res.partner, or res.users for medical workflows. Those mappings belong in the Odoo module.

This is intentional: using a guessed Odoo model would make the mobile appear integrated while silently reading or writing the wrong business objects.

## Required Odoo deliverable
The Odoo side needs a module/controller implementation for the contract above, or an existing API with equivalent request/response semantics.

At minimum it must provide authentication/session/token handling, patient profile and authorization, clinics, doctors, medical services, appointment availability and conflict validation, appointments, medical records, consultations, prescriptions, audit authorization, billing/payment authorization and telehealth session issuance.

Do not expose Odoo credentials, database passwords, or unrestricted model RPC access to the mobile app.

## Mobile configuration
Do not commit a fake Odoo URL. Build with the actual Odoo API base URL:

flutter run --dart-define=APP_ENV=staging --dart-define=API_BASE_URL=https://YOUR-ODOO-API-HOST --dart-define=API_VERSION=/api/medibook/v1 --dart-define=ENABLE_DEMO_AUTH=false --dart-define=ENABLE_FIREBASE_AUTH=false

For production, use HTTPS and a real certificate pin supplied by the deployment team.

## Important
The Flutter repository cannot honestly be described as connected to a real Odoo installation until the Odoo controller/module implementing this contract exists and its base URL is supplied. The mobile code intentionally fails rather than silently using demo data when demo authentication is disabled.