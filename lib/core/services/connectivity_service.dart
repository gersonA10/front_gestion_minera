import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  ConnectivityService._();
  static final ConnectivityService instance = ConnectivityService._();

  final _connectivity = Connectivity();
  final _controller = StreamController<bool>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _isConnected = true;
  bool _initialized = false;

  Stream<bool> get stream => _controller.stream;
  bool get isConnected => _isConnected;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    _isConnected = await _hasInternetAccess();

    _subscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
      onError: (e) => debugPrint('[ConnectivityService] stream error: $e'),
    );
  }

  Future<void> _onConnectivityChanged(List<ConnectivityResult> results) async {
    final hasNetwork = results.any((r) => r != ConnectivityResult.none);

    if (!hasNetwork) {
      _emit(false);
      return;
    }

    // Red disponible — verificar acceso real a internet
    final hasInternet = await _hasInternetAccess();
    _emit(hasInternet);
  }

  Future<bool> _hasInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  void _emit(bool connected) {
    if (_isConnected == connected) return;
    _isConnected = connected;
    _controller.add(connected);
  }

  /// Fuerza una re-verificación manual del estado de internet.
  Future<bool> recheck() async {
    final connected = await _hasInternetAccess();
    _emit(connected);
    return connected;
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
