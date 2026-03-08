//registar un prestamo
class LoanRegisterResponseEntity {
  final bool success;
  final String message;
  final String loanId;

  LoanRegisterResponseEntity({
    required this.success,
    required this.message,
    required this.loanId,
  });
}
