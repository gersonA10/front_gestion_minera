import 'package:front_gestion_minera/modules/surveillance/domain/entity/entity.dart';

class ContributionCalculationModel extends ContributionCalculationEntity {
  ContributionCalculationModel({
    required super.montoTotal,
    required super.cantidadPersonas,
    required super.montoPorPersona,
  });

  factory ContributionCalculationModel.fromJson(Map<String, dynamic> json) {
    return ContributionCalculationModel(
      montoTotal: (json['monto_total'] ?? 0).toDouble(),
      cantidadPersonas: json['cantidad_personas'] ?? 0,
      montoPorPersona: (json['monto_por_persona'] ?? 0).toDouble(),
    );
  }
}

class ContributionRegistrationModel extends ContributionRegistrationEntity {
  ContributionRegistrationModel({
    required super.motivo,
    required super.montoTotal,
    required super.cantidadPersonas,
    required super.montoPorPersona,
  });

  factory ContributionRegistrationModel.fromJson(Map<String, dynamic> json) {
    return ContributionRegistrationModel(
      motivo: json['motivo'],
      montoTotal: (json['monto_total'] ?? 0).toDouble(),
      cantidadPersonas: json['cantidad_personas'] ?? 0,
      montoPorPersona: (json['monto_por_persona'] ?? 0).toDouble(),
    );
  }
}
