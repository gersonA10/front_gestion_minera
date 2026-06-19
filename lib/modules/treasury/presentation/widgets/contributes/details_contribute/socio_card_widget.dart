import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entity/entity.dart';
import '../../../screens/contributes/contributes_ui.dart';

class SocioCard extends StatelessWidget {
  final ContributionDetailMemberEntity item;
  final CashResponseEntity cash;
  final bool isPendiente;
  final DateTime dateContibution;
  final String titleContibuton;
  const SocioCard({
    super.key,
    required this.item,
    required this.cash,
    required this.isPendiente,
    required this.dateContibution,
    required this.titleContibuton,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00', 'es_PE');
    final montoColor = isPendiente ? CUi.warning : CUi.success;
    final montoBg = isPendiente ? CUi.warningBg : CUi.successBg;

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
            ? context.router.push(
                RecordContributionPaymentRoute(
                  dateContibution: dateContibution,
                  titleContibuton: titleContibuton,
                  item: item,
                  cash: cash,
                ),
              )
            : context.router.push(
                PaymentConfirmationRoute(
                  transactionId: item.detailId,
                  screen: false,
                ),
              );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: CUi.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: CUi.border),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: CUi.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Text(
                initials.isEmpty ? '?' : initials,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: CUi.primary,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: CUi.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: montoBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${isPendiente ? 'Deuda' : 'Pagado'}: ${fmt.format(item.amountToPay)} Bs',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: montoColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isPendiente
                  ? Icons.chevron_right_rounded
                  : Icons.check_circle_rounded,
              size: isPendiente ? 24 : 20,
              color: isPendiente ? CUi.muted : CUi.success,
            ),
          ],
        ),
      ),
    );
  }
}
