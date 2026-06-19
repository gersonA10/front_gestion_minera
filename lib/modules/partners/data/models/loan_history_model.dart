import '../../domain/entity/loan_histori_entity.dart';

double _toDouble(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}

double? _toDoubleN(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

DateTime? _toDateN(dynamic v) {
  if (v == null) return null;
  return DateTime.tryParse(v.toString());
}

class LoanHistoryDataModel extends LoanHistoryDataEntity {
  LoanHistoryDataModel({
    required super.loanId,
    required super.loanType,
    required super.amountOrQuantity,
    required super.description,
    required super.fileUrl,
    required super.status,
    super.motivoRechazo,
    super.hasInterest,
    super.interestRate,
    super.approvedAt,
    super.endDate,
    super.outstandingPrincipal,
    super.motivoCancelacion,
    super.interesPagado,
    required super.createdAt,
  });

  factory LoanHistoryDataModel.fromJson(Map<String, dynamic> json) =>
      LoanHistoryDataModel(
        loanId: json["loan_id"]?.toString() ?? '',
        loanType: json["loan_type"]?.toString() ?? '',
        amountOrQuantity: _toDouble(json["amount_or_quantity"]),
        description: json["description"]?.toString() ?? '',
        fileUrl: json["file_url"]?.toString() ?? '',
        status: json["status"]?.toString() ?? '',
        motivoRechazo: json["motivo_rechazo"]?.toString(),
        hasInterest: json["has_interest"] == true,
        interestRate: _toDoubleN(json["interest_rate"]),
        approvedAt: _toDateN(json["approved_at"]),
        endDate: _toDateN(json["end_date"]),
        outstandingPrincipal: _toDoubleN(json["outstanding_principal"]),
        motivoCancelacion: json["motivo_cancelacion"]?.toString(),
        interesPagado: _toDouble(json["interes_pagado"]),
        createdAt: _toDateN(json["created_at"]) ?? DateTime.now(),
      );

  /// Parsea la respuesta completa de /api/loans/history (data + meta).
  static LoanHistoryPageEntity pageFromResponse(Map<String, dynamic> json) {
    final List<dynamic> data = json["data"] ?? [];
    final Map<String, dynamic> meta = json["meta"] ?? {};
    return LoanHistoryPageEntity(
      items: data
          .map((e) => LoanHistoryDataModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasMore: meta["has_more_data"] == true,
    );
  }
}
