import '../../domain/entity/entity.dart';

class ApproveTheRequestModel extends ApproveTheRequestEntity {
  ApproveTheRequestModel({
    required super.success,
    required super.message,
    required super.data,
  });

  factory ApproveTheRequestModel.fromJson(Map<String, dynamic> json) =>
      ApproveTheRequestModel(
        success: json["success"],
        message: json["message"],
        data: ApproveTheRequestDataModel.fromJson(json["data"]),
      );
}

class ApproveTheRequestDataModel extends ApproveTheRequestDataEntity {
  ApproveTheRequestDataModel({required super.description});

  factory ApproveTheRequestDataModel.fromJson(Map<String, dynamic> json) =>
      ApproveTheRequestDataModel(description: json["description"]);
}
