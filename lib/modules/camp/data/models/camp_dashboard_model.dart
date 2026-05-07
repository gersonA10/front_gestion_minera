import 'package:front_gestion_minera/modules/camp/domain/entity/entity.dart';

class CampStatsModel extends CampStatsEntity {
  CampStatsModel({required super.active, required super.completed});

  factory CampStatsModel.fromJson(Map<String, dynamic> json) {
    return CampStatsModel(
      active: json['active'] as int? ?? 0,
      completed: json['completed'] as int? ?? 0,
    );
  }
}

class CampRecentRequestModel extends CampRecentRequestEntity {
  CampRecentRequestModel({
    required super.requestId,
    required super.displayCode,
    required super.description,
    required super.globalStatus,
    required super.statusLabel,
    required super.createdAt,
  });

  factory CampRecentRequestModel.fromJson(Map<String, dynamic> json) {
    return CampRecentRequestModel(
      requestId: json['request_id'] as String? ?? '',
      displayCode: json['display_code'] as String? ?? '',
      description: json['description'] as String? ?? '',
      globalStatus: json['global_status'] as String? ?? '',
      statusLabel: json['status_label'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class CampDashboardModel extends CampDashboardEntity {
  CampDashboardModel({
    required super.stats,
    required super.recentRequests,
    required super.totalRecords,
  });

  factory CampDashboardModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final statsJson = data['stats'] as Map<String, dynamic>? ?? {};
    final requestsJson = data['recent_requests'] as List<dynamic>? ?? [];

    return CampDashboardModel(
      stats: CampStatsModel.fromJson(statsJson),
      recentRequests: requestsJson
          .map((item) => CampRecentRequestModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalRecords: data['total_records'] as int? ?? 0,
    );
  }
}
