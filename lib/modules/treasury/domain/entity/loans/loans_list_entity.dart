enum LoanStatus { activo, enMora, finalizado }

class InternalLoansResponseEntity {
  final int totalRecords;
  final bool hasMore;
  final List<InternalLoansEntity> items;

  InternalLoansResponseEntity({
    required this.totalRecords,
    required this.hasMore,
    required this.items,
  });
}

class InternalLoansEntity {
  final String loanId;
  final String lenderName;
  final String loanCode;
  final String estadoEtiqueta;
  final int totalPrestado;
  final int pendiente;
  final int progresoPagoPct;
  final AlertaVencimientoEntity alertaVencimiento;

  InternalLoansEntity({
    required this.loanId,
    required this.lenderName,
    required this.loanCode,
    required this.estadoEtiqueta,
    required this.totalPrestado,
    required this.pendiente,
    required this.progresoPagoPct,
    required this.alertaVencimiento,
  });

  LoanStatus get status {
    if (alertaVencimiento.estaEnMora) return LoanStatus.enMora;
    if (pendiente <= 0) return LoanStatus.finalizado;
    return LoanStatus.activo;
  }

  double get progreso => progresoPagoPct.toDouble();
  int get progresoInt => progresoPagoPct;
  int get totalPagado => totalPrestado - pendiente;
}

class AlertaVencimientoEntity {
  final bool estaEnMora;
  final String textoFecha;

  AlertaVencimientoEntity({required this.estaEnMora, required this.textoFecha});
}
