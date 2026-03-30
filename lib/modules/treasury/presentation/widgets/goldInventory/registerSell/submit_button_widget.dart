import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

class SubmitButton extends StatefulWidget {
  final VoidCallback? onTap;
  final bool isLoading;
  const SubmitButton({super.key, required this.onTap, required this.isLoading});

  @override
  State<SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<SubmitButton> {
  bool _pressing = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null
          ? (_) => setState(() => _pressing = true)
          : null,
      onTapUp: widget.onTap != null
          ? (_) {
              setState(() => _pressing = false);
              widget.onTap!();
            }
          : null,
      onTapCancel: () => setState(() => _pressing = false),
      child: AnimatedScale(
        scale: _pressing ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 54,
          width: double.infinity,
          decoration: BoxDecoration(
            color: TColors.appMainColor.withOpacity(
              widget.isLoading ? 0.6 : 1.0,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: TColors.appMainColor.withValues(alpha: 0.30),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: widget.isLoading
              ? const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.visibility_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Vista Previa',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
