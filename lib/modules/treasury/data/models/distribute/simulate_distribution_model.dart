
import '../../../domain/entity/entity.dart';

class SimulateDistributionResponseModel extends SimulateDistributionResponseEntity{

    SimulateDistributionResponseModel({
        required super.success,
        required super.data,
    });

    factory SimulateDistributionResponseModel.fromJson(Map<String, dynamic> json) => SimulateDistributionResponseModel(
        success: json["success"],
        data: SimulateDistributionDataModel.fromJson(json["data"]),
    );
}

class SimulateDistributionDataModel extends SimulateDistributionDataEntity {

    SimulateDistributionDataModel({
        required super.numberOfActiveMembers,
        required super.amountPerMember,
    });

    factory SimulateDistributionDataModel.fromJson(Map<String, dynamic> json) => SimulateDistributionDataModel(
        numberOfActiveMembers: json["number_of_active_members"],
        amountPerMember: json["amount_per_member"].toDouble(),
    );
}
