import 'package:front_gestion_minera/modules/treasury/domain/entity/entity.dart';

class GoldInventoryModel extends GoldInventoryEntity {
  GoldInventoryModel({
    required super.estimateValue,
    required super.priceReference,
    required super.totalGramsVault,
  });

  factory GoldInventoryModel.fromJson(Map<String, dynamic> json) {
    return GoldInventoryModel(
      totalGramsVault: (json['total_gramos_boveda'] ?? 0).toDouble(),
      estimateValue: (json['valor_estimado_bs'] ?? 0).toDouble(),
      priceReference: (json['precio_referencia_gramo'] ?? 0).toDouble(),
    );
  }
}

class GoldBatchModel extends GoldBatchEntity {
  GoldBatchModel({
    required super.batchId,
    required super.batchCode,
    required super.extractionDate,
    required super.originalWeight,
    required super.avilableWeight,
    required super.purity,
    required super.status,
  });

  factory GoldBatchModel.fromJson(Map<String, dynamic> json) {
    return GoldBatchModel(
      batchId: json['batch_id'] ?? '',
      batchCode: json['batch_code'] ?? '',
      extractionDate: DateTime.parse(json['fecha_extraccion']),
      originalWeight: (json['peso_original'] ?? 0).toDouble(),
      avilableWeight: (json['peso_disponible'] ?? 0).toDouble(),
      purity: (json['pureza'] ?? 0).toDouble(),
      status: json['estado'] ?? 'Agotado',
    );
  }
}
