class CreatePayrollMonthlyEntity {
  final int month;
  final int year;
  final String justification;
  final String planillaUrl;

  CreatePayrollMonthlyEntity({
    required this.month,
    required this.year,
    required this.justification,
    required this.planillaUrl,
  });
}
