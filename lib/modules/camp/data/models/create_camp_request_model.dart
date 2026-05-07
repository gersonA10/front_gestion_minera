import 'package:front_gestion_minera/modules/camp/domain/entity/entity.dart';

class CreateCampRequestModel extends CreateCampRequestEntity {
  const CreateCampRequestModel({
    required super.concept,
    required super.detail,
    required super.requestedAmount,
    required super.evidencePath,
  });

  factory CreateCampRequestModel.fromEntity(CreateCampRequestEntity entity) {
    return CreateCampRequestModel(
      concept: entity.concept,
      detail: entity.detail,
      requestedAmount: entity.requestedAmount,
      evidencePath: entity.evidencePath,
    );
  }

  Map<String, dynamic> toFormDataMap() {
    return {
      'concept': concept,
      'detail': detail,
      'requested_amount': requestedAmount,
    };
  }
}
