import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

import '../../../../domain/entity/entity.dart';

class SocioCard extends StatelessWidget {
  final ContributionDetailMemberEntity item;
  final CashResponseEntity cash;
  final bool isPendiente;
  final DateTime dateContibution;
  final String titleContibuton;
  const SocioCard({super.key, required this.item, required this.cash, required this.isPendiente, required this.dateContibution, required this.titleContibuton});
  @override
  Widget build(BuildContext context) {
    final Color montoColor = isPendiente
        ? TColors.pendingYellow
        : TColors.green;
    final IconData statusIcon = isPendiente
        ? Icons.schedule_outlined
        : Icons.check_circle_outline;

    final initials = item.fullName
        .trim()
        .split(' ')
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();

    return GestureDetector(
      onTap: () {
        isPendiente
                        ? context.router.push(RecordContributionPaymentRoute(dateContibution: dateContibution, titleContibuton: titleContibuton, item: item , cash: cash))
                        : context.router.push(PaymentConfirmationRoute(transactionId: item.detailId, screen: false));
       
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: TColors.lightContainerAccount,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: TColors.appSurfaceColor),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: TColors.shimmer,
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: TColors.appSecondaryColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.fullName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: TColors.appMainTextColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isPendiente
                        ? 'Deuda: ${item.amountToPay.toStringAsFixed(2)} Bs'
                        : 'Pagado: ${item.amountToPay.toStringAsFixed(2)} Bs',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: montoColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(statusIcon, size: 20, color: montoColor),
          ],
        ),
      ),
    );
  }
}
