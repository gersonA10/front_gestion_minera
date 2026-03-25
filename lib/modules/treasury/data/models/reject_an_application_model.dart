import '../../domain/entity/entity.dart';

class RejectAnApplicationResponseModel extends RejectAnApplicationResponseEntity{
    RejectAnApplicationResponseModel({
        required super.success,
        required super.message,
        required super.data,
    });
    factory RejectAnApplicationResponseModel.fromJson(Map<String, dynamic> json) => RejectAnApplicationResponseModel(
        success: json["success"],
        message: json["message"],
        data: RejectAnApplicationDataModel.fromJson(json["data"]),
    );
}

class RejectAnApplicationDataModel extends RejectAnApplicationDataEntity{

    RejectAnApplicationDataModel({
        required super.description,
    });

    factory RejectAnApplicationDataModel.fromJson(Map<String, dynamic> json) => RejectAnApplicationDataModel(
        description: json["description"],
    );
}
