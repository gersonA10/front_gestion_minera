class ContributionCalculationEntity {
  final double montoTotal;
  final int cantidadPersonas;
  final double montoPorPersona;

  ContributionCalculationEntity({
    required this.montoTotal,
    required this.cantidadPersonas,
    required this.montoPorPersona
  });


}

  class ContributionRegistrationEntity {
    final String motivo;
    final double montoTotal;
    final int cantidadPersonas;
    final double montoPorPersona;

    ContributionRegistrationEntity({
      required this.motivo,
      required this.montoTotal,
      required this.cantidadPersonas,
      required this.montoPorPersona,
    });
  }