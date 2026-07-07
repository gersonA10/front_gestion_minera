import '../../domain/entity/financial_report_entity.dart';

class FinancialReportModel extends FinancialReportEntity {
  FinancialReportModel({
    required super.resumenGeneral,
    required super.conciliacion,
    required super.datosGrafica,
    required super.gastosPorResponsable,
    required super.detalleAbsolutoPdf,
  });

  factory FinancialReportModel.fromJson(Map<String, dynamic> json) {
    return FinancialReportModel(
      resumenGeneral: GeneralSummaryModel.fromJson(json['resumen_general'] ?? {}),
      conciliacion: ReconciliationSummaryModel.fromJson(json['conciliacion'] ?? {}),
      datosGrafica: (json['datos_grafica'] as List?)
              ?.map((e) => ChartDataModel.fromJson(e))
              .toList() ??
          [],
      gastosPorResponsable: (json['gastos_por_responsable'] as List?)
              ?.map((e) => ExpenseByResponsibleModel.fromJson(e))
              .toList() ??
          [],
      detalleAbsolutoPdf: (json['detalle_absoluto_pdf'] as List?)
              ?.map((e) => AbsoluteDetailModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class GeneralSummaryModel extends GeneralSummaryEntity {
  GeneralSummaryModel({
    required super.ingresosTotales,
    required super.egresosTotales,
    required super.balanceNeto,
    required super.estadoSalud,
  });

  factory GeneralSummaryModel.fromJson(Map<String, dynamic> json) {
    return GeneralSummaryModel(
      ingresosTotales: (json['ingresos_totales'] ?? 0).toDouble(),
      egresosTotales: (json['egresos_totales'] ?? 0).toDouble(),
      balanceNeto: (json['balance_neto'] ?? 0).toDouble(),
      estadoSalud: json['estado_salud'] ?? 'DESCONOCIDO',
    );
  }
}

class ReconciliationSummaryModel extends ReconciliationSummaryEntity {
  ReconciliationSummaryModel({
    required super.totalDevoluciones,
    required super.totalCompensaciones,
    required super.countDevoluciones,
    required super.countCompensaciones,
    required super.neto,
  });

  factory ReconciliationSummaryModel.fromJson(Map<String, dynamic> json) {
    return ReconciliationSummaryModel(
      totalDevoluciones: (json['total_devoluciones'] ?? 0).toDouble(),
      totalCompensaciones: (json['total_compensaciones'] ?? 0).toDouble(),
      countDevoluciones: (json['count_devoluciones'] ?? 0) as int,
      countCompensaciones: (json['count_compensaciones'] ?? 0) as int,
      neto: (json['neto'] ?? 0).toDouble(),
    );
  }
}

class ChartDataModel extends ChartDataEntity {
  ChartDataModel({
    required super.fecha,
    required super.etiqueta,
    required super.ingresos,
    required super.egresos,
    required super.margen,
  });

  factory ChartDataModel.fromJson(Map<String, dynamic> json) {
    final fecha = json['fecha']?.toString() ?? '';
    return ChartDataModel(
      fecha: fecha,
      etiqueta: json['etiqueta']?.toString() ?? '', 
      ingresos: (json['ingresos'] ?? 0).toDouble(),
      egresos: (json['egresos'] ?? 0).toDouble(),
      margen: (json['margen'] ?? 0).toDouble(),
    );
  }
}

class ExpenseByResponsibleModel extends ExpenseByResponsibleEntity {
  ExpenseByResponsibleModel({
    required super.area,
    required super.subtitulo,
    required super.monto,
    required super.porcentajeDelTotal,
  });

  factory ExpenseByResponsibleModel.fromJson(Map<String, dynamic> json) {
    return ExpenseByResponsibleModel(
      area: json['area'] ?? '',
      subtitulo: json['subtitulo'] ?? '',
      monto: (json['monto'] ?? 0).toDouble(),
      porcentajeDelTotal: (json['porcentaje_del_total'] ?? 0).toDouble(),
    );
  }
}

class AbsoluteDetailModel extends AbsoluteDetailEntity {
  AbsoluteDetailModel({
    required super.fecha,
    required super.tipo,
    required super.caja,
    required super.monto,
    required super.concepto,
    required super.responsable,
    required super.solicitante,
    super.recibo,
  });

  factory AbsoluteDetailModel.fromJson(Map<String, dynamic> json) {
    return AbsoluteDetailModel(
      fecha: json['fecha'] ?? '',
      tipo: json['tipo'] ?? '',
      caja: json['caja'] ?? '',
      monto: (json['monto'] ?? 0).toDouble(),
      concepto: json['concepto'] ?? '',
      responsable: json['responsable'] ?? '',
      solicitante: json['solicitante'] ?? '',
      recibo: json['recibo'],
    );
  }
}