import 'package:flutter/material.dart';

class ExcavatorLoader extends StatefulWidget {
  final double width;
  final double height;
  final String assetPath;
  final Duration duration;

  const ExcavatorLoader({
    super.key,
    this.width = 170,
    this.height = 170,
    this.assetPath = 'assets/img/excavadora.png',
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<ExcavatorLoader> createState() => _ExcavatorLoaderState();
}

class _ExcavatorLoaderState extends State<ExcavatorLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: widget.duration)..repeat();

    _animation = Tween<double>(
      begin: 1.8,
      end: -1.8,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return FractionalTranslation(
          translation: Offset(_animation.value, 0),
          child: child,
        );
      },
      child: Image.asset(
        widget.assetPath,
        width: widget.width,
        height: widget.height,
        fit: BoxFit.contain,
      ),
    );
  }
}