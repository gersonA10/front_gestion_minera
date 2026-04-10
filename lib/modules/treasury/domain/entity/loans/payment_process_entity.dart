
class PayTheFeeResponseEntity {
    final double montoPagado;
    final String referencia;
    final String fechaHora;
    final String cajaAfectada;
    final String transactionId;

    PayTheFeeResponseEntity({
        required this.montoPagado,
        required this.referencia,
        required this.fechaHora,
        required this.cajaAfectada,
        required this.transactionId,
    });
}
class PayTheFeeRequetsEntity {
 final String cajaOrigenId;
  final String metodoPago;
  final String referencia;
  final String fechaPago;
  final String comprobante;

    PayTheFeeRequetsEntity({
       required this.cajaOrigenId,
    required this.metodoPago,
    required this.referencia,
    required this.fechaPago,
    required this.comprobante,
    });
}