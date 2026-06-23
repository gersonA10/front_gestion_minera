class FinancialReportEntity {
  final GeneralSummaryEntity resumenGeneral;
  final ReconciliationSummaryEntity conciliacion;
  final List<ChartDataEntity> datosGrafica;
  final List<ExpenseByResponsibleEntity> gastosPorResponsable;
  final List<AbsoluteDetailEntity> detalleAbsolutoPdf;

  FinancialReportEntity({
    required this.resumenGeneral,
    required this.conciliacion,
    required this.datosGrafica,
    required this.gastosPorResponsable,
    required this.detalleAbsolutoPdf,
  });
}

/// Resumen de reposiciones de Campamento en el periodo:
///  - devoluciones: el campamento gastó menos y el sobrante volvió a caja.
///  - compensaciones: gastó de más y se le reintegró la diferencia.
class ReconciliationSummaryEntity {
  final double totalDevoluciones;
  final double totalCompensaciones;
  final int countDevoluciones;
  final int countCompensaciones;
  final double neto;

  ReconciliationSummaryEntity({
    required this.totalDevoluciones,
    required this.totalCompensaciones,
    required this.countDevoluciones,
    required this.countCompensaciones,
    required this.neto,
  });

  bool get hasActivity => countDevoluciones > 0 || countCompensaciones > 0;
}

class GeneralSummaryEntity {
  final double ingresosTotales;
  final double egresosTotales;
  final double balanceNeto;
  final String estadoSalud;

  GeneralSummaryEntity({
    required this.ingresosTotales,
    required this.egresosTotales,
    required this.balanceNeto,
    required this.estadoSalud,
  });
}

class ChartDataEntity {
  final String fecha;
  final String etiqueta;
  final double ingresos;
  final double egresos;
  final double margen;

  ChartDataEntity({
    required this.fecha,
    required this.etiqueta,
    required this.ingresos,
    required this.egresos,
    required this.margen,
  });
}

class ExpenseByResponsibleEntity {
  final String area;
  final String subtitulo;
  final double monto;
  final double porcentajeDelTotal;

  ExpenseByResponsibleEntity({
    required this.area,
    required this.subtitulo,
    required this.monto,
    required this.porcentajeDelTotal,
  });
}

class AbsoluteDetailEntity {
  final String fecha;
  final String tipo;
  final String caja;
  final double monto;
  final String concepto;
  final String responsable;
  final String solicitante;
  final String? recibo;

  AbsoluteDetailEntity({
    required this.fecha,
    required this.tipo,
    required this.caja,
    required this.monto,
    required this.concepto,
    required this.responsable,
    required this.solicitante,
    this.recibo,
  });
}