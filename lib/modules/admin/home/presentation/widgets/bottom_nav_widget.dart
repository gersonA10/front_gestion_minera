import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

class BottomNavWidget extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Keys de los coach marks: una por pestaña. Si es `null`, el bottom nav se
  /// dibuja normal (sin tutorial). En showcaseview 5.x estas keys son
  /// identificadores de registro, por eso viven en el State que las crea.
  final List<GlobalKey>? showcaseKeys;

  /// Scope del recorrido guiado. Debe coincidir con el ShowcaseView registrado
  /// en la pantalla contenedora.
  final String? showcaseScope;

  const BottomNavWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.showcaseKeys,
    this.showcaseScope,
  });

  @override
  Widget build(BuildContext context) {
    const items = [
      _NavItem(
        icon: Icons.inbox_outlined,
        label: 'Solicitudes',
        tutorialTitle: 'Bandeja de Solicitudes',
        tutorialDescription:
            'Aquí llegan las solicitudes de de egreso '
            'Revísalas para aprobarlas o rechazarlas.',
      ),
      _NavItem(
        icon: Icons.history_outlined,
        label: 'Historial',
        tutorialTitle: 'Historial',
        tutorialDescription:
            'Consulta todas las solicitudes ya procesadas y el resultado de '
            'cada una.',
      ),
      _NavItem(
        icon: Icons.account_balance_wallet_outlined,
        label: 'Aportes',
        tutorialTitle: 'Aportes',
        tutorialDescription:
            'Registra y administra los aportes que hacen los socios al fondo.',
      ),
      _NavItem(
        icon: Icons.people_outline,
        label: 'Usuarios',
        tutorialTitle: 'Usuarios',
        tutorialDescription:
            'Gestiona los usuarios del sistema: crea, edita y administra sus '
            'accesos.',
      ),
    ];

    final keys = showcaseKeys;
    final scope = showcaseScope;
    assert(
      keys == null || keys.length == items.length,
      'El número de keys de coach marks (${keys.length}) debe coincidir con '
      'la cantidad de pestañas (${items.length}).',
    );

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final selected = i == currentIndex;
          final navContent = GestureDetector(
            onTap: () => onTap(i),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFEFF6FF)
                        : const Color(0xFFEFF6FF).withValues(alpha: 0.0),
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
          );

          if (keys == null || scope == null) {
            return Expanded(child: navContent);
          }

          return Expanded(
            child: Showcase(
              key: keys[i],
              scope: scope,
              title: items[i].tutorialTitle,
              description: items[i].tutorialDescription,
              targetBorderRadius: BorderRadius.circular(14),
              targetPadding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 8,
              ),
              tooltipBackgroundColor: Colors.white,
              tooltipBorderRadius: BorderRadius.circular(16),
              titleTextStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0D1B2A),
                letterSpacing: -0.2,
              ),
              descTextStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                height: 1.4,
                color: Color(0xFF64748B),
              ),
              child: navContent,
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

  /// Título del coach mark para esta pestaña.
  final String tutorialTitle;

  /// Descripción del coach mark: qué hace el admin desde esta sección.
  final String tutorialDescription;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.tutorialTitle,
    required this.tutorialDescription,
  });
}
