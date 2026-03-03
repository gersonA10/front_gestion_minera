class BaseApiOption {
  final int connectTimeout;
  final int receiveTimeout;
  final Map<String, dynamic>? headers;

  BaseApiOption({
    this.connectTimeout = 3000,
    this.receiveTimeout = 3000,
    this.headers,
  });
}
