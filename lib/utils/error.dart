import 'package:front_gestion_minera/core/networking/base_api_exception.dart';

/// Mensaje a mostrar al usuario ante un error de API.
///
/// El backend manda validaciones de negocio en 400 con un `message` ya redactado
/// para el usuario ("Stock insuficiente. Solo hay 599.95g...") pero sin `error_key`,
/// así que `mapErrorMessage(key)` las convertía todas en "Ocurrió un error inesperado".
/// Aquí se prioriza ese mensaje y se cae al genérico solo cuando no hay uno útil
/// (timeouts, offline, o respuestas sin cuerpo).
String apiErrorMessage(BaseApiException error) {
  final serverMessage = error.message.trim();
  final isUseless = serverMessage.isEmpty ||
      serverMessage == 'Error inesperado' ||
      serverMessage == 'Sesión expirada';

  if (!isUseless && _hasResponseBody(error)) return serverMessage;
  return mapErrorMessage(error.key);
}

/// Los errores de red (sin respuesta del servidor) no traen mensaje de negocio.
bool _hasResponseBody(BaseApiException error) =>
    error.response != null && error.response!.data is Map;

String mapErrorMessage(String key) {
  switch (key) {
    case 'dio_connect_timeout':
    case 'dio_receive_timeout':
    case 'dio_send_timeout':
    case 'dio_offline':
      return "No tienes conexión a internet.";

    case 'dio_response':
      return "Error del servidor.";

    default:
      return "Ocurrió un error inesperado.";
  }
}
