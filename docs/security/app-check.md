# Firebase App Check

Firebase App Check is required before exposing clinical data through Firebase-backed services.

Production requirements:
1. Configure an App Check provider for every supported platform.
2. Validate App Check server-side where the backend uses Firebase services.
3. Roll out enforcement in staging before production.
4. Treat App Check as an additional signal, not as a replacement for authorization.
5. Monitor rejected clients during rollout.

Firebase Authentication remains the identity layer. Business permissions, organization boundaries and clinical object authorization remain backend responsibilities.

This document does not claim regulatory compliance.
