String mapErrorMessage(String key) {
  switch (key) {
    case 'dio_connect_timeout':
    case 'dio_receive_timeout':
    case 'dio_send_timeout':
    case 'dio_offline':
      return "No tienes conexión a internet.";

    case 'dio_unauthorized':
      return "Tu sesión ha expirado.";

    case 'dio_response':
      return "Error del servidor.";

    default:
      return "Ocurrió un error inesperado.";
  }
}
