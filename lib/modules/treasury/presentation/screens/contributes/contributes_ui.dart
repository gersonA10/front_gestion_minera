import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

/// Kit de UI del módulo de **Aportes** (Hacienda). Estética clara y premium,
/// consistente con el resto de tesorería. Centraliza paleta, el header con
/// degradado y un botón uniforme de "volver al inicio" (al home de Hacienda).
class CUi {
  CUi._();

  // Base (alineada a TColors para coherencia con toda la app)
  static const bg = TColors.background; // 0xFFF5F7FB
  static const surface = TColors.surface; // white
  static const textPrimary = TColors.textPrimary; // 0xFF0D1B3E
  static const textSecondary = TColors.textSecondary; // 0xFF6B7A99
  static const border = TColors.border; // 0xFFE8EDF5
  static const muted = Color(0xFF9AA7C2);
  static const fieldBg = Color(0xFFF1F4F9);

  // Marca
  static const primary = TColors.primary; // 0xFF1A56FF
  static const primaryDeep = Color(0xFF0B33B8);
  static const primarySoft = Color(0xFFEDF2FF);

  // Estados
  static const success = TColors.success; // 0xFF16A34A
  static const successBg = Color(0xFFE7F7EE);
  static const warning = Color(0xFFC47A00);
  static const warningBg = Color(0xFFFFF4E2);
  static const danger = Color(0xFFD32F2F);
  static const dangerBg = Color(0xFFFDECEC);

  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDeep],
  );

  /// Vuelve al inicio de Hacienda (menú de tesorería), sin importar la
  /// profundidad del stack de navegación.
  static void goHome(BuildContext context) {
    context.router.popUntilRouteWithName(TreasuryRoute.name);
  }
}

/// Botón circular translúcido para usar sobre el header con degradado.
class CGlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  const CGlassButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final btn = GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
    return tooltip == null ? btn : Tooltip(message: tooltip!, child: btn);
  }
}

/// Header hero con degradado para pantallas principales del módulo.
/// Incluye atrás, título/subtítulo, acciones y un botón opcional de inicio.
/// El slot [bottom] permite incrustar métricas u otros widgets.
class ContribHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final bool showHome;
  final Widget? bottom;
  const ContribHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.showHome = true,
    this.bottom,
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
        gradient: CUi.gradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: -28,
            right: -20,
            child: _circle(120, Colors.white.withValues(alpha: 0.07)),
          ),
          Positioned(
            top: 30,
            right: 40,
            child: _circle(56, Colors.white.withValues(alpha: 0.06)),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CGlassButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => context.router.maybePop(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                            if (subtitle != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  subtitle!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      ...actions,
                      if (showHome) ...[
                        if (actions.isNotEmpty) const SizedBox(width: 8),
                        CGlassButton(
                          icon: Icons.home_rounded,
                          tooltip: 'Volver al inicio',
                          onTap: () => CUi.goHome(context),
                        ),
                      ],
                    ],
                  ),
                  if (bottom != null) ...[
                    const SizedBox(height: 18),
                    bottom!,
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

/// App bar clara estándar para pantallas internas, con botón opcional de inicio.
PreferredSizeWidget contribAppBar(
  BuildContext context, {
  required String title,
  bool showBack = true,
  bool showHome = true,
  List<Widget> actions = const [],
}) {
  return AppBar(
    backgroundColor: CUi.surface,
    surfaceTintColor: CUi.surface,
    elevation: 0,
    centerTitle: true,
    automaticallyImplyLeading: showBack,
    iconTheme: const IconThemeData(color: CUi.textPrimary),
    title: Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: CUi.textPrimary,
      ),
    ),
    actions: [
      ...actions,
      if (showHome)
        Padding(
          padding: const EdgeInsets.only(right: 6),
          child: IconButton(
            tooltip: 'Volver al inicio',
            icon: const Icon(Icons.home_rounded, color: CUi.primary),
            onPressed: () => CUi.goHome(context),
          ),
        ),
    ],
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(color: CUi.border, height: 1),
    ),
  );
}

/// Tarjeta blanca base con sombra sutil.
class CCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  const CCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: CUi.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CUi.border),
        boxShadow: [
          BoxShadow(
            color: CUi.primary.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
    if (onTap == null) return box;
    return GestureDetector(onTap: onTap, child: box);
  }
}

/// Encabezado de sección con ícono + título + contador opcional.
class CSectionTitle extends StatelessWidget {
  final String title;
  final IconData? icon;
  final String? trailing;
  const CSectionTitle(this.title, {super.key, this.icon, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: CUi.primary),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: CUi.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
        ),
        if (trailing != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: CUi.primarySoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              trailing!,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: CUi.primary,
              ),
            ),
          ),
      ],
    );
  }
}

/// Chip de estado (texto + color sobre fondo suave).
class CPill extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  final IconData? icon;
  const CPill({
    super.key,
    required this.label,
    required this.color,
    required this.bg,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Etiqueta/valor en columna (resúmenes de montos).
class CStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final CrossAxisAlignment align;
  const CStat({
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
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: CUi.textSecondary,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: valueColor ?? CUi.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Barra de progreso con etiqueta + porcentaje opcional arriba.
class CProgress extends StatelessWidget {
  final double value; // 0..1
  final Color color;
  final String? leftLabel;
  final bool showPercent;
  const CProgress({
    super.key,
    required this.value,
    this.color = CUi.primary,
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
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  leftLabel ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: CUi.textPrimary,
                  ),
                ),
                if (showPercent)
                  Text(
                    '${(v * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: CUi.textPrimary,
                    ),
                  ),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: v,
            minHeight: 8,
            backgroundColor: CUi.border,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

/// Botón primario sólido.
class CPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final Color color;
  const CPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.color = CUi.primary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: color.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : Row(
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

/// Botón secundario (contorno).
class COutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  const COutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: CUi.textPrimary,
          side: const BorderSide(color: CUi.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 6),
              Icon(icon, size: 16),
            ],
          ],
        ),
      ),
    );
  }
}

/// Estado vacío / error centrado y amable.
class CStateView extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  const CStateView({
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
              width: 92,
              height: 92,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 42, color: color.withValues(alpha: 0.75)),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: CUi.textPrimary,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: CUi.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
