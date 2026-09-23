# Authorization API Contract

This document defines the authorization contract expected from the MediBook backend. The Flutter client is advisory only. The backend must independently authenticate every request, enforce tenant isolation, and perform object-level authorization.

## Required metadata

Every protected endpoint must define required permissions/roles, object-level authorization, organization/clinic boundary, audit requirements, rate limit and enumeration policy.

## Response contract

- 401 — not authenticated.
- 403 — authenticated but not authorized.
- 404 — resource may exist but is hidden to prevent enumeration.
- 409 — state/version conflict.
- 422 — validation failure.

## Core rules

| Area | Client requirement | Backend object rule |
|---|---|---|
| Appointments | own/any appointment permissions | Patient: patient_id must equal auth.uid; staff: organization/clinic and relationship checks. |
| Booking | bookAppointment | Revalidate clinic, service, doctor, schedule, availability, price, duration, timezone and conflicts. |
| Medical records | own/any record permissions | Patient reads own records; clinician needs active clinical relationship or explicit grant; admins do not receive clinical content. |
| Prescriptions | writePrescription | Authorized clinician plus active consultation. |
| Patient directory | staff only | Doctor sees patients with an appointment with that doctor; admin sees patients in organization. |
| Billing | billing permissions | Organization/clinic scope and payment authorization are server-enforced. |
| Administration | organization/staff permissions | Actor must be authorized for target organization/clinic. |

## Audit requirements

Audit authentication, authorization failures, medical-record reads/writes, consultations, prescriptions, appointment mutations, billing mutations, and permission/staff changes. Include actor, organization, timestamp, action, target, outcome and correlation ID without unnecessary clinical content.

## Session lifecycle

The backend owns refresh-token validity and revocation. Multiple-device revocation is server-enforced. Account deactivation returns a documented 403 code such as account_deactivated.

## Client boundary

The Flutter app may hide UI and redirect unauthorized users, but client-side permissions are not an authorization boundary. The backend must enforce every rule above.

## Clinical integrity

Medical records are append-only. Corrections create new entries with supersedes_id. Consultation notes become immutable after signing. Amendments create a new version.

This document is a contract, not an implementation, and does not claim HIPAA, GDPR, PDPL or other regulatory compliance.
