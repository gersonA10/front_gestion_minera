import 'package:front_gestion_minera/modules/staff/domain/entity/entity.dart';

class HistoryExpenditureResponseModel extends HistoryExpenditureResponseEntity {
  HistoryExpenditureResponseModel({
    required super.page,
    required super.limit,
    required super.total,
    required super.hasMore,
    required super.totalExpenses,
    required super.items,
  });
  factory HistoryExpenditureResponseModel.fronJson(Map<String, dynamic> json) {
    return HistoryExpenditureResponseModel(
      page: json['page'],
      limit: json['limit'],
      total: json['total'],
      hasMore: json['hasMore'],
      totalExpenses: json['summary']['total_expenses'],
      items: (json['items'] as List<dynamic>? ?? [])
          .map((items) => HistoryExpenditureModel.fromJson(items))
          .toList(),
    );
  }
}

class HistoryExpenditureModel extends HistoryExpenditureEntity {
  HistoryExpenditureModel({
    required super.requestId,
    required super.payrollCycle,
    required super.totalRequested,
    required super.approvedAmount,
    required super.requestedDate,
    required super.closedDate,
    required super.status,
    required super.rejectReason,
  });

  factory HistoryExpenditureModel.fromJson(Map<String, dynamic> json) {
    return HistoryExpenditureModel(
      requestId: json['request_id'] ?? '',
      payrollCycle: json['payroll_cycle'] ?? '',
      totalRequested: (json['total_requested']).toDouble() ?? 0,
      approvedAmount: (json['approved_amount']).toDouble() ?? 0,
      requestedDate: json['requested_date'] ?? '',
      closedDate: json['closed_date'],
      status: json['status'] ?? '',
      rejectReason: json['reject_reason'],
    );
  }
}
