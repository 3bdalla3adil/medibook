import '../../../../core/error/result.dart';
import '../entities/audit_entry.dart';

abstract interface class AuditRepository {
  /// [SERVER-ENFORCED] Requires manageOrganization.
  Future<Result<List<AuditEntry>>> getEntries({String? entityType, String? entityId});
}
