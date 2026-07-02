import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:front_gestion_minera/utils/greeting_util.dart';
import 'package:front_gestion_minera/utils/session/session_actions.dart';
import 'package:front_gestion_minera/utils/session/user_session.dart';
import 'package:intl/intl.dart';
import 'package:showcaseview/showcaseview.dart';

/// Kit de UI del módulo **Jefe de Personal** (`staff`).
///
/// Centraliza la paleta premium (reutilizando [TColors], sin declarar una
/// cuarta paleta) y un puñado de primitivas para que todas las pantallas del
/// módulo queden consistentes con Hacienda / Socios / Campamento:
/// headers, tarjetas, pills de estado, botón primario y estados vacío/error.
class StaffUi {
  StaffUi._();

  // ── Marca / gradiente hero (mismos valores que Hacienda) ──
  static const primary = TColors.primary; // 0xFF1A56FF
  static const primaryDeep = Color(0xFF0B33B8);
  static const primarySoft = TColors.primaryLight; // 0xFFEEF2FF
  static const surface = TColors.surface;
  static const background = TColors.background;
  static const textPrimary = TColors.textPrimary;
  static const textSecondary = TColors.textSecondary;
  static const muted = Color(0xFF9AA7BF);
  static const border = TColors.border;

  /// Scope único de los coach marks del módulo.
  static const String tutorialScope = 'staff_personal';

  /// Clave de rol para persistir si el jefe de personal ya vio el tutorial.
  static const String tutorialRoleKey = 'jefe_personal';

  /// Sombra estándar de tarjeta (muy sutil, tono navy).
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF0D1B3E).withValues(alpha: 0.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  /// Monto en Bs sin decimales (es-PE usa coma de miles).
  static String money(num v, {bool symbol = true}) {
    final s = NumberFormat('#,##0', 'es_PE').format(v);
    return symbol ? 'Bs $s' : s;
  }

  /// Monto en Bs con 2 decimales (cuotas / montos exactos).
  static String money2(num v, {bool symbol = true}) {
    final s = NumberFormat('#,##0.00', 'es_PE').format(v);
    return symbol ? 'Bs $s' : s;
  }
}

/// Estilo visual de un estado (pill) según un texto de estado del backend.
class StaffStatusStyle {
  final String label;
  final Color color;
  final Color bg;
  const StaffStatusStyle(this.label, this.color, this.bg);

  /// Mapea un estado (en español o inglés) a su estilo de pill canónico.
  static StaffStatusStyle of(String? raw) {
    final s = (raw ?? '').toUpperCase().trim();
    switch (s) {
      case 'APPROVED':
      case 'APROBADO':
      case 'ACTIVO':
      case 'ACTIVE':
        return const StaffStatusStyle(
            'Aprobado', TColors.primary, TColors.primaryLight);
      case 'PAID':
      case 'PAGADO':
      case 'COMPLETED':
      case 'COMPLETADO':
      case 'FINALIZADO':
        return const StaffStatusStyle(
            'Pagado', TColors.statusGreen, TColors.statusGreenBg);
      case 'IN_REVIEW':
      case 'PENDING':
      case 'PENDIENTE':
      case 'EN_REVISION':
      case 'EN REVISIÓN':
        return const StaffStatusStyle(
            'Pendiente', TColors.statusOrange, TColors.statusOrangeBg);
      case 'REJECTED':
      case 'RECHAZADO':
      case 'DENIED':
        return const StaffStatusStyle(
            'Rechazado', Color(0xFFEF4444), Color(0xFFFEF2F2));
      default:
        return StaffStatusStyle(
            raw == null || raw.isEmpty ? '—' : raw,
            TColors.textSecondary,
            TColors.statusGreyBg);
    }
  }
}

/// AppBar claro estándar del módulo: fondo blanco, título oscuro, línea inferior.
PreferredSizeWidget staffAppBar(
  BuildContext context, {
  required String title,
  List<Widget>? actions,
  bool showBack = true,
}) {
  return AppBar(
    backgroundColor: StaffUi.surface,
    surfaceTintColor: StaffUi.surface,
    elevation: 0,
    centerTitle: true,
    automaticallyImplyLeading: showBack,
    iconTheme: const IconThemeData(color: StaffUi.textPrimary),
    title: Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: StaffUi.textPrimary,
        letterSpacing: -0.2,
      ),
    ),
    actions: actions,
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(color: StaffUi.border, height: 1),
    ),
  );
}

/// Tarjeta base: superficie blanca, esquinas 18, borde y sombra suave.
class StaffCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? borderColor;
  final double radius;
  const StaffCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.borderColor,
    this.radius = 18,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: StaffUi.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor ?? StaffUi.border),
      boxShadow: StaffUi.cardShadow,
    );

    if (onTap == null) {
      return Container(padding: padding, decoration: decoration, child: child);
    }
    return Container(
      decoration: decoration,
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Encabezado de sección: título w800 + helper/contador opcional a la derecha.
class StaffSectionTitle extends StatelessWidget {
  final String title;
  final IconData? icon;
  final String? helper;
  final String? trailing;
  const StaffSectionTitle(
    this.title, {
    super.key,
    this.icon,
    this.helper,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 17, color: StaffUi.primary),
          const SizedBox(width: 8),
        ],
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: StaffUi.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
        const Spacer(),
        if (trailing != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: StaffUi.primarySoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              trailing!,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: StaffUi.primary,
              ),
            ),
          )
        else if (helper != null)
          Text(
            helper!,
            style: const TextStyle(
              fontSize: 11.5,
              color: StaffUi.textSecondary,
            ),
          ),
      ],
    );
  }
}

/// Chip de estado: fondo suave + texto fuerte.
class StaffPill extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  final IconData? icon;
  const StaffPill({
    super.key,
    required this.label,
    required this.color,
    required this.bg,
    this.icon,
  });

  /// Construye el pill directamente desde un estado del backend.
  factory StaffPill.status(String? raw, {IconData? icon}) {
    final s = StaffStatusStyle.of(raw);
    return StaffPill(label: s.label, color: s.color, bg: s.bg, icon: icon);
  }

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

/// Tarjeta-métrica (KPI): chip de icono + valor grande + título + helper.
class StaffMetricTile extends StatelessWidget {
  final String value;
  final String title;
  final String? helper;
  final IconData icon;
  final Color color;
  const StaffMetricTile({
    super.key,
    required this.value,
    required this.title,
    required this.icon,
    required this.color,
    this.helper,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StaffUi.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: StaffUi.border),
        boxShadow: StaffUi.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 17, color: color),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 22,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: StaffUi.textPrimary,
            ),
          ),
          if (helper != null) ...[
            const SizedBox(height: 3),
            Text(
              helper!,
              style: const TextStyle(
                fontSize: 11.5,
                height: 1.25,
                color: StaffUi.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Botón primario sólido del módulo (acción principal).
class StaffPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final Color color;
  final double height;
  const StaffPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.color = StaffUi.primary,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
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

/// Botón "glass" translúcido para usar dentro del header hero.
class StaffGlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const StaffGlassButton({super.key, required this.icon, required this.onTap});

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
        child: Icon(icon, color: Colors.white, size: 19),
      ),
    );
  }
}

/// Header hero con gradiente para el shell del módulo. Muestra saludo + nombre
/// del usuario y, debajo, el título/subtítulo de la sección actual (morphing
/// por tab). Reutilizable en todas las pantallas raíz del módulo.
class StaffHeroHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onHelp;
  final bool showLogout;

  /// Acción opcional a la derecha de la fila de título (p. ej. "Historial").
  final Widget? trailing;

  const StaffHeroHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onHelp,
    this.showLogout = true,
    this.trailing,
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
          colors: [StaffUi.primary, StaffUi.primaryDeep],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: -36,
            right: -28,
            child: _circle(140, Colors.white.withValues(alpha: 0.08)),
          ),
          Positioned(
            top: 36,
            right: 56,
            child: _circle(64, Colors.white.withValues(alpha: 0.10)),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              GreetingUtil.getGreeting(),
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.4,
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              UserSession.userName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (onHelp != null) ...[
                        StaffGlassButton(
                          icon: Icons.help_outline_rounded,
                          onTap: onHelp!,
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (showLogout)
                        StaffGlassButton(
                          icon: Icons.logout_rounded,
                          onTap: () => SessionActions.logout(),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.22),
                          ),
                        ),
                        child: Icon(icon, color: Colors.white, size: 21),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.25,
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (trailing != null) ...[
                        const SizedBox(width: 10),
                        trailing!,
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Barra de búsqueda premium reutilizable.
class StaffSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  const StaffSearchField({
    super.key,
    this.controller,
    this.hint = 'Buscar...',
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasText = (controller?.text ?? '').isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        color: StaffUi.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: StaffUi.border),
        boxShadow: StaffUi.cardShadow,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 14,
          color: StaffUi.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 14,
            color: StaffUi.muted,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Icon(Icons.search_rounded,
              color: StaffUi.textSecondary, size: 21),
          suffixIcon: hasText
              ? IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: StaffUi.textSecondary, size: 19),
                  onPressed: onClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}

/// Estado vacío ilustrado (icono en chip + título + descripción centrada).
class StaffEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  const StaffEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: StaffUi.primarySoft,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(icon, size: 34, color: StaffUi.primary),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: StaffUi.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: StaffUi.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Estado de error con botón "Reintentar".
class StaffErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const StaffErrorState({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: TColors.statusOrangeBg,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.error_outline_rounded,
                  size: 34, color: TColors.statusOrange),
            ),
            const SizedBox(height: 18),
            Text(
              'Ocurrió un problema',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: StaffUi.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: StaffUi.textSecondary,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: StaffUi.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 22, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Loader de marca premium: excavadora animada en su lugar (siempre visible,
/// con sombra y leve balanceo de "trabajo"), texto "Cargando" con puntos que
/// laten en onda, y una barra de progreso indeterminada.
class StaffLoader extends StatefulWidget {
  final String? label;
  final String assetPath;
  const StaffLoader({
    super.key,
    this.label = 'Cargando',
    this.assetPath = 'assets/img/excavadora.png',
  });

  @override
  State<StaffLoader> createState() => _StaffLoaderState();
}

class _StaffLoaderState extends State<StaffLoader>
    with TickerProviderStateMixin {
  late final AnimationController _bob;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _bob = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1150),
    )..repeat(reverse: true);
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _bob.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 160,
            height: 124,
            child: AnimatedBuilder(
              animation: _bob,
              builder: (context, _) {
                final t = Curves.easeInOut.transform(_bob.value); // 0..1
                final lift = -9.0 * t;
                final tilt = (t - 0.5) * 0.05;
                final shadow = 1.0 - 0.28 * t;
                return Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Positioned(
                      bottom: 8,
                      child: Container(
                        width: 104 * shadow,
                        height: 15 * shadow,
                        decoration: BoxDecoration(
                          color: StaffUi.primary
                              .withValues(alpha: 0.05 + 0.10 * shadow),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(0, lift),
                      child: Transform.rotate(
                        angle: tilt,
                        child: Image.asset(
                          widget.assetPath,
                          width: 124,
                          height: 104,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          if (widget.label != null) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.label!,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: StaffUi.textSecondary,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(width: 6),
                for (int i = 0; i < 3; i++)
                  AnimatedBuilder(
                    animation: _pulse,
                    builder: (context, _) {
                      final s = (math.sin(
                                _pulse.value * 2 * math.pi - i * 0.9,
                              ) +
                              1) /
                          2;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Container(
                          width: 5.5,
                          height: 5.5,
                          decoration: BoxDecoration(
                            color: StaffUi.primary
                                .withValues(alpha: 0.30 + 0.70 * s),
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: 132,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: const LinearProgressIndicator(
                minHeight: 4,
                backgroundColor: StaffUi.primarySoft,
                valueColor: AlwaysStoppedAnimation<Color>(StaffUi.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Envuelve un widget como objetivo de coach mark con el estilo del módulo.
Widget staffCoachMark({
  required GlobalKey key,
  required String title,
  required String description,
  required Widget child,
}) {
  return Showcase(
    key: key,
    scope: StaffUi.tutorialScope,
    title: title,
    description: description,
    targetBorderRadius: BorderRadius.circular(16),
    targetPadding: const EdgeInsets.all(8),
    tooltipBackgroundColor: StaffUi.surface,
    tooltipBorderRadius: BorderRadius.circular(16),
    titleTextStyle: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w800,
      color: StaffUi.textPrimary,
      letterSpacing: -0.2,
    ),
    descTextStyle: const TextStyle(
      fontSize: 13,
      height: 1.4,
      color: StaffUi.textSecondary,
    ),
    child: child,
  );
}

/// Overlay de envío/proceso con el [StaffLoader] en un card blanco sobre un
/// velo oscuro. Pensado para usarse como hijo directo de un [Stack]
/// (usa [Positioned.fill] para cubrir toda la pantalla).
class StaffSubmitOverlay extends StatelessWidget {
  final String label;
  final String? subtitle;

  const StaffSubmitOverlay({
    super.key,
    this.label = 'Cargando',
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.35),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 160,
                    height: 148,
                    child: StaffLoader(label: null),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: StaffUi.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: StaffUi.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
