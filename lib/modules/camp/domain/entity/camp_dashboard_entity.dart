class CampStatsEntity {
  final int active;
  final int completed;

  CampStatsEntity({required this.active, required this.completed});
}

class CampRecentRequestEntity {
  final String requestId;
  final String displayCode;
  final String description;
  final String globalStatus;
  final String statusLabel;

  /// Estado de conciliación (reposición): 'PENDING' | 'RECONCILED' |
  /// 'NOT_REQUIRED' | null. Si es 'PENDING' la solicitud no está realmente
  /// completada: tiene una reposición pendiente de Hacienda.
  final String? reconciliationStatus;

  final DateTime createdAt;

  CampRecentRequestEntity({
    required this.requestId,
    required this.displayCode,
    required this.description,
    required this.globalStatus,
    required this.statusLabel,
    this.reconciliationStatus,
    required this.createdAt,
  });
}

class CampDashboardEntity {
  final CampStatsEntity stats;
  final List<CampRecentRequestEntity> recentRequests;
  final int totalRecords;

  CampDashboardEntity({
    required this.stats,
    required this.recentRequests,
    required this.totalRecords,
  });

  bool hasMoreData(int page, int limit) => (page * limit) < totalRecords;
}
