import 'package:front_gestion_minera/modules/camp/domain/entity/entity.dart';

class CreateCampRequestModel extends CreateCampRequestEntity {
  const CreateCampRequestModel({
    required super.concept,
    required super.detail,
    required super.requestedAmount,
  });

  factory CreateCampRequestModel.fromEntity(CreateCampRequestEntity entity) {
    return CreateCampRequestModel(
      concept: entity.concept,
      detail: entity.detail,
      requestedAmount: entity.requestedAmount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'concept': concept,
      'detail': detail,
      'requested_amount': requestedAmount,
    };
  }
}
