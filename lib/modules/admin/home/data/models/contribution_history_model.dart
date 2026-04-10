import '../../domain/entity/contribution_history_entity.dart';

class ContributionHistoryModel extends ContributionHistoryEntity {
  ContributionHistoryModel({
    required super.contributionId,
    required super.motivo,
    super.periodMonth,
    super.periodYear,
    required super.metaRecaudacion,
    required super.montoIndividual,
    required super.sociosTotales,
    required super.fechaCreacion,
    required super.recaudadoReal,
    required super.progresoPct,
  });

  factory ContributionHistoryModel.fromJson(Map<String, dynamic> json) {
    return ContributionHistoryModel(
      contributionId: json['contribution_id'] as String? ?? '',
      motivo: json['motivo'] as String? ?? '',
      periodMonth: json['period_month'] as String?,
      periodYear: json['period_year'] as int?,
      metaRecaudacion: (json['meta_recaudacion'] as num?)?.toDouble() ?? 0.0,
      montoIndividual: (json['monto_individual'] as num?)?.toDouble() ?? 0.0,
      sociosTotales: json['socios_totales'] as int? ?? 0,
      fechaCreacion: DateTime.parse(json['fecha_creacion']).toLocal(),
      recaudadoReal: (json['recaudado_real'] as num?)?.toDouble() ?? 0.0,
      progresoPct: (json['progreso_pct'] as num?)?.toDouble() ?? 0.0,
    );
  }

  ContributionHistoryEntity toEntity() => ContributionHistoryEntity(
        contributionId: contributionId,
        motivo: motivo,
        periodMonth: periodMonth,
        periodYear: periodYear,
        metaRecaudacion: metaRecaudacion,
        montoIndividual: montoIndividual,
        sociosTotales: sociosTotales,
        fechaCreacion: fechaCreacion,
        recaudadoReal: recaudadoReal,
        progresoPct: progresoPct,
      );
}
