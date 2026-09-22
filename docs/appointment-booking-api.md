# Appointment Booking API Contract

MediBook's booking UI is backend-independent. The Flutter client expects the following REST resources.

## Catalog

### GET /clinics
Response:
```json
{
  "data": [
    {"id": "clinic-1", "name": "Main Clinic", "description": "Primary branch"}
  ]
}
```

### GET /medical-services?clinic_id={clinicId}
Returns services available at the selected clinic.

### GET /doctors?clinic_id={clinicId}&service_id={serviceId}
Returns doctors who can provide the selected service at the selected clinic.

## Availability

### GET /appointments/availability

Query parameters:
- `clinic_id`
- `service_id`
- `doctor_id`
- `date` — ISO-8601 date/time

Response:
```json
{
  "data": [
    {
      "starts_at": "2026-10-01T09:00:00Z",
      "duration_minutes": 30
    }
  ]
}
```

The server is authoritative for availability. The client must not assume that a displayed slot remains available until booking succeeds.

## Create appointment

### POST /appointments

The existing appointment repository sends:
- `id`
- `clinic_id`
- `patient_id`
- `doctor_id`
- `service_id`
- `starts_at`
- `duration_minutes`
- `is_telehealth`
- `notes`
- `version`

An `Idempotency-Key` header is sent for creation.

The server should revalidate:
1. authenticated patient identity,
2. clinic/service/doctor relationship,
3. slot availability,
4. appointment conflicts,
5. authorization,
6. requested time zone / UTC normalization.

A successful response must return the canonical appointment under `data`.

> This document defines the client contract only. It does not claim that a production backend already implements these endpoints.
