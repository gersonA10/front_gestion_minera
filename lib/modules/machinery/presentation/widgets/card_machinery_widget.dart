import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/core/widgets/app_network_image.dart';
import 'package:front_gestion_minera/modules/machinery/domain/entity/entity.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

class CardMachineryWidget extends StatelessWidget {
  final MachineryEntity machine;
  const CardMachineryWidget({super.key, required this.machine});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.router.push(DetailMachineryRoute(machineId: machine.machineId));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: TColors.border),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AppNetworkImage(
                url: machine.photoUrl,
                width: 64,
                height: 64,
                errorIcon: Icons.precision_manufacturing_rounded,
                errorIconSize: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    machine.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: TColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    machine.description,
                    style: const TextStyle(
                      color: TColors.textSecondary,
                      fontSize: 12.5,
                      height: 1.25,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  _statusPill(machine.status.toLowerCase()),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: TColors.iconMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusPill(String tipo) {
    late final Color color;
    late final Color bg;
    late final String label;
    late final IconData icon;

    if (tipo == 'activo') {
      color = TColors.success;
      bg = TColors.successLight;
      label = 'ACTIVO';
      icon = Icons.check_circle_rounded;
    } else if (tipo == 'en mantenimiento') {
      color = TColors.warning;
      bg = TColors.warningLight;
      label = 'MANTENIMIENTO';
      icon = Icons.build_rounded;
    } else {
      color = TColors.danger;
      bg = TColors.dangerLight;
      label = 'INACTIVO';
      icon = Icons.cancel_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 9),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: color,
              fontSize: 10,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
