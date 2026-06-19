import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/entity/entity.dart';
import '../../screens/loans/loan_ui.dart';

class LoanSummaryCard extends StatelessWidget {
  final NewLoansResponseEntity loan;
  final double? rate;
  const LoanSummaryCard({super.key, required this.loan, this.rate});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.##', 'es_PE');
    final s = loan.summary;
    final rateLabel = rate != null ? '${fmt.format(rate)}% Anual' : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: LoanUi.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LoanUi.border),
      ),
      child: Column(
        children: [
          const Text(
            'TOTAL A PAGAR',
            style: TextStyle(
              color: LoanUi.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            fmt.format(s.totalPayable),
            style: const TextStyle(
              color: LoanUi.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          if (rateLabel != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: LoanUi.primarySoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.show_chart_rounded,
                      color: LoanUi.primary, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    rateLabel,
                    style: const TextStyle(
                      color: LoanUi.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          const Divider(color: LoanUi.border, height: 1),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SummaryItem(
                  label: 'Capital Solicitado',
                  value: fmt.format(s.amount),
                  valueColor: LoanUi.textPrimary,
                ),
              ),
              Expanded(
                child: SummaryItem(
                  label: 'Interés Total',
                  value: fmt.format(s.totalInterest),
                  valueColor: LoanUi.finalizado,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SummaryItem(
                  label: 'Cuota Mensual',
                  value: fmt.format(s.monthlyInstallment),
                  valueColor: LoanUi.textPrimary,
                ),
              ),
              Expanded(
                child: SummaryItem(
                  label: 'Nº Cuotas',
                  value: '${s.termMonths} Meses',
                  valueColor: LoanUi.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const SummaryItem({
    super.key,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: LoanUi.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: valueColor,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
