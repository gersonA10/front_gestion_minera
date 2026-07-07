import 'dart:async';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/core/services/connectivity_service.dart';
import 'package:front_gestion_minera/core/widgets/no_internet_screen.dart';

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;

  const ConnectivityWrapper({super.key, required this.child});

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  late bool _isConnected;
  StreamSubscription<bool>? _subscription;

  @override
  void initState() {
    super.initState();
    _isConnected = ConnectivityService.instance.isConnected;
    _subscription = ConnectivityService.instance.stream.listen((connected) {
      if (mounted) setState(() => _isConnected = connected);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: child,
          ),
          child: _isConnected
              ? const SizedBox.shrink(key: ValueKey('online'))
              : NoInternetScreen(
                  key: const ValueKey('offline'),
                  onRetry: ConnectivityService.instance.recheck,
                ),
        ),
      ],
    );
  }
}
