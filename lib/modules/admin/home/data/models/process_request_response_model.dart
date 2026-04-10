import '../../domain/entity/entity.dart';

class ProcessRequestResponseModel {
  final String message;
  final String descripcion;
  final String estadoGlobalResultante;

  ProcessRequestResponseModel({
    required this.message,
    required this.descripcion,
    required this.estadoGlobalResultante,
  });

  factory ProcessRequestResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    
    return ProcessRequestResponseModel(
      message: json['message'] ?? 'Operación procesada',
      descripcion: data['descripcion'] ?? '',
      estadoGlobalResultante: data['estado_global_resultante'] ?? '',
    );
  }

  ProcessRequestResponseEntity toEntity() {
    return ProcessRequestResponseEntity(
      message: message,
      descripcion: descripcion,
      estadoGlobalResultante: estadoGlobalResultante,
    );
  }
}