import 'package:flutter/material.dart';

/// Paleta y helpers compartidos del módulo de préstamos de socios (Hacienda).
class MlColors {
  static const primary = Color(0xFF1A56FF);
  static const primaryDeep = Color(0xFF0B33B8);
  static const gold = Color(0xFFEFC805);
  static const goldDeep = Color(0xFFB8930A);
  static const green = Color(0xFF17A05D);
  static const amber = Color(0xFFC47A00);
  static const red = Color(0xFFD32F2F);
  static const background = Color(0xFFF5F7FB);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF0D1B3E);
  static const textSecondary = Color(0xFF6B7A99);
  static const border = Color(0xFFE8EDF5);
}

const mlMonths = [
  'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
  'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
];

String mlNum(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

String mlMoney(double v, {required bool isGrams}) =>
    isGrams ? '${mlNum(v)} g' : 'Bs ${mlNum(v)}';

String mlDate(DateTime? d) =>
    d == null ? '—' : '${d.day.toString().padLeft(2, '0')} ${mlMonths[d.month - 1]} ${d.year}';

class MlStatusStyle {
  final Color fg;
  final Color bg;
  final IconData icon;
  final String label;
  const MlStatusStyle(this.fg, this.bg, this.icon, this.label);
}

/// Estilo por estado, aceptando tanto el `status` (PENDING…) como la etiqueta
/// (`En Revisión`, `Vigente`…).
MlStatusStyle mlStatusStyle(String s) {
  switch (s.toLowerCase()) {
    case 'paid':
    case 'pagado':
      return const MlStatusStyle(
          MlColors.green, Color(0xFFE7F7EE), Icons.check_circle_rounded, 'Pagado');
    case 'approved':
    case 'vigente':
      return const MlStatusStyle(
          Color(0xFF2457C5), Color(0xFFE8F0FE), Icons.verified_rounded, 'Vigente');
    case 'rejected':
    case 'rechazado':
      return const MlStatusStyle(
          MlColors.red, Color(0xFFFFEBEE), Icons.cancel_rounded, 'Rechazado');
    case 'cancelled':
    case 'cancelado':
      return const MlStatusStyle(
          Color(0xFF6B7A99), Color(0xFFEDEFF4), Icons.block_rounded, 'Cancelado');
    case 'pending':
    case 'en revisión':
    case 'en revision':
    default:
      return const MlStatusStyle(MlColors.amber, Color(0xFFFFF4E5),
          Icons.hourglass_top_rounded, 'En Revisión');
  }
}

// ─── Widgets compartidos ─────────────────────────────────────────────────────

class MlGlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const MlGlassButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class MlGradientHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onBack;
  final List<Widget> actions;
  const MlGradientHeader({
    super.key,
    required this.title,
    required this.onBack,
    this.subtitle,
    this.actions = const [],
  });

  Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [MlColors.primary, MlColors.primaryDeep],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -24,
            child: _circle(120, Colors.white.withValues(alpha: 0.08)),
          ),
          Positioned(
            top: 26,
            right: 36,
            child: _circle(64, MlColors.gold.withValues(alpha: 0.18)),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      MlGlassButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: onBack,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      ...actions,
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.35,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MlChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const MlChip({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [MlColors.primary, MlColors.primaryDeep],
                )
              : null,
          color: active ? null : MlColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? Colors.transparent : MlColors.border,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: MlColors.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : MlColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class MlStatusBadge extends StatelessWidget {
  final MlStatusStyle style;
  const MlStatusBadge({super.key, required this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: style.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 13, color: style.fg),
          const SizedBox(width: 4),
          Text(
            style.label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: style.fg,
            ),
          ),
        ],
      ),
    );
  }
}

class MlStateView extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  const MlStateView({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: color.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: MlColors.textPrimary,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: MlColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
