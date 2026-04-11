
import '../../../domain/entity/entity.dart';

class RecordContributionPaymentDataModel  extends RecordContributionPaymentDataEntity {

    RecordContributionPaymentDataModel({
        required super.detailId,
        required super.transactionId,
    });

    factory RecordContributionPaymentDataModel.fromJson(Map<String, dynamic> json) => RecordContributionPaymentDataModel(
        detailId: json["detail_id"],
        transactionId: json["transaction_id"],
    );
}

class RecordContributionPaymentRequestModel extends RecordContributionPaymentRequestEntity {

    RecordContributionPaymentRequestModel({
        required super.detailid,
        required super.cashRegisterid,
        required super.observacion,
        required super.evidencia,
    });
factory RecordContributionPaymentRequestModel.fromEntity(RecordContributionPaymentRequestEntity entity) {
    return RecordContributionPaymentRequestModel(
      detailid: entity.detailid,
      cashRegisterid: entity.cashRegisterid,
      observacion: entity.observacion,
      evidencia: entity.evidencia,
    );
  }

  Map<String, dynamic> toFormDataMap() => {
    "detail_id": detailid,
    "cash_register_id": cashRegisterid,
    "observacion": observacion,
    "evidencia": evidencia,
  };
}