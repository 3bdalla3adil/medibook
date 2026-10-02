# MediBook target implementation

## Phase 1: registration and settings

- Patient self-registration is available at `/register` and rejects staff roles.
- Staff accounts are created only from single-use, expiring Odoo invitation records at `/invitation/:token`.
- Invitation acceptance assigns the invited role, organization, and clinic scope server-side.
- Settings are persisted with `shared_preferences` for theme, text scale, and reduced motion. Secure identity/session material remains in the existing encrypted storage layer.
- English and Arabic localization keys were added to both ARB files.

## Phase 2: telehealth

- `medibook_telehealth` stores session participants, expiration, end reason, and signaling messages.
- Odoo endpoints authorize only the appointment patient and doctor; persisted signals are offer, answer, ICE, state, and end events.
- `OdooSignalingChannel` and `OdooWebSocketDataSource` provide a WebSocket adapter; the Odoo HTTP signal endpoints can be used by a WebSocket gateway/bridge.
- `WebRtcMediaController` acquires local audio/video, attaches tracks to an `RTCPeerConnection`, and disposes tracks on permission failure or call end.
- Android camera/microphone permissions and iOS usage descriptions are included.
- No SFU/TURN credentials are hardcoded; deployment supplies ICE/SFU configuration.

## Phase 3: medication and pharmacy

- Medication catalog, patient medication orders, schedules, dose logs, reminders, and a five-minute server cron are represented in `medibook_medication`.
- Pharmacy queue and dispense records are represented in `medibook_pharmacy`; dispensing marks the record and patient notification state together.
- Portal users are denied backend access to operational pharmacy and medication models by record rules.
- Pharmacist role and `managePharmacy` permission are exposed through the existing auth API.

## Validation limits

The active sandbox does not contain Flutter/Dart or an Odoo runtime, so `flutter pub get`, `flutter analyze`, `flutter test`, and an Odoo module install cannot be executed here. Static checks were run for Python syntax, XML parsing, JSON validity, localization key parity, forbidden `_sql_constraints`, route coverage, and required target files. Run the full toolchain checks in CI or a Flutter/Odoo development environment before release.
