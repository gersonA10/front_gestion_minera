import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import '../../../domain/entity/entity.dart';

class InstallmentCard extends StatelessWidget {
  final String month;
  final String day;
  final int number;
  final String? label;
  final double amount;
  final String status;
  final String quotaId;
  final String idLoan;
  final CashResponseEntity cash;
final VoidCallback? onTap;
  const InstallmentCard({
    super.key,
    required this.month,
    required this.day,
    required this.number,
    this.label,
    required this.amount,
    required this.status,
    required this.quotaId,
    required this.cash,
    required this.idLoan,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: TColors.cardBgDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: TColors.cardBorderDark.withValues(alpha: 0.3),
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 3,
                  decoration: BoxDecoration(
                    color: status == 'Atrasado'
                        ? TColors.danger
                        : status == 'Pagado'
                        ? TColors.green
                        : status == 'Pendiente'
                        ? TColors.pendingYellow
                        : TColors.disabled,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  if (status == 'Pendiente')
                    Container(
                      width: double.infinity,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 12, top: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: TColors.amber,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'PRÓXIMO PAGO',
                          style: TextStyle(
                            color: TColors.bgColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      status == 'Pendiente' ? 6 : 14,
                      14,
                      14,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 44,
                          child: Column(
                            children: [
                              Text(
                                month,
                                style: TextStyle(
                                  color: status == 'Atrasado'
                                      ? TColors.danger
                                      : TColors.textSecondary1,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                day,
                                style: TextStyle(
                                  color: status == 'Atrasado'
                                      ? TColors.danger
                                      : TColors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cuota #$number',
                                style: const TextStyle(
                                  color: TColors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Icon(
                                    status == 'Atrasado'
                                        ? Icons.warning_amber_rounded
                                        : status == 'Pagado'
                                        ? Icons.check_circle_outline
                                        : status == 'Pendiente'
                                        ? Icons.access_time
                                        : Icons.calendar_today_outlined,
                                    color: status == 'Atrasado'
                                        ? TColors.danger
                                        : status == 'Pagado'
                                        ? TColors.green
                                        : status == 'Pendiente'
                                        ? TColors.pendingYellow
                                        : TColors.textSecondary1,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    status == 'Atrasado'
                                        ? 'Atrasado'
                                        : status == 'Pagado'
                                        ? 'Pagado'
                                        : status == 'Pendiente'
                                        ? 'Pendiente'
                                        : 'Programado',
                                    style: TextStyle(
                                      color: status == 'Atrasado'
                                          ? TColors.danger
                                          : status == 'Pagado'
                                          ? TColors.green
                                          : status == 'Pendiente'
                                          ? TColors.pendingYellow
                                          : TColors.textSecondary1,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              amount.toStringAsFixed(2),
                              style: TextStyle(
                                color: status == 'Atrasado'
                                    ? TColors.danger
                                    : TColors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (status == 'Atrasado') ...[
                              const SizedBox(height: 3),
                              Text(
                                'Registrar Pago',
                                style: TextStyle(
                                  color: status == 'Atrasado'
                                      ? TColors.danger
                                      : TColors.textSecondary1,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  decoration: status == 'Atrasado'
                                      ? TextDecoration.underline
                                      : TextDecoration.none,
                                  decorationColor: TColors.danger,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (status == 'Pendiente')
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                      child: SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: OutlinedButton.icon(
                          onPressed: onTap,
                          icon: const Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 15,
                          ),
                          label: const Text(
                            'Registrar Pago Anticipado',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: TColors.amber,
                            side: BorderSide(
                              color: TColors.amber.withValues(alpha: 0.4),
                            ),
                            backgroundColor: TColors.amberLight,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
