class ListOfPendingRequestsResponseEntity {
  final bool hasMoreData;
  final int totalRecords;
  final List<ListOfPendingDataEntity> items;

  ListOfPendingRequestsResponseEntity({
    required this.hasMoreData,
    required this.totalRecords,
    required this.items,
  });
}

class ListOfPendingDataEntity {
  final String name;
  final String rol;
  final String amount;
  final String description;
  final DateTime createdAt;
  final String globalStatus;
  final String requestId;

  ListOfPendingDataEntity({
    required this.name,
    required this.rol,
    required this.amount,
    required this.description,
    required this.createdAt,
    required this.globalStatus,
    required this.requestId,
  });
}