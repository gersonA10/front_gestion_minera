class TransferRequestEntity {
  final double monto;
  final String cajaOrigenId;
  final String cajaDestinoId;
  final String concepto;

  TransferRequestEntity({
    required this.monto,
    required this.cajaOrigenId,
    required this.cajaDestinoId,
    required this.concepto,
  });
}

class TransferResponseEntity {
  final String message;
  TransferResponseEntity({required this.message});
}