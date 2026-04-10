import '../../domain/entity/entity.dart';

class ContributionSimulationModel {
  final int cantidadSocios;
  final double montoPorSocio;
  final double totalRecaudacion;

  ContributionSimulationModel({
    required this.cantidadSocios,
    required this.montoPorSocio,
    required this.totalRecaudacion,
  });

  factory ContributionSimulationModel.fromJson(Map<String, dynamic> json) {
    return ContributionSimulationModel(
      cantidadSocios: json['cantidad_socios'] ?? 0,
      montoPorSocio: (json['monto_por_socio'] ?? 0).toDouble(),
      totalRecaudacion: (json['total_recaudacion'] ?? 0).toDouble(),
    );
  }

  ContributionSimulationEntity toEntity() {
    return ContributionSimulationEntity(
      cantidadSocios: cantidadSocios,
      montoPorSocio: montoPorSocio,
      totalRecaudacion: totalRecaudacion,
    );
  }
}