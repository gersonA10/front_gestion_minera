import '../../domain/entity/loan_register_request_entity.dart';

class LoanRequestModel extends LoanRequestEntity {
  LoanRequestModel({
    required super.loanType,
    required super.amountOrQuantity,
    required super.description,
    required super.comprobanteImg,
    super.hasInterest,
    super.interestRate,
  });
  // Mapeamos la Entidad de Dominio a este Modelo de Datos
  factory LoanRequestModel.fromEntity(LoanRequestEntity entity) {
    return LoanRequestModel(
      loanType: entity.loanType,
      amountOrQuantity: entity.amountOrQuantity,
      description: entity.description,
      comprobanteImg: entity.comprobanteImg,
      hasInterest: entity.hasInterest,
      interestRate: entity.interestRate,
    );
  }

  Map<String, dynamic> toFormDataMap() {
    return {
      "loan_type": loanType,
      "amount_or_quantity": amountOrQuantity,
      "description": description,
      "has_interest": hasInterest,
      // La tasa solo viaja cuando el préstamo pacta interés.
      if (hasInterest && interestRate != null) "interest_rate": interestRate,
    };
  }
}
