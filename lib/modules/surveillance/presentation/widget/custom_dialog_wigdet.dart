import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/text_util.dart';

class CustomDialog extends StatelessWidget {
  const CustomDialog({
    super.key,
    required this.onPressed,
    required this.content,
    required this.title,
    this.isDanger = false,
    this.text,
  });

  final void Function()? onPressed;
  final Widget content;
  final String title;
  final bool isDanger;
  final TextEditingController? text;

  @override
  Widget build(BuildContext context) {
    const background = Color(0xff1b2b44);

    final primaryColor = isDanger
        ? const Color(0xffe53935)
        : const Color(0xff22c55e);

    final icon = isDanger ? Icons.close : Icons.check;

    return Dialog(
      backgroundColor: background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: .15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: primaryColor, size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.mainStyleWhite14Bold(
                context,
              ).copyWith(fontSize: 16, letterSpacing: 0.3),
            ),
            const SizedBox(height: 10),
            DefaultTextStyle(
              style: AppTextStyles.mainStyleWhite12(
                context,
              ).copyWith(color: Colors.white70),
              textAlign: TextAlign.center,
              child: content,
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      text?.clear();
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Cancelar"),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, size: 18, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          isDanger ? "Rechazar" : "Aprobar",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
