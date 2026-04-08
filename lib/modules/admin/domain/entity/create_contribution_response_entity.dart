class CreateContributionResponseEntity {
  final String message;
  final int totalPeople;
  final double amountPerPerson;
  final double totalAmount;

  CreateContributionResponseEntity({
    required this.message,
    required this.totalPeople,
    required this.amountPerPerson,
    required this.totalAmount,
  });
}