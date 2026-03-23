
import '../../domain/entity/entity.dart';

class ListOfPendingRequestsResponseModel extends ListOfPendingDataEntity {
  ListOfPendingRequestsResponseModel({
    required super.name,
    required super.rol,
    required super.amount,
    required super.description,
    required super.createdAt,
    required super.globalStatus,
    required super.requestId,
  });

  factory ListOfPendingRequestsResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => ListOfPendingRequestsResponseModel(
    name: json["name"],
    rol: json["rol"],
    amount: json["amount"],
    description: json["description"],
    createdAt: DateTime.parse(json["created_at"]),
    globalStatus: json["global_status"],
    requestId: json["request_id"],
  );
  ListOfPendingDataEntity toEntity() {
    return ListOfPendingDataEntity(
      name: name,
      rol: rol,
      amount: amount,
      description: description,
      createdAt: createdAt,
      globalStatus: globalStatus,
      requestId: requestId,
    );
  }
}
