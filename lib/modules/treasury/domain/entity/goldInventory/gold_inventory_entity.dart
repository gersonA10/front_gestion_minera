//Inventory Entity
class GoldInventoryEntity {
  final double totalGramsVault;
  final double priceReference;
  final double estimateValue;

  GoldInventoryEntity({
    required this.totalGramsVault,
    required this.estimateValue,
    required this.priceReference,
  });
}

//Lotes entity
class GoldBatchEntity {
  final String batchId;
  final String batchCode;
  final DateTime extractionDate;
  final double originalWeight;
  final double avilableWeight;
  final double purity;
  final String status;

  GoldBatchEntity({
    required this.batchId,
    required this.batchCode,
    required this.extractionDate,
    required this.originalWeight,
    required this.avilableWeight,
    required this.purity,
    required this.status,
  });
}

class PaginatedGoldBatchesEntity {
  final List<GoldBatchEntity> batches;
  final bool hasMore;
  final int totalRecords;

  PaginatedGoldBatchesEntity({
    required this.batches,
    required this.hasMore,
    required this.totalRecords,
  });
}
