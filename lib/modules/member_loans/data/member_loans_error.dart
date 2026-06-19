import 'package:front_gestion_minera/core/networking/base_api_exception.dart';
import 'package:front_gestion_minera/utils/error.dart';

/// Devuelve un mensaje listo para el usuario. Prioriza el `message` que envía el
/// backend en los errores de validación (400), tal como pide el doc.
String memberLoansError(Object error) {
  if (error is BaseApiException) {
    final data = error.response?.data;
    if (data is Map &&
        data['message'] is String &&
        (data['message'] as String).trim().isNotEmpty) {
      return data['message'] as String;
    }
    return mapErrorMessage(error.key);
  }
  return 'Ocurrió un error inesperado.';
}
