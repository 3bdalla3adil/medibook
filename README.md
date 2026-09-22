# MediBook

MediBook is an Arabic-first, multi-clinic medical appointment and telehealth mobile foundation for Flutter on Android and iOS.

## Architecture

The application uses feature-first Clean Architecture:

- Presentation: BLoC/Cubit, pages, widgets
- Domain: entities, repository contracts, use cases
- Data: DTOs, remote/local data sources, repository implementations
- Core: networking, security, encrypted local storage, synchronization, configuration, dependency injection

Backend integrations remain behind domain repository contracts so REST, Odoo REST/RPC, Firebase, or another backend can be introduced without coupling the UI to infrastructure.

## Current foundation

- Authentication and session restoration
- Patient dashboard
- Appointment domain and repository
- Offline appointment cache and outbox synchronization
- Patient profile data flow
- Telehealth session abstraction
- Arabic-first localization with English support
- RTL-aware Material 3 interface
- Secure token storage
- Dio networking with centralized error handling/retry/auth interception
- Hive-based local storage
- Security extension points
- Unit/BLoC/widget tests
- CI validation and Android/iOS release builds

## Important security note

This repository is an engineering foundation, not a declaration of HIPAA, GDPR, PDPL, or any other regulatory compliance. Real clinical deployment requires backend authorization, audit controls, key management, data retention policies, incident response, backups, operational security, and legal/privacy review.

Never commit private keys, signing credentials, service-account files, production secrets, or real patient data.

## Development

Install dependencies:

    flutter pub get

Generate localization code:

    flutter gen-l10n

Run static analysis:

    flutter analyze

Run tests:

    flutter test

Run the application:

    flutter run

Environment values are supplied with Dart defines. See config/staging.json and the configuration classes under lib/core/config.

## Repository layout

    lib/
      app/          Application shell, routing, theme
      core/         Cross-cutting infrastructure
      features/     Feature-owned data/domain/presentation layers
      l10n/         Arabic and English localization

See docs/architecture.md for dependency rules and docs/feature-roadmap.md for the planned clinical modules.
