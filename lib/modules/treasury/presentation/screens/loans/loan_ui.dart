import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Kit de estilo claro ("azul limpio") compartido por el módulo de
/// Préstamos Internos (préstamos de la empresa con terceros externos).
///
/// Centraliza la paleta y un puñado de primitivas para mantener todas las
/// pantallas del módulo (home, detalle, nuevo, simulación, pago) consistentes.
class LoanUi {
  LoanUi._();

  // Base
  static const bg = Color(0xFFF6F8FB);
  static const surface = Colors.white;
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const muted = Color(0xFF9CA3AF);
  static const border = Color(0xFFEDF0F4);
  static const fieldBg = Color(0xFFF3F4F6);

  // Marca
  static const primary = Color(0xFF2563EB);
  static const primaryDeep = Color(0xFF1D4ED8);
  static const primarySoft = Color(0xFFEFF4FF);

  // Estados
  static const activo = Color(0xFF2563EB);
  static const activoBg = Color(0xFFEFF4FF);
  static const mora = Color(0xFFEF4444);
  static const moraBg = Color(0xFFFEF2F2);
  static const finalizado = Color(0xFF16A34A);
  static const finalizadoBg = Color(0xFFF0FDF4);
  static const pendiente = Color(0xFFF59E0B);
  static const pendienteBg = Color(0xFFFFF7EB);

  /// Formatea un monto en Bs sin decimales (es-PE usa coma de miles).
  static String money(num v, {bool symbol = true}) {
    final s = NumberFormat('#,##0', 'es_PE').format(v);
    return symbol ? 'Bs $s' : s;
  }

  /// Igual que [money] pero con 2 decimales (cuotas / montos exactos).
  static String money2(num v, {bool symbol = true}) {
    final s = NumberFormat('#,##0.00', 'es_PE').format(v);
    return symbol ? 'Bs $s' : s;
  }
}

/// AppBar claro estándar del módulo: fondo blanco, título oscuro, flecha atrás.
PreferredSizeWidget loanAppBar(
  BuildContext context, {
  required String title,
  List<Widget>? actions,
  bool showBack = true,
}) {
  return AppBar(
    backgroundColor: LoanUi.surface,
    surfaceTintColor: LoanUi.surface,
    elevation: 0,
    centerTitle: true,
    automaticallyImplyLeading: showBack,
    iconTheme: const IconThemeData(color: LoanUi.textPrimary),
    title: Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: LoanUi.textPrimary,
      ),
    ),
    actions: actions,
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(color: LoanUi.border, height: 1),
    ),
  );
}

/// Contenedor blanco con borde y esquinas redondeadas (tarjeta base).
class LoanCardBox extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? borderColor;
  const LoanCardBox({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: LoanUi.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? LoanUi.border),
      ),
      child: child,
    );
    if (onTap == null) return box;
    return GestureDetector(onTap: onTap, child: box);
  }
}

/// Encabezado de sección: ícono + título + contador opcional a la derecha.
class LoanSectionTitle extends StatelessWidget {
  final String title;
  final IconData? icon;
  final String? trailing;
  const LoanSectionTitle(this.title, {super.key, this.icon, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 17, color: LoanUi.primary),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: LoanUi.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
        ),
        if (trailing != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: LoanUi.primarySoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              trailing!,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: LoanUi.primary,
              ),
            ),
          ),
      ],
    );
  }
}

/// Chip de estado (texto + color de marca). Fondo suave + texto fuerte.
class LoanPill extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  final IconData? icon;
  const LoanPill({
    super.key,
    required this.label,
    required this.color,
    required this.bg,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pareja etiqueta/valor en columna (para resúmenes de montos).
class LoanStatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final CrossAxisAlignment align;
  const LoanStatTile({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.align = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
            color: LoanUi.muted,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: valueColor ?? LoanUi.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Barra de progreso con etiqueta y porcentaje arriba.
class LoanProgress extends StatelessWidget {
  final double value; // 0..1
  final Color color;
  final String? leftLabel;
  final bool showPercent;
  const LoanProgress({
    super.key,
    required this.value,
    required this.color,
    this.leftLabel,
    this.showPercent = true,
  });

  @override
  Widget build(BuildContext context) {
    final v = value.isNaN ? 0.0 : value.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leftLabel != null || showPercent)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (leftLabel != null)
                  Text(
                    leftLabel!,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  )
                else
                  const SizedBox.shrink(),
                if (showPercent)
                  Text(
                    '${(v * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: LoanUi.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: v,
            minHeight: 6,
            backgroundColor: LoanUi.fieldBg,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

/// Botón primario sólido del módulo (acción principal).
class LoanPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color color;
  const LoanPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color = LoanUi.primary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: color.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child:  Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
