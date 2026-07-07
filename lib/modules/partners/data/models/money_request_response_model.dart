import 'package:front_gestion_minera/modules/partners/domain/entity/money_request_response_entity.dart';

class MoneyRequestResponseModel {

  final bool success;
  final String message;
  final String requestId;
  
  MoneyRequestResponseModel({
    required this.success,
    required this.message,
    required this.requestId
  });

  factory MoneyRequestResponseModel.fromJson(Map<String, dynamic> json) {
    return MoneyRequestResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      requestId: json['data']?['request_id'] ?? '',
    );
  }
  
  //esto. es un mapper transforma este modelo a una entidad
  MoneyRequestResponseEntity toEntity() {
    return MoneyRequestResponseEntity(
      success: success,
      message: message,
      requestId: requestId,
    );
  }


}