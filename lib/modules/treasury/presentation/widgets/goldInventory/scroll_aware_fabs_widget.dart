import 'package:front_gestion_minera/utils/constants/color.constant.dart';

import '../widgtes.dart';

class ScrollAwareFabs extends StatelessWidget {
  final bool visible;
  final VoidCallback onAddTap;
  final VoidCallback onMoneyTap;

  const ScrollAwareFabs({
    super.key,
    required this.visible,
    required this.onAddTap,
    required this.onMoneyTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: visible ? Offset.zero : const Offset(0, 2.5),
      duration: const Duration(milliseconds: 300),
      curve: visible ? Curves.easeOut : Curves.easeIn,
      child: AnimatedOpacity(
        opacity: visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FabButton(
              icon: Icons.attach_money_rounded,
              backgroundColor: TColors.goldAccent,
              onTap: onMoneyTap,
              tooltip: 'Registrar venta',
            ),
            const SizedBox(width: 12),
            FabButton(
              icon: Icons.add_rounded,
              backgroundColor: TColors.primary,
              onTap: onAddTap,
              tooltip: 'Nueva extracción',
            ),
          ],
        ),
      ),
    );
  }
}
