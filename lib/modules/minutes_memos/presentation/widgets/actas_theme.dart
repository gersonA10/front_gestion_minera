import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/session/session_actions.dart';

/// Paleta y piezas de UI compartidas del módulo de Actas y Memorandos.
///
/// Misma identidad visual azul que socios y hacienda, para que toda la app se
/// sienta como un único producto. Se centraliza aquí para no duplicar colores
/// ni widgets de cabecera en cada pantalla del módulo.
class AC {
  AC._();

  static const primary = Color(0xFF1A56FF);
  static const primaryDeep = Color(0xFF0B33B8);
  static const gold = Color(0xFFEFC805);

  static const surface = Color(0xFFFFFFFF);
  static const background = Color(0xFFF5F7FB);

  static const textPrimary = Color(0xFF0D1B3E);
  static const textSecondary = Color(0xFF6B7A99);

  static const border = Color(0xFFE8EDF5);
  static const cardShadow = Color(0x0A1A56FF);

  /// Acento por tipo de documento.
  static const acta = Color(0xFF1A56FF); // azul → acta
  static const memo = Color(0xFFFF8C42); // naranja → memorando

  // Estados.
  static const green = Color(0xFF17A05D);
  static const greenBg = Color(0xFFE6F6EE);
  static const amber = Color(0xFFC47A00);
  static const amberBg = Color(0xFFFBF1DC);
  static const danger = Color(0xFFD32F2F);
}

/// Botón "glass" de ícono que vive sobre el header de color.
class AcGlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  const AcGlassIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.28),
            width: 1,
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );

    if (tooltip == null) return button;
    return Tooltip(message: tooltip, child: button);
  }
}

/// Botón de logout estilo "glass" sobre el header de color.
class AcGlassLogoutButton extends StatefulWidget {
  const AcGlassLogoutButton({super.key});

  @override
  State<AcGlassLogoutButton> createState() => _AcGlassLogoutButtonState();
}

class _AcGlassLogoutButtonState extends State<AcGlassLogoutButton> {
  bool _pressing = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressing = true),
      onTapUp: (_) {
        setState(() => _pressing = false);
        SessionActions.logout();
      },
      onTapCancel: () => setState(() => _pressing = false),
      child: AnimatedScale(
        scale: _pressing ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.28),
              width: 1,
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.logout_rounded, color: Colors.white, size: 16),
              SizedBox(width: 6),
              Text(
                'Salir',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// AppBar con degradado azul para las pantallas internas del módulo
/// (registro y detalles). Mantiene la identidad del header principal pero en
/// formato compacto, con botón de retroceso y una acción opcional.
class AcGradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? action;

  const AcGradientAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.action,
  });

  @override
  Size get preferredSize => Size.fromHeight(subtitle == null ? 64 : 80);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AC.primary, AC.primaryDeep],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 16, 12),
          child: Row(
            children: [
              IconButton(
                onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                splashRadius: 22,
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ?action,
            ],
          ),
        ),
      ),
    );
  }
}
