# MediBook demo account

MediBook includes an explicit demo authentication provider for development and staging builds.

## Demo credentials

- Email: `demo@medibook.app`
- Password: `Demo@2026!`

The login screen exposes **Continue with demo account** only when
`ENABLE_DEMO_AUTH=true`.

## Important security boundary

These credentials are intentionally public demo credentials. They are not a
production secret and must never provide access to real patient data.

The application configuration rejects demo authentication in production.
Production authentication must use the configured backend identity provider.

The demo provider currently authenticates the patient session locally. It does
not create or modify a Firebase Authentication user. A real Firebase test
account can be added separately once Firebase is connected to the project.
