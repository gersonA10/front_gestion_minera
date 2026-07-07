class TransactionDetailsResponseEntity {
    final String transactionId;
    final String referencia;
    final int monto;
    final String tipoOperacion;
    final String concepto;
    final DateTime fechaHora;
    final String cajaAfectada;
    final String responsablePago;
    final String solicitanteOriginal;
    final String? comprobantesAdjuntos;

    TransactionDetailsResponseEntity({
        required this.transactionId,
        required this.referencia,
        required this.monto,
        required this.tipoOperacion,
        required this.concepto,
        required this.fechaHora,
        required this.cajaAfectada,
        required this.responsablePago,
        required this.solicitanteOriginal,
        required this.comprobantesAdjuntos,
    });
}
