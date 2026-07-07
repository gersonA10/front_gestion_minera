import 'package:front_gestion_minera/modules/camp/domain/entity/entity.dart';
import 'package:intl/intl.dart';

class CreateCampRequestModel extends CreateCampRequestEntity {
  const CreateCampRequestModel({
    required super.concept,
    required super.detail,
    required super.requestedAmount,
    required super.estimatedPurchaseDate,
  });

  factory CreateCampRequestModel.fromEntity(CreateCampRequestEntity entity) {
    return CreateCampRequestModel(
      concept: entity.concept,
      detail: entity.detail,
      requestedAmount: entity.requestedAmount,
      estimatedPurchaseDate: entity.estimatedPurchaseDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'concept': concept,
      'detail': detail,
      'requested_amount': requestedAmount,
      'estimated_date': DateFormat('yyyy-MM-dd').format(estimatedPurchaseDate),
    };
  }
}
