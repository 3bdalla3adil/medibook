enum SyncStatus { synced, cached, pending, failed, conflict }

extension SyncStatusX on SyncStatus {
  bool get isOptimistic => this == SyncStatus.pending;
  bool get needsAttention => this == SyncStatus.failed || this == SyncStatus.conflict;
}
