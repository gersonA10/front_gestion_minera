class ConfirmPaymentResponseEntity {
    final bool success;
    final String message;
    final String transactionReference;

    ConfirmPaymentResponseEntity({
        required this.success,
        required this.message,
        required this.transactionReference,
    });
}

class ConfirmPaymentRequetsEntity {
 final String cajaOrigenId;
  final String notaPago;
  final String comprobante;

    ConfirmPaymentRequetsEntity({
       required this.cajaOrigenId,
    required this.notaPago,
    required this.comprobante,
    });
}