# Firebase + Firestore setup for MediBook

This project supports three authentication modes:

1. **Demo authentication** for local/staging demonstrations.
2. **Firebase Authentication + Cloud Firestore** for a serverless mobile foundation.
3. **REST/Odoo-compatible authentication** for a future or existing MediBook backend.

Firebase is selected with:

`ENABLE_FIREBASE_AUTH=true`

and demo authentication takes precedence when:

`ENABLE_DEMO_AUTH=true`

For a demo-only build, keep `ENABLE_DEMO_AUTH=true` and `ENABLE_FIREBASE_AUTH=false`. For a Firebase build, use `ENABLE_DEMO_AUTH=false` and `ENABLE_FIREBASE_AUTH=true`. This keeps startup deterministic and prevents an unconfigured Firebase SDK from breaking the demo APK.

## 1. Create the Firebase project

Open the Firebase console and create a project for MediBook.

Then enable:

- **Authentication → Sign-in method → Email/Password**
- **Firestore Database**

The reference repository uses a legacy web-only Firebase JavaScript configuration in `src/web/index.html`. We are **not copying that pattern** into MediBook because MediBook is a native Android/iOS Flutter app and the current FlutterFire workflow is safer and more maintainable. Firebase's current Flutter documentation recommends the Firebase CLI plus FlutterFire CLI; FlutterFire registers the platform apps and generates `firebase_options.dart`. citeturn0search0

## 2. Install the CLIs

From the MediBook project directory:

```bash
firebase login
dart pub global activate flutterfire_cli
flutterfire configure
```

During `flutterfire configure`:

- select your Firebase project;
- select Android and iOS;
- select Web too if you intend to run MediBook on Web.

FlutterFire creates the Firebase app registrations and generates `lib/firebase_options.dart`. Re-run it whenever you add a supported platform or a Firebase product that requires updated configuration. citeturn0search0

## 3. Android and iOS configuration

For Android, FlutterFire registers the Android app and produces the native Firebase configuration. For iOS, it registers the iOS app and produces the Apple configuration. For Web, it generates the Dart options used by `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`. citeturn0search0turn0search3

Do not manually invent Firebase project IDs, application IDs, or API keys. Let `flutterfire configure` generate the correct configuration for the Firebase project. The repository intentionally does not contain fake Firebase credentials. Firebase configuration values identify the Firebase app; authorization must still be enforced by Firebase Authentication and Firestore Security Rules. citeturn0search3

Firebase configuration identifiers are not passwords; however, access control must come from Firebase Authentication and Firestore Security Rules, not from hiding the client configuration.

## 4. Enable Firebase authentication in MediBook

After Firebase configuration has been generated, edit the staging configuration:

```json
{
  "ENABLE_FIREBASE_AUTH": "true"
}
```

The repository keeps this flag **false** in the demo/staging configuration until a real Firebase project has been configured. This is intentional: enabling Firebase without valid native configuration can prevent the application from starting.

Then run:

```bash
flutter pub get
flutterfire configure
flutter run --dart-define-from-file=config/staging.json
```

## 5. Registration flow implemented in MediBook

The new registration flow is:

```text
Register screen
      ↓
AuthBloc
      ↓
RegisterUseCase
      ↓
AuthRepository
      ↓
FirebaseAuthRemoteDataSource
      ├── Firebase Auth: createUserWithEmailAndPassword()
      ├── update Firebase display name
      ├── send verification email
      └── Firestore users/{uid}: create patient profile
```

Firebase Auth creates the account and signs the user in after successful password registration. The app then creates a patient profile in Firestore. Firebase documents the same email/password creation flow and recommends handling errors such as weak passwords and existing email addresses.

## 6. Firestore data model

Registration creates:

`users/{firebaseUid}`

with fields similar to:

```text
id
display_name
email
roles: ["patient"]
permissions:
  - viewOwnAppointments
  - bookAppointment
  - cancelOwnAppointment
  - viewOwnMedicalRecord
  - joinTelehealth
organization_id: "default"
clinic_ids: []
locale: "ar"
email_verified
created_at
updated_at
```

The application treats the Firebase UID as the stable identity key.

## 7. Firestore Security Rules

The repository includes:

```text
firestore.rules
```

The initial rules allow a signed-in user to read their own `users/{uid}` profile, allow creation of a patient profile with the fixed default organization and patient permissions, and prevent the user from changing their role/permissions/organization through client-side updates.

Everything else is denied until its authorization model is explicitly implemented.

Deploy with:

```bash
firebase deploy --only firestore
```

Do **not** use `allow read, write: if true` in a deployed medical application. Firebase explicitly warns that open Firestore rules can expose or allow modification of the database. Security Rules should use Firebase Authentication and data-based authorization.

## 8. Fixing the existing login flow

The previous login page created its own `AuthBloc`, while the router/auth guard used another instance. That could make a successful login invisible to the router.

The login screen now uses the application's shared `AuthBloc` from the widget tree.

The same shared bloc handles:

- login;
- registration;
- session restoration;
- logout;
- session expiration.

## 9. Testing Firebase registration

In Firebase Console:

1. Authentication → Users.
2. Create a test user manually if desired, or use MediBook's registration screen.
3. Register from the app.
4. Confirm the Firebase Auth user exists.
5. Confirm `Firestore → users → <UID>` contains the patient profile.
6. Sign out.
7. Sign back in with the registered account.

For automated/local testing, Firebase also provides the Local Emulator Suite.

## 10. Important architecture boundary

Firebase is currently an authentication/profile backend option, not a replacement for every MediBook backend service.

Appointments, doctors, clinics, medical records, billing, telehealth, and other clinical workflows can continue using the existing REST/Odoo-compatible repositories.

This gives MediBook this deployment shape:

```text
                    ┌── Firebase Auth
Flutter App ─ Auth ─┤
                    └── REST/Odoo Auth

Flutter App ─ Clinical APIs ─ Odoo / REST backend

Flutter App ─ User Profile ─ Firestore
```

For a production medical deployment, authorization, audit logging, data retention, encryption/key management, backups, incident response, and privacy/legal requirements still need to be implemented and reviewed. Firebase configuration alone does not make an application HIPAA/GDPR/PDPL compliant.
