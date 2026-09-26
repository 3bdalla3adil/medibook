# Firebase identity setup for MediBook + Odoo 19

MediBook uses Firebase Authentication as the identity provider. Odoo 19 is the authoritative application backend for user profiles, authorization, appointments, clinics, doctors, medical records and other clinical workflows.

## Authentication flow

```text
Flutter
  ↓
Firebase Authentication
  ↓ Firebase ID token
POST /medibook/api/auth/exchange
  ↓
Odoo verifies Firebase JWT
  ↓
Odoo issues short-lived MediBook JWT
  ↓
Flutter stores MediBook JWT in secure storage
  ↓
Authorization: Bearer <MediBook JWT>
  ↓
Odoo protected APIs
```

The Firebase ID token must not be used as the bearer token for Odoo clinical APIs.

## 1. Configure Firebase

Create a Firebase project and enable:
- Authentication → Email/Password
- Android and/or iOS application registration

Use FlutterFire to configure the native applications:
```bash
firebase login
dart pub global activate flutterfire_cli
flutterfire configure
```

The repository intentionally does not contain production Firebase credentials.

## 2. Configure MediBook

For an Odoo-backed build:
```text
ENABLE_FIREBASE_AUTH=true
ENABLE_DEMO_AUTH=false
API_VERSION=
API_BASE_URL=https://<your-odoo-domain>
```

API_VERSION should remain empty because the Odoo controller routes already contain /medibook/api.

## 3. Configure Odoo

Install the medibook_api module from the MediBook Odoo 19 backend package.

Configure these Odoo system parameters:
- medibook.jwt_secret — long random secret
- medibook.firebase_project_id — Firebase project ID

Never commit either secret to source control.

## 4. Registration and login

The Flutter auth datasource:
1. Creates or authenticates the Firebase user.
2. Obtains a fresh Firebase ID token.
3. Sends it to Odoo /medibook/api/auth/exchange.
4. Receives a short-lived Odoo MediBook JWT.
5. Stores that Odoo token using the existing secure TokenStore.
6. Uses Odoo /medibook/api/auth/me for the authoritative user profile.

There is no longer a Firestore users/{uid} profile dependency in the authentication flow.

## 5. Token refresh

When Odoo returns HTTP 401, the Flutter interceptor refreshes the Firebase ID token, exchanges it again with Odoo, stores the newly issued Odoo JWT, and retries the failed API request once.

A Firebase token is never written into the Odoo TokenStore as an application access token.

## 6. Logout

Logout attempts to revoke the Odoo server-side session and then signs out of Firebase locally.

## 7. Clinical-data boundary

Do not move clinical records, appointments, prescriptions, or authorization decisions into Firestore as a parallel source of truth.

Odoo is the authoritative backend for these domains. Firebase can still be used for platform services such as push delivery where separately configured.

## 8. Production checklist

- configure HTTPS and production certificates;
- configure Firebase project ID in Odoo;
- configure a high-entropy Odoo JWT secret;
- enable Firebase Auth and disable demo auth;
- verify organization/clinic access rules;
- verify doctor/patient clinical authorization;
- test appointment concurrency and idempotency;
- test token expiry and 401 recovery;
- enable backups and restore testing;
- configure monitoring and rate limiting;
- perform penetration/security testing;
- define privacy, retention, consent and incident-response procedures.

This architecture is an engineering implementation foundation; it is not by itself a declaration of HIPAA, GDPR, PDPL, PCI DSS, or other regulatory compliance.