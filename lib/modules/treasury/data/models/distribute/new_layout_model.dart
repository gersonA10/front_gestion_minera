
import '../../../domain/entity/entity.dart';

class NewLayoutResponseModel extends NewLayoutResponseEntity{

    NewLayoutResponseModel({
        required super.distributionId,
    });

    factory NewLayoutResponseModel.fromJson(Map<String, dynamic> json) => NewLayoutResponseModel(
        distributionId: json["distribution_id"],
    );
}
