# Backend Tickets for [SERVER-ENFORCED] Behaviors

This repository does not contain the production backend. The following backend work is required before production use:

- AUTHZ-001: enforce role/permission checks on every protected endpoint.
- AUTHZ-002: enforce organization and clinic tenant isolation.
- AUTHZ-003: enforce appointment ownership/relationship authorization.
- BOOK-001: revalidate availability, schedule conflicts, pricing and timezone on booking.
- CLIN-001: enforce medical-record object authorization and append-only corrections.
- CLIN-002: prevent unsigned/signed consultation mutation outside the clinical workflow.
- RX-001: enforce prescription issuance by an authorized clinician and freeze issued prescriptions.
- BILL-001: implement PCI-scoped payment model, idempotency and provider webhooks before billing UI.
- AUDIT-001: write audit events server-side; mobile remains reader-only.
- NOTIFY-001: send notification IDs rather than clinical content in FCM payloads.
- TELE-001: issue single-use Daily tokens with expiry under 15 minutes and appointment authorization.
- TELE-002: persist recording consent server-side before any recording operation.
- SEC-001: verify Play Integrity/App Attest server-side.
- SEC-002: rate-limit authentication and sensitive endpoints.
- SEC-003: enforce Firebase App Check where Firebase services are exposed.
