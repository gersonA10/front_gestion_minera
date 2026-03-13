import '../../domain/entity/entity.dart';

class ApproveTheRequestModel extends ApproveTheRequestEntity {
  ApproveTheRequestModel({required super.description});

  factory ApproveTheRequestModel.fromJson(Map<String, dynamic> json) =>
      ApproveTheRequestModel(description: json["description"]);
}
