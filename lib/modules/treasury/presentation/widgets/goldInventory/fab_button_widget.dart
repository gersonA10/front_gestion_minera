import 'package:flutter/material.dart';



class FabButton extends StatefulWidget {
  final IconData icon;
  final Color backgroundColor;
  final VoidCallback onTap;
  final String tooltip;

  const FabButton({super.key, 
    required this.icon,
    required this.backgroundColor,
    required this.onTap,
    required this.tooltip,
  });

  @override
  State<FabButton> createState() => _FabButtonState();
}

class _FabButtonState extends State<FabButton> {
  bool _pressing = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressing = true),
        onTapUp: (_) {
          setState(() => _pressing = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressing = false),
        child: AnimatedScale(
          scale: _pressing ? 0.92 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.backgroundColor.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(widget.icon, color: Colors.white, size: 26),
          ),
        ),
      ),
    );
  }
}
