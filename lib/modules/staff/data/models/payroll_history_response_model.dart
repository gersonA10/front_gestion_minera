import '../../domain/entity/payroll_history_entity.dart';
import 'payroll_history_model.dart';

class PayrollHistoryResponseModel {
  final PayrollHistoryEntity latestPayment;

  final List<PayrollHistoryEntity> previousCycles;

  final int page;
  final int limit;
  final int total;
  final bool hasMore;

  const PayrollHistoryResponseModel({
    required this.latestPayment,
    required this.previousCycles,
    required this.page,
    required this.limit,
    required this.total,
    required this.hasMore,
  });

  factory PayrollHistoryResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final meta = json['meta'] ?? {};
    final data = json['data'] ?? {};

    return PayrollHistoryResponseModel(
      latestPayment: PayrollHistoryModel.fromJson(
        data['latest_payment'] ?? {},
      ),
      previousCycles:
          (data['previous_cycles'] as List? ?? [])
              .map(
                (e) => PayrollHistoryModel.fromJson(
                  e,
                ),
              )
              .toList(),
      page: meta['page'] ?? 1,
      limit: meta['limit'] ?? 10,
      total: meta['total'] ?? 0,
      hasMore: meta['hasMore'] ?? false,
    );
  }
}