import '../../../domain/entity/goldInventory/gold_sale_entity.dart';

class SalePreviewBatchDistributionModel
    extends SalePreviewBatchDistributionEntity {
  const SalePreviewBatchDistributionModel({
    required super.batchId,
    required super.batchCode,
    required super.pureza,
    required super.disponibleAntes,
    required super.gramosDescontados,
    required super.restanteDespues,
  });

  factory SalePreviewBatchDistributionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return SalePreviewBatchDistributionModel(
      batchId: json['batch_id'] as String? ?? '',
      batchCode: json['batch_code'] as String? ?? '',
      pureza: (json['pureza'] as num?)?.toDouble(),
      disponibleAntes: (json['disponible_antes'] as num).toDouble(),
      gramosDescontados: (json['gramos_descontados'] as num).toDouble(),
      restanteDespues: (json['restante_despues'] as num).toDouble(),
    );
  }
}

class SalePreviewResponseModel extends SalePreviewResponseEntity {
  const SalePreviewResponseModel({
    required super.totalSolicitado,
    required super.distribucionLotes,
  });

  factory SalePreviewResponseModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> lots = json['distribucion_lotes'] as List? ?? [];
    return SalePreviewResponseModel(
      totalSolicitado: (json['total_solicitado'] as num).toDouble(),
      distribucionLotes: lots
          .map((e) => SalePreviewBatchDistributionModel.fromJson(
                e as Map<String, dynamic>,
              ))
          .toList(),
    );
  }
}

class RegisterSaleRequestModel extends RegisterSaleRequestEntity {
  const RegisterSaleRequestModel({
    required super.salesDate,
    required super.buyer,
    required super.totalGramsSold,
    required super.priceBsPerGram,
    required super.comprobante,
  });

  factory RegisterSaleRequestModel.fromEntity(
    RegisterSaleRequestEntity entity,
  ) {
    return RegisterSaleRequestModel(
      salesDate: entity.salesDate,
      buyer: entity.buyer,
      totalGramsSold: entity.totalGramsSold,
      priceBsPerGram: entity.priceBsPerGram,
      comprobante: entity.comprobante,
    );
  }

  Map<String, dynamic> toFormDataMap() {
    return {
      'sale_date': salesDate,
      'buyer': buyer,
      'total_grams_sold': totalGramsSold.toString(),
      'price_bs_per_gram': priceBsPerGram.toString(),
    };
  }
}

class SaleBatchDesgloceModel extends SaleBatchDesgloceEntity {
  const SaleBatchDesgloceModel({
    required super.batchCode,
    required super.pureza,
    required super.gramosDescontados,
    required super.estado,
  });

  factory SaleBatchDesgloceModel.fromJson(Map<String, dynamic> json) {
    return SaleBatchDesgloceModel(
      batchCode: json['batch_code'] as String? ?? '',
      pureza: (json['pureza'] as num?)?.toDouble(),
      gramosDescontados: (json['gramos_descontados'] as num).toDouble(),
      estado: json['estado'] as String? ?? '',
    );
  }
}

class RegisterSaleResponseModel extends RegisterSaleResponseEntity {
  const RegisterSaleResponseModel({
    required super.saleId,
    required super.pesoVendidoG,
    required super.precioPorGramoBS,
    required super.totalBs,
    required super.comprador,
    required super.fechaHora,
    required super.numOperacion,
    required super.desgloseLotes,
  });

  factory RegisterSaleResponseModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> lots = json['desglose_lotes'] as List? ?? [];
    return RegisterSaleResponseModel(
      saleId: json['sale_id'] as String? ?? '',
      pesoVendidoG: (json['peso_vendido_g'] as num).toDouble(),
      precioPorGramoBS: (json['precio_por_gramo_bs'] as num).toDouble(),
      totalBs: (json['total_bs'] as num).toDouble(),
      comprador: json['comprador'] as String? ?? '',
      fechaHora: json['fecha_hora'] as String? ?? '',
      numOperacion: json['num_operacion'] as String? ?? '',
      desgloseLotes: lots
          .map((e) =>
              SaleBatchDesgloceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
