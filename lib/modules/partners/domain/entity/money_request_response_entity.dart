class MoneyRequestResponseEntity {
  final bool success;
  final String message;
  final String requestId;

  MoneyRequestResponseEntity({
    required this.success,
    required this.message,
    required this.requestId,
  });
}