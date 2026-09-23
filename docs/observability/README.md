# Observability

Crash and performance telemetry must scrub PHI before transmission.

PhiRedactor is the mandatory redaction mechanism. Reporter integrations must apply it in their beforeSend/equivalent hook.

Allowed analytics examples: app_opened, appointment_booked, appointment_cancelled.

Never send patient identifiers, appointment details, diagnosis codes, prescriptions, medical notes, tokens or sensitive URLs.
