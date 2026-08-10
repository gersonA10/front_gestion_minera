class SalePreviewRequestEntity {
  final double gramsToSell;
  const SalePreviewRequestEntity({required this.gramsToSell});
}

class SalePreviewBatchDistributionEntity {
  final String batchId;
  final String batchCode;

  /// Null en lotes que entraron por préstamo de socio: no tienen pureza analizada.
  final double? pureza;
  final double disponibleAntes;
  final double gramosDescontados;
  final double restanteDespues;

  const SalePreviewBatchDistributionEntity({
    required this.batchId,
    required this.batchCode,
    required this.pureza,
    required this.disponibleAntes,
    required this.gramosDescontados,
    required this.restanteDespues,
  });
}

class SalePreviewResponseEntity {
  final double totalSolicitado;
  final List<SalePreviewBatchDistributionEntity> distribucionLotes;

  const SalePreviewResponseEntity({
    required this.totalSolicitado,
    required this.distribucionLotes,
  });
}

class RegisterSaleRequestEntity {
  final String salesDate;
  final String buyer;
  final double totalGramsSold;
  final double priceBsPerGram;
  final String comprobante;

  const RegisterSaleRequestEntity({
    required this.salesDate,
    required this.buyer,
    required this.totalGramsSold,
    required this.priceBsPerGram,
    required this.comprobante,
  });
}

class SaleBatchDesgloceEntity {
  final String batchCode;

  /// Null en lotes que entraron por préstamo de socio: no tienen pureza analizada.
  final double? pureza;
  final double gramosDescontados;
  final String estado;

  const SaleBatchDesgloceEntity({
    required this.batchCode,
    required this.pureza,
    required this.gramosDescontados,
    required this.estado,
  });
}

class RegisterSaleResponseEntity {
  final String saleId;
  final double pesoVendidoG;
  final double precioPorGramoBS;
  final double totalBs;
  final String comprador;
  final String fechaHora;
  final String numOperacion;
  final List<SaleBatchDesgloceEntity> desgloseLotes;

  const RegisterSaleResponseEntity({
    required this.saleId,
    required this.pesoVendidoG,
    required this.precioPorGramoBS,
    required this.totalBs,
    required this.comprador,
    required this.fechaHora,
    required this.numOperacion,
    required this.desgloseLotes,
  });
}
