import '../../domain/entity/loan_register_request_response_entity.dart';
//resgistar un prestamo

class LoanRegisterResponseModel {
  final bool success;
  final String message;
  final String loanId;
  LoanRegisterResponseModel({
    required this.success,
    required this.message,
    required this.loanId,
  });

  factory LoanRegisterResponseModel.fromJson(Map<String, dynamic> json) =>
      LoanRegisterResponseModel(
        success: json["success"],
        message: json["message"],
        loanId: json['data']?['loan_id'] ?? '',
      );
  LoanRegisterResponseEntity toEntity() {
    return LoanRegisterResponseEntity(
      success: success,
      message: message,
      loanId: loanId,
    );
  }
}
