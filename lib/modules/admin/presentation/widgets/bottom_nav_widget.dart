import 'package:flutter/material.dart';

class BottomNavWidget extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavWidget({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const items = [
      _NavItem(icon: Icons.inbox_outlined, label: 'Solicitudes'),
      _NavItem(icon: Icons.history_outlined, label: 'Historial'),
      _NavItem(icon: Icons.account_balance_wallet_outlined, label: 'Aportes'),
    ];

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final selected = i == currentIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFEFF6FF)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      items[i].icon,
                      size: 22,
                      color: selected
                          ? const Color(0xFF1A3557)
                          : const Color(0xFFCBD5E1),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    items[i].label,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                      color: selected
                          ? const Color(0xFF1A3557)
                          : const Color(0xFFCBD5E1),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}


class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}