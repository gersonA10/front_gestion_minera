class MonitoringTrayEntity {
  final bool hasMoreData;
    final int totalRecords;
  final List<MonitoringTrayDataEntity> items;
  MonitoringTrayEntity({required this.hasMoreData, required this.items, required this.totalRecords});
}

class MonitoringTrayDataEntity {
  final DateTime createdAt;
  final String name;
  final String rol;
  final String description;
  final String status;
  final String amount;
  final String evidencia;

  MonitoringTrayDataEntity({
    required this.createdAt,
    required this.name,
    required this.rol,
    required this.description,
    required this.status,
    required this.amount,
    required this.evidencia,
  });
}
