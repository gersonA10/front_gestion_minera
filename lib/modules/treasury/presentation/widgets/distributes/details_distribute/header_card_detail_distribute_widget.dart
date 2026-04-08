
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

import '../../../../domain/entity/entity.dart';

class HeaderCard extends StatelessWidget {
  final DistributionDetailHeaderEntity header;
  final String Function(double) formatCurrency;

  const HeaderCard({super.key, required this.header, required this.formatCurrency});

  bool get _isAbierto => header.status.toLowerCase() == 'abierto';
  Color get _statusColor =>
      _isAbierto ? const Color(0xFF0EA5E9) : TColors.success;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _isAbierto
              ? [const Color(0xFF0C2340), const Color(0xFF1A4060)]
              : [const Color(0xFF1A2A1A), const Color(0xFF2D4A2D)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                header.period,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${header.totalMembers} socios',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: _statusColor.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                      color: _statusColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 5),
                Text(
                  header.status,
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
