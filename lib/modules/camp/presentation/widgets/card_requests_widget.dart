import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:intl/intl.dart';

import '../../../../utils/constants/color.constant.dart';
import '../../domain/entity/entity.dart';

class CardRequestsWidget extends StatelessWidget {
  final CampRecentRequestEntity request;

  const CardRequestsWidget({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
         context.router.push(RequestProgressDetailsRoute(requestId: request.requestId));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(request.description, style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 5),
                  Text(
                    '${request.displayCode} · ${DateFormat('dd/MM/yyyy').format(request.createdAt)}',
                    style: TextStyle(fontSize: 13, color: TColors.appDisabledColor),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _StatusBadge(globalStatus: request.globalStatus, label: request.statusLabel),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String globalStatus;
  final String label;

  const _StatusBadge({required this.globalStatus, required this.label});

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(globalStatus);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: const BoxConstraints(maxWidth: 110),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _colorFor(String status) {
    switch (status) {
      case 'IN_REVIEW':
        return TColors.appMainColor;
      case 'APPROVED':
        return TColors.amber;
      case 'PAID':
        return TColors.green;
      case 'REJECTED':
        return TColors.danger;
      default:
        return TColors.danger;
    }
  }
}
