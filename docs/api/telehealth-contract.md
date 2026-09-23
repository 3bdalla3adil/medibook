# Telehealth API Contract

Provider: Daily.

## Session creation

`POST /telehealth/sessions`

Request: appointment ID and provider `daily`.

Response includes a Daily room URL, a short-lived single-use join token, session ID and expiry. The backend must enforce that the actor may join the appointment.

Join tokens must expire in less than 15 minutes and must never be logged or persisted as application data.

## Lifecycle

- `POST /telehealth/sessions/{id}/joined`
- `POST /telehealth/sessions/{id}/end`
- `POST /telehealth/sessions/{id}/join` for a refreshed token

On join, the client requests the consultation transition to `in_progress`. Leaving the room does not complete the consultation. Only the clinician completion workflow can do that.

## Recording

Recording is disabled unless the backend/provider is explicitly configured for it. Before recording starts, the app must obtain explicit patient consent and the backend must persist the consent event. Recording tokens/settings are never exposed in logs.

## Security

The backend remains authoritative for participant identity, appointment membership, role, room permissions and token issuance.
