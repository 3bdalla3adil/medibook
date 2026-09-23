import 'package:dio/dio.dart';
import '../../../../core/error/result.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/audit_entry.dart';
import '../../domain/repositories/audit_repository.dart';

class DioAuditRepository implements AuditRepository {
  DioAuditRepository(this._dio); final Dio _dio;
  @override Future<Result<List<AuditEntry>>> getEntries({String? entityType, String? entityId}) async {
    final result = await guard(() => _dio.get<Map<String, dynamic>>(ApiEndpoints.audit, queryParameters: {if (entityType != null) 'entity_type': entityType, if (entityId != null) 'entity_id': entityId}));
    return result.map((response) {
      final data = response.data?['data']; if (data is! List) return const <AuditEntry>[];
      return data.map((raw) { final item = raw as Map<String, dynamic>; return AuditEntry(id:item['id'].toString(),action:item['action'].toString(),entityType:item['entity_type'].toString(),entityId:item['entity_id'].toString(),occurredAt:DateTime.parse(item['occurred_at'].toString()).toUtc(),outcome:item['outcome'].toString(),actorLabel:item['actor_label']?.toString(),correlationId:item['correlation_id']?.toString()); }).toList(growable:false);
    });
  }
}
