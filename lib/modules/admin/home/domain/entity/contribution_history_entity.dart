import 'package:intl/intl.dart';

class ContributionHistoryEntity {
  final String contributionId;
  final String motivo;
  final String? periodMonth;
  final int? periodYear;
  final double metaRecaudacion;
  final double montoIndividual;
  final int sociosTotales;
  final DateTime fechaCreacion;
  final double recaudadoReal;
  final double progresoPct;

  ContributionHistoryEntity({
    required this.contributionId,
    required this.motivo,
    required this.periodMonth,
    required this.periodYear,
    required this.metaRecaudacion,
    required this.montoIndividual,
    required this.sociosTotales,
    required this.fechaCreacion,
    required this.recaudadoReal,
    required this.progresoPct,
  });

  bool get isFinalized => progresoPct >= 100;

  String get periodLabel {
    if (periodMonth != null && periodYear != null) {
      final month = periodMonth![0].toUpperCase() + periodMonth!.substring(1);
      return '$month $periodYear';
    }
    return DateFormat('dd MMM yyyy', 'es').format(fechaCreacion);
  }

  String get shortCode {
    final clean = contributionId.replaceAll('-', '');
    return '#AP-${clean.substring(0, 4).toUpperCase()}';
  }
}

class PaginatedContributionHistoryEntity {
  final List<ContributionHistoryEntity> items;
  final bool hasMoreData;
  final int totalRecords;

  PaginatedContributionHistoryEntity({
    required this.items,
    required this.hasMoreData,
    required this.totalRecords,
  });
}
