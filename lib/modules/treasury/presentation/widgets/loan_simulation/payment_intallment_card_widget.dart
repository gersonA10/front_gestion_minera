import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../screens/loans/loan_ui.dart';

class PaymentInstallmentCard extends StatelessWidget {
  final int number;
  final String dueDate;
  final double amount;
  final double capital;
  final double interest;
  final String status;

  const PaymentInstallmentCard({
    super.key,
    required this.number,
    required this.dueDate,
    required this.amount,
    required this.capital,
    required this.interest,
    required this.status,
  });

  Color get _statusColor {
    switch (status) {
      case 'Pendiente':
        return LoanUi.pendiente;
      case 'Futura':
        return LoanUi.muted;
      default:
        return LoanUi.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00', 'es_PE');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LoanUi.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: LoanUi.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: LoanUi.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calendar_today_outlined,
                  color: LoanUi.primary,
                  size: 20,
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
                        color: LoanUi.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Vence: $dueDate',
                      style: const TextStyle(
                        color: LoanUi.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    fmt.format(amount),
                    style: const TextStyle(
                      color: LoanUi.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        status,
                        style: TextStyle(
                          color: _statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: LoanUi.border, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'Capital: ',
                style: TextStyle(color: LoanUi.textSecondary, fontSize: 11),
              ),
              Text(
                fmt.format(capital),
                style: const TextStyle(
                  color: LoanUi.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 24),
              const Text(
                'Interés: ',
                style: TextStyle(color: LoanUi.textSecondary, fontSize: 11),
              ),
              Text(
                fmt.format(interest),
                style: const TextStyle(
                  color: LoanUi.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
