import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/staff_ui.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

/// Tarjeta de trabajador en la lista de personal. Toda la tarjeta es táctil y
/// navega al perfil del empleado.
class WorkerCardWidget extends StatelessWidget {
  final String employeeId;
  final String image;
  final String name;
  final String position;
  final String location;
  final String status;
  final String actionText;

  /// `true` si el trabajador registró asistencia hoy → muestra el sello "Hoy".
  final bool workedToday;

  const WorkerCardWidget({
    super.key,
    required this.employeeId,
    required this.image,
    required this.name,
    required this.position,
    required this.location,
    required this.status,
    this.actionText = 'Ver perfil',
    this.workedToday = false,
  });

  String get _initials {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts[1].characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final style = _WorkerStatusStyle.of(status);
    final isInactive = status.toLowerCase() == 'inactivo';

    return StaffCard(
      padding: const EdgeInsets.all(14),
      onTap: () =>
          context.router.push(WorkerProfileRoute(employeeId: employeeId)),
      child: Row(
        children: [
          _Avatar(image: image, initials: _initials, dotColor: style.dot),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: StaffUi.textPrimary,
                          letterSpacing: -0.2,
                          height: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    StaffPill(
                      label: style.label,
                      color: style.text,
                      bg: style.bg,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  position,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: StaffUi.textSecondary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Icon(
                      isInactive
                          ? Icons.schedule_rounded
                          : Icons.place_outlined,
                      size: 13,
                      color: StaffUi.muted,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        location.isEmpty ? 'Sin asignar' : location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: StaffUi.muted,
                          height: 1.2,
                        ),
                      ),
                    ),
                    if (workedToday) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: TColors.statusGreenBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_rounded,
                                size: 11, color: TColors.statusGreen),
                            SizedBox(width: 3),
                            Text(
                              'Hoy',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: TColors.statusGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: StaffUi.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_forward_ios_rounded,
                color: StaffUi.primary, size: 12),
          ),
        ],
      ),
    );
  }
}

/// Avatar con foto de red (si existe) o iniciales como respaldo, con un punto
/// de estado superpuesto.
class _Avatar extends StatelessWidget {
  final String image;
  final String initials;
  final Color dotColor;
  const _Avatar({
    required this.image,
    required this.initials,
    required this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: 54,
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: StaffUi.primarySoft,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: StaffUi.primary,
        ),
      ),
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (image.isEmpty)
          fallback
        else
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              image,
              width: 54,
              height: 54,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => fallback,
            ),
          ),
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _WorkerStatusStyle {
  final String label;
  final Color bg;
  final Color text;
  final Color dot;
  const _WorkerStatusStyle({
    required this.label,
    required this.bg,
    required this.text,
    required this.dot,
  });

  static _WorkerStatusStyle of(String status) {
    switch (status.toLowerCase()) {
      case 'activo':
        return const _WorkerStatusStyle(
          label: 'Activo',
          bg: TColors.statusActiveBg,
          text: TColors.success,
          dot: TColors.statusActiveDot,
        );
      case 'descanso':
        return const _WorkerStatusStyle(
          label: 'Descanso',
          bg: TColors.statusRestBg,
          text: TColors.statusOrange,
          dot: TColors.statusRestDot,
        );
      case 'inactivo':
        return const _WorkerStatusStyle(
          label: 'Inactivo',
          bg: TColors.statusInactiveBg,
          text: TColors.textSecondary,
          dot: TColors.statusInactiveDot,
        );
      default:
        return const _WorkerStatusStyle(
          label: 'Sin estado',
          bg: TColors.statusGreyBg,
          text: TColors.textSecondary,
          dot: TColors.statusInactiveDot,
        );
    }
  }
}
