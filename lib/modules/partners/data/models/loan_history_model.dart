import 'dart:convert';
import '../../domain/entity/entity.dart';

LoanHistoryResponseModel loanHistoryResponseFromJson(String str) =>
    LoanHistoryResponseModel.fromJson(json.decode(str));

class LoanHistoryResponseModel extends LoanHistoryResponseEntity {
  LoanHistoryResponseModel({
    required super.success,
    required super.message,
    required super.data,
  });

  factory LoanHistoryResponseModel.fromJson(Map<String, dynamic> json) =>
      LoanHistoryResponseModel(
        success: json["success"],
        message: json["message"],
        data: List<LoanHistoryDataModel>.from(
          json["data"].map((x) => LoanHistoryDataModel.fromJson(x)),
        ),
      );
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
    required super.createdAt,
  });

  factory LoanHistoryDataModel.fromJson(Map<String, dynamic> json) =>
      LoanHistoryDataModel(
        loanId: json["loan_id"],
        loanType: json["loan_type"],
        amountOrQuantity: json["amount_or_quantity"],
        description: json["description"],
        fileUrl: json["file_url"],
        status: json["status"],
        motivoRechazo: json["motivo_rechazo"],
        createdAt:
            DateTime.tryParse(json["created_at"] ?? '') ?? DateTime.now(),
      );
}
