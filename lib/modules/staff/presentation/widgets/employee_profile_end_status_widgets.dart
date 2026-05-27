
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

class CardWidget extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const CardWidget({super.key, required this.child, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: backgroundColor ?? TColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: TColors.profileBlue.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

enum WorkerStatusWidget { activo, descanso, inactivo }

extension WorkerStatusExt on WorkerStatusWidget {
  String get label {
    switch (this) {
      case WorkerStatusWidget.activo:
        return 'Activo';
      case WorkerStatusWidget.descanso:
        return 'Descanso';
      case WorkerStatusWidget.inactivo:
        return 'Inactivo';
    }
  }

  Color get dotColor {
    switch (this) {
      case WorkerStatusWidget.activo:
        return TColors.statusActiveDot;
      case WorkerStatusWidget.descanso:
        return TColors.statusRestDot;
      case WorkerStatusWidget.inactivo:
        return TColors.statusInactiveDot;
    }
  }

  Color get selectedBg {
    switch (this) {
      case WorkerStatusWidget.activo:
        return TColors.statusActiveBg;
      case WorkerStatusWidget.descanso:
        return TColors.statusRestBg;
      case WorkerStatusWidget.inactivo:
        return TColors.statusInactiveBg;
    }
  }
}


class StatusChip extends StatelessWidget {
  final WorkerStatusWidget status;
  final bool isSelected;

  const StatusChip({super.key, required this.status, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: isSelected ? status.selectedBg : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected
              ? status.dotColor.withValues(alpha: 0.3)
              : Colors.transparent,
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: status.dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? TColors.profileDarkText
                  : TColors.profileMutedLabel,
            ),
          ),
        ],
      ),
    );
  }
}
