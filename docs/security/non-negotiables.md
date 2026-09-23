# MediBook Security Non-Negotiables

1. **Client authorization is advisory.** The server decides access. Every `[SERVER-ENFORCED]` marker means the backend must enforce the rule.
2. **No PHI in logs, URLs, analytics or crash reports.** Use `PhiRedactor`; do not bypass it.
3. **No clinical content in push notification payloads.**
4. **No automatic merge of clinical data on sync conflicts.**
5. **No plaintext tokens or PHI.** Use `flutter_secure_storage` and encrypted Hive storage.
6. **No client-side computation of availability, pricing or permission sets.** These are server-owned.
7. **No stub screens in the production route tree.** Routes exist only when their page works.
8. **Compliance is not a checkbox.** This project does not claim HIPAA, GDPR, PDPL or other regulatory compliance.
