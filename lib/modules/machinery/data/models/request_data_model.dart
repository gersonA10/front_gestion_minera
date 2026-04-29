import '../../domain/entity/entity.dart';

class RequestDataModel extends RequestData {

  RequestDataModel({
    required super.globalStatus,
    required super.securityStatus,
    required super.administrationStatus,
    required super.rejectReason,
    required super.requestedAmount,
    required super.paidAt,
  });

  factory RequestDataModel.fromJson(Map<String, dynamic> json) {
    return RequestDataModel(
      globalStatus: json["global_status"],
      securityStatus: json["security_status"],
      administrationStatus: json["administration_status"],
      rejectReason: json["reject_reason"],
      requestedAmount: json["requested_amount"],
      paidAt: json["paid_at"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "global_status": globalStatus,
      "security_status": securityStatus,
      "administration_status": administrationStatus,
      "reject_reason": rejectReason,
      "requested_amount": requestedAmount,
      "paid_at": paidAt,
    };
  }
}