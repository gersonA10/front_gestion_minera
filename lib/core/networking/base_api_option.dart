class BaseApiOption {
  final int connectTimeout;
  final int receiveTimeout;
  final Map<String, dynamic>? headers;

  BaseApiOption({
    this.connectTimeout = 30000,
    this.receiveTimeout = 30000,
    this.headers,
  });
}
