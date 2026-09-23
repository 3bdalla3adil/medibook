# Notifications API Contract

## In-app

Firestore path: `users/{uid}/notifications/{notificationId}`

The client may read notifications belonging to the authenticated user only.

Suggested fields: `id`, `type`, `title`, `body`, `created_at`, `read_at`, `action`, `expires_at`.

Clinical content must be fetched from the protected API when needed. Do not put diagnosis, prescription, appointment details or other PHI in FCM payloads.

## Push

Backend-triggered FCM messages contain only a notification ID and non-sensitive event type/display metadata. The client receives the ID and fetches protected content over TLS.

## SMS/email

SMS and email are backend-triggered. The mobile client does not send clinical content directly.
