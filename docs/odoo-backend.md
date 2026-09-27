# MediBook Odoo 19 Backend

The Odoo backend lives under `addons/` and is intentionally split by ownership:

- `medibook_base`: organizations, clinics, practitioners, services, users, security, audit
- `medibook_patient`: patient profiles and append-only medical records
- `medibook_appointment`: schedules, availability and appointments
- `medibook_consultation`: consultations and telehealth sessions
- `medibook_prescription`: medications and prescriptions
- `medibook_billing`: invoice/payment/refund domain, read-only from the mobile API
- `medibook_api`: mobile HTTP API adapter using Odoo server-side sessions
- `medibook_admin`: backend administration menus

## Odoo 19 requirements

The implementation uses Odoo 19 APIs:

- SQL invariants use `models.Constraint`, not `_sql_constraints`.
- User membership uses `res.users.group_ids`.
- Interactive mobile authentication is backed by Odoo sessions.
- Server-to-server integrations should use Odoo's JSON-2 API with API keys; the MediBook mobile adapter exposes the REST paths already defined by the Flutter contract.

## Install

Run Odoo with the custom addons path and install `medibook_admin`:

```bash
odoo -d medibook -i medibook_admin --addons-path=/mnt/extra-addons,/usr/lib/python3/dist-packages/odoo/addons
```

The dependency graph installs the MediBook modules underneath it.

## Demo accounts

Demo identities are **not created in production by default**.

For a development/staging database, set:

```bash
export MEDIBOOK_DEMO_PASSWORD='the same password configured in the Flutter demo build'
```

Then install or reinstall `medibook_api`. Its post-install hook creates/updates:

- `demo.patient@medibook.app`
- `demo.doctor@medibook.app`
- `demo.admin@medibook.app`

The password is supplied at deployment time and is not stored in this repository.

## Mobile authentication

`POST /auth/login` authenticates against Odoo's server-side session and returns the session identifier in `access_token` for compatibility with the existing Flutter bearer interceptor. The backend resolves that bearer value back to the Odoo session and updates the request environment to the authenticated user.

The raw session is also returned as the standard Odoo `session_id` cookie.

No JWT or fabricated long-lived bearer credential is used.

## Important security boundary

The API uses `sudo()` only inside controller adapters after explicit object/role/organization authorization. Direct Odoo model access remains protected by ACLs and record rules.

Clinical records are append-only. Signed consultation notes cannot be modified in place. Organization administrators do not receive medical-record ACLs.

## Telehealth

Daily credentials are read from Odoo system parameters:

- `medibook.daily_api_key`
- `medibook.daily_domain`

The API issues short-lived Daily tokens and stores only a SHA-256 hash of the token. Raw join tokens are never persisted. Recording is not enabled by this backend.

## Verification

The repository CI contains an Odoo 19 job that:

1. runs Python syntax compilation over `addons/`;
2. starts PostgreSQL 16;
3. runs the official Odoo 19 container;
4. installs `medibook_admin` and all dependencies;
5. executes Odoo module tests.

A CI run must be green before the backend is called install-verified.
