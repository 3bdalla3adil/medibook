# Audit API Contract

Audit logs are **reader-only** from the mobile application.

`GET /audit?entity_type={type}&entity_id={id}`

Required permission: `manageOrganization`.

The client never creates, updates or deletes audit entries.

Each entry should expose event ID, actor, organization ID, action, entity type, entity ID, timestamp, outcome and correlation ID without unnecessary clinical content.
