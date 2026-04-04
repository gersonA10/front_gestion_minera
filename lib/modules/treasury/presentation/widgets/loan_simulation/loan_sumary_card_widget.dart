import 'package:flutter/material.dart';
import '../../../domain/entity/entity.dart';

class LoanSummaryCard extends StatelessWidget {
  final NewLoansResponseEntity loan;
  const LoanSummaryCard({super.key, required this.loan});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'TOTAL A PAGAR',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            loan.summary.totalPayable.toString(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2332),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF2EA043).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.show_chart,
                  color: const Color(0xFF2EA043),
                  size: 16,
                ),
                const SizedBox(width: 4),
                const Text(
                  '12% Anual',
                  style: TextStyle(
                    color: Color(0xFF2EA043),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.grey[800], height: 1),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SummaryItem(
                  label: 'Capital Solicitado',
                  value: '${loan.summary.amount}',
                  valueColor: Colors.white,
                ),
              ),
              Expanded(
                child: SummaryItem(
                  label: 'Interés Total',
                  value: '${loan.summary.totalInterest}',
                  valueColor: const Color(0xFF2EA043),
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
                  value: '${loan.summary.monthlyInstallment}',
                  valueColor: Colors.white,
                ),
              ),
              Expanded(
                child: SummaryItem(
                  label: 'Nº Cuotas',
                  value: '${loan.summary.termMonths} Meses',
                  valueColor: Colors.white,
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
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 10,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}