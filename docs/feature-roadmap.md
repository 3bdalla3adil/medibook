# MediBook Feature Roadmap

The repository is intentionally built incrementally. A feature should become production-facing only after its domain contract, data implementation, presentation state handling, tests, authorization requirements, and backend API contract are defined.

## Foundation

- Authentication
- Patient dashboard
- Patients
- Appointments
- Telehealth
- Offline synchronization
- Localization and RTL
- Security and networking

## Next clinical modules

- Doctors
- Clinics / organizations
- Medical services
- Consultations
- Medical records
- Prescriptions
- Notifications
- Payments
- Profile
- Settings
- Administration

## Rules for adding a module

1. Create the feature under lib/features/<name>.
2. Keep data, domain, and presentation inside the feature.
3. Define domain entities independently of API DTOs.
4. Define a repository interface in the domain layer.
5. Implement remote/local data sources in the data layer.
6. Expose business operations through use cases.
7. Use BLoC/Cubit for presentation state.
8. Add loading, success, empty, error, and offline states where applicable.
9. Add unit and BLoC/widget tests.
10. Add authorization and audit requirements before handling clinical or financial data.

Do not create placeholder screens merely to make a route appear complete. A route should be added when its feature has a real presentation implementation.
