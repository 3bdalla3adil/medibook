# Admin CRUD API Contract

Administrative CRUD is backend-authoritative and requires organization/clinic scoped permissions.

Endpoints:
- `GET /clinics`, `POST /clinics`, `GET /clinics/{id}`, `PATCH /clinics/{id}`
- `GET /doctors`, `POST /doctors`, `GET /doctors/{id}`, `PATCH /doctors/{id}`
- `GET /medical-services`, `POST /medical-services`, `GET /medical-services/{id}`, `PATCH /medical-services/{id}`
- `GET /patients`, `GET /patients/{id}`

`POST`/`PATCH` operations require the appropriate staff-management permission and organization scope. Patient records are never mutated through generic admin CRUD.

Every mutation requires an idempotency key where retry duplication is possible and emits a server-side audit event.

The mobile client must not infer permissions or organization membership. The backend decides access.
