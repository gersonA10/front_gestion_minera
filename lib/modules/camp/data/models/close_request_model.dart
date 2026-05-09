import 'package:front_gestion_minera/modules/camp/domain/entity/entity.dart';

class CloseRequestModel extends CloseRequestEntity {
  const CloseRequestModel({
    required super.finalAmount,
    required super.evidencePath,
  });

  factory CloseRequestModel.fromEntity(CloseRequestEntity entity) {
    return CloseRequestModel(
      finalAmount: entity.finalAmount,
      evidencePath: entity.evidencePath,
    );
  }

  Map<String, dynamic> toJson(String evidenceUrl) {
    return {
      'evidence_url': evidenceUrl,
      'final_amount': finalAmount,
    };
  }
}
