import 'package:flutter/material.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/staff_ui.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

class PayrollEmployeeCardWidget extends StatelessWidget {
  final String name;
  final String position;
  final String employeeId;

  /// Monto ya formateado (incluye símbolo y separadores).
  final String amount;
  final bool paid;
  final VoidCallback? onTap;

  const PayrollEmployeeCardWidget({
    super.key,
    required this.name,
    required this.position,
    required this.employeeId,
    required this.amount,
    required this.paid,
    this.onTap,
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
    final pillColor = paid ? TColors.statusGreen : TColors.statusOrange;
    final pillBg = paid ? TColors.statusGreenBg : TColors.statusOrangeBg;

    return StaffCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: StaffUi.primarySoft,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Text(
              _initials,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: StaffUi.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: StaffUi.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$position · #$employeeId',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: StaffUi.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  color: StaffUi.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              StaffPill(
                label: paid ? 'Pagado' : 'Pendiente',
                color: pillColor,
                bg: pillBg,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
