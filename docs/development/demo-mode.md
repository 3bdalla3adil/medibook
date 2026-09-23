# Demo Mode

Demo mode is controlled by the single compile-time flag ENABLE_DEMO_AUTH.

## Behavior

When enabled:
- demo authentication uses local deterministic credentials;
- patient profile data comes from DemoPatientRemoteDataSource;
- appointments come from DemoAppointmentRepository;
- booking uses DemoBookingRepository;
- clinics, services, doctors, patient directory, medical records, consultations, prescriptions and telehealth use isolated demo data sources/repositories;
- the demo path does not require a backend.

When disabled, normal Dio/Firebase implementations are selected by dependency injection.

Production configuration rejects ENABLE_DEMO_AUTH=true.

## Deterministic seed

The seed lives in lib/core/demo/demo_seed.dart. It uses stable IDs and fixed dates so automated tests can assert exact results.

The patient dashboard contains exactly two demo appointments:
- demo-appointment-001
- demo-appointment-002

The demo patient display name is Demo Patient.

## Local run

Run the staging/demo configuration:

flutter run --dart-define-from-file=config/staging.json

Run the end-to-end test on a connected device/emulator:

flutter test integration_test/demo_login_flow_test.dart

The integration test also configures the demo dependency graph directly, so it does not require the placeholder API endpoint.

## Production rule

Never enable demo authentication in a production build. The production configuration template sets ENABLE_DEMO_AUTH to false, and AppConfig.validate() rejects demo mode when APP_ENV=prod.
