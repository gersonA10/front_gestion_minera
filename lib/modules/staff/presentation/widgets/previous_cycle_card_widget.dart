import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

class PreviousCycleCardWidget extends StatelessWidget {
  final String period;
  final String payrollType;
  final double totalAmount;
  final String paymentDate;
  final String status;
  final VoidCallback? onTap;

  const PreviousCycleCardWidget({
    super.key,
    required this.period,
    required this.payrollType,
    required this.totalAmount,
    required this.paymentDate,
    required this.status,
    this.onTap,
  });

  bool get isPaid => status.toUpperCase() == 'PAGADO';
  String get displayStatus => isPaid ? 'COMPLETADO' : 'PENDIENTE';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: TColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 18,
                  color: TColors.appMainColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      period,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: TColors.appMainDarkColor,
                      ),
                    ),
                    Text(
                      payrollType,
                      style: const TextStyle(
                        fontSize: 12,
                        color: TColors.appDisabledColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isPaid ? TColors.successLight : TColors.warningLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  displayStatus,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isPaid ? TColors.success : TColors.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MONTO TOTAL',
                      style: TextStyle(
                        fontSize: 10,
                        color: TColors.appDisabledColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: TColors.appMainDarkColor,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'FECHA DE PAGO',
                    style: TextStyle(
                      fontSize: 10,
                      color: TColors.appDisabledColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    paymentDate,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: TColors.appMainDarkColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: TColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Ver Detalle',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: TColors.appMainColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
