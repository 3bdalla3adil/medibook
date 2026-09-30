# Appointment-app source review and MediBook adoption

Reviewed:
- Andrewwalke/clinic_booking_app
- dc-exe/Health_and_Doctor_Appointment
- Hamad-Anwar/Doctor-Appointment-Application-UI
- TechnoLX/Flutter-Doctor-Appointment-App-With-Laravel/doctor_appointment_app

## 1. Stable workflows to adopt

### Clinic booking app
The repository documents Clean Architecture + BLoC, doctor discovery, doctor details, date/time booking, and a local appointment list backed by Isar. It uses Supabase magic-link authentication. The reusable idea for MediBook is the workflow shape, not the Supabase implementation.

### Medic.ly
The repository documents Firebase authentication/data storage, doctor browsing, doctor profiles, booking, appointment history, search/explore lists, and notification data structures. It also explicitly marks notifications, Google sign-in, forgot password, and introduction screens as unfinished in that project. These are reference UX/data patterns, not evidence of production completeness.

### Doctor Appointment UI
This is primarily a UI reference. Its documented strengths are doctor selection by specialty/category/availability, detailed doctor profiles, messaging, reviews, and animations. Because the repository describes itself as UI-focused, backend/business logic should not be copied into MediBook.

### Laravel-backed app
This repository demonstrates a Flutter client with a separate Laravel backend/dashboard. MediBook should preserve its backend-agnostic REST boundary rather than couple the Flutter application to Laravel.

## 2. Missing or weak areas identified in MediBook

- Doctor list existed, but doctor profile/details were not reachable from the list.
- Demo DI bypassed the existing deterministic doctor data source and could therefore fall through to a backend call.
- Doctor DTO/domain fields were inconsistent.
- Doctor list use-case/Cubit registration was incomplete in the DI graph.
- Appointment booking already exists and has stronger server-authoritative availability requirements than the reference apps.
- Notification domain/Firebase repository exists, but a user-facing notification inbox still needs completion.
- Messaging/reviews are not part of the current MediBook clinical scope and should not be added until privacy, authorization, and backend contracts are defined.

## 3. Recommended completion set

### Patient
1. Doctor discovery
2. Doctor profile
3. Clinic/service filtering
4. Server-authoritative availability
5. Booking confirmation
6. Appointment history/details
7. Cancellation/rescheduling
8. Notification inbox
9. Telehealth
10. Medical records

### Doctor
1. Schedule
2. Patient directory
3. Consultation lifecycle
4. Clinical notes
5. Prescriptions
6. Telehealth host flow

### Administration
1. Clinic CRUD
2. Doctor/staff CRUD
3. Patient directory
4. Services
5. Billing/payment workflow
6. Audit reader
7. Reports

## 4. Implementation decisions

- Keep Flutter + BLoC + Clean Architecture.
- Keep Dio/REST as the business API boundary.
- Firebase Auth remains an identity provider, not the authorization authority.
- Keep demo mode deterministic and offline-capable.
- Do not copy old repository dependencies such as Supabase or Laravel into MediBook merely because the reference apps use them.
- Do not add clinical messaging/reviews until backend authorization, retention, moderation/audit, and PHI handling are specified.

## Changes implemented from this review

- Added GetDoctorUseCase.
- Added a real doctor profile/details page.
- Doctor list now opens the profile.
- Fixed doctor DTO/domain model alignment.
- Restored demo-aware doctor dependency injection.
- Added deterministic demo doctor assignments and availability.
- Registered doctor list/profile use cases and Cubit.
- Added English/Arabic doctor-profile localization.

## Sources

- https://github.com/Andrewwalke/clinic_booking_app
- https://github.com/dc-exe/Health_and_Doctor_Appointment
- https://github.com/Hamad-Anwar/Doctor-Appointment-Application-UI
- https://github.com/TechnoLX/Flutter-Doctor-Appointment-App-With-Laravel/tree/main/doctor_appointment_app
