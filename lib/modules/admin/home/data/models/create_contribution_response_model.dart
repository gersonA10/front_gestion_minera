import '../../domain/entity/entity.dart';

class CreateContributionResponseModel {
  final String message;
  final int totalPeople;
  final double amountPerPerson;
  final double totalAmount;

  CreateContributionResponseModel({
    required this.message,
    required this.totalPeople,
    required this.amountPerPerson,
    required this.totalAmount,
  });

  factory CreateContributionResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return CreateContributionResponseModel(
      message: json['message'] ?? 'Aporte creado correctamente',
      totalPeople: data['total_people'] ?? 0,
      amountPerPerson: (data['amount_per_person'] ?? 0).toDouble(),
      totalAmount: (data['total_amount'] ?? 0).toDouble(),
    );
  }

  CreateContributionResponseEntity toEntity() {
    return CreateContributionResponseEntity(
      message: message,
      totalPeople: totalPeople,
      amountPerPerson: amountPerPerson,
      totalAmount: totalAmount,
    );
  }
}