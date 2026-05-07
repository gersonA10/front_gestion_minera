import 'package:flutter/material.dart';

import '../../../../utils/constants/color.constant.dart';

class StatusBadgeWidget extends StatelessWidget {
  final String statusId;

  const StatusBadgeWidget({super.key, required this.statusId});

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(statusId);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: const BoxConstraints(maxWidth: 110),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Icon(Icons.circle, size: 8, color: config.color),
            ),
            const TextSpan(text: " "),
            TextSpan(
              text: config.label,
              style: TextStyle(
                fontSize: 13,
                color: config.color,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Lógica de mapeo separada de la UI
  _StatusData _getStatusConfig(String id) {
    switch (id) {
      case '1':
        return _StatusData(label: 'En Revision', color: TColors.appMainColor);
      case '2':
        return _StatusData(label: 'Completada', color: TColors.green);
      case '3':
        return _StatusData(label: 'Pendiente de Recibo', color: TColors.amber);
      default:
        return _StatusData(label: 'Rechazada', color: TColors.red);
    }
  }
}

class _StatusData {
  final String label;
  final Color color;
  _StatusData({required this.label, required this.color});
}
