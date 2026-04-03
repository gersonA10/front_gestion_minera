import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/date_util.dart';

import '../../../domain/entity/entity.dart';

@RoutePage()
class LoanSimulationScreen extends StatelessWidget {
  final NewLoansResponseEntity loan;
  final String name;
  const LoanSimulationScreen({
    super.key,
    required this.loan,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Simulación de Préstamo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LoanSummaryCard(loan: loan),
                  const SizedBox(height: 24),
                  const Text(
                    'Cronograma de Pagos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: loan.cronograma.length,
                    itemBuilder: (context, index) {
                      final installment = loan.cronograma[index];
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.0),
                        child: PaymentInstallmentCard(
                          number: installment.installmentNumber,
                          dueDate: formatDate(installment.dueDate),
                          amount: installment.totalInstallment,
                          capital: installment.principal,
                          interest: installment.interest,
                          status: installment.status,
                        ),
                      );
                    },
                  ),
                  TotalsCard(loan: loan),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          const _ConfirmButton(),
        ],
      ),
    );
  }
}

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
                color: const Color(0xFF2EA043).withOpacity(0.3),
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
                child: _SummaryItem(
                  label: 'Capital Solicitado',
                  value: '${loan.summary.amount}',
                  valueColor: Colors.white,
                ),
              ),
              Expanded(
                child: _SummaryItem(
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
                child: _SummaryItem(
                  label: 'Cuota Mensual',
                  value: '${loan.summary.monthlyInstallment}',
                  valueColor: Colors.white,
                ),
              ),
              Expanded(
                child: _SummaryItem(
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

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _SummaryItem({
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2530),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.grey[400],
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
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Vence: $dueDate',
                      style: TextStyle(color: Colors.grey[500], fontSize: 11),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount.toStringAsFixed(2),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
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
                          color: status == 'Pendiente'
                              ? const Color(0xFF2EA043)
                              : status == 'Futura'
                              ? Colors.grey
                              : const Color(0xFF3B82F6),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        status,
                        style: TextStyle(
                          color: status == 'Pendiente'
                              ? const Color(0xFF2EA043)
                              : status == 'Futura'
                              ? Colors.grey
                              : const Color(0xFF3B82F6),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: Colors.grey[800], height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Capital: ',
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
              Text(
                capital.toStringAsFixed(2),
                style: const TextStyle(
                  color: Color(0xFF3B82F6),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 24),
              Text(
                'Interés: ',
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
              Text(
                interest.toStringAsFixed(2),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TotalsCard extends StatelessWidget {
  final NewLoansResponseEntity loan;
  const TotalsCard({super.key, required this.loan});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[800]!, width: 0.5),
      ),
      child: Column(
        children: [
          _TotalRow(
            label: 'Total Capital',
            value: '${loan.summary.amount}',
            valueColor: Colors.white,
            isBold: false,
          ),
          const SizedBox(height: 12),
          _TotalRow(
            label: 'Total Interés',
            value: '${loan.summary.totalInterest}',
            valueColor: Colors.white,
            isBold: false,
          ),
          const SizedBox(height: 14),
          Divider(color: Colors.grey[800], height: 1),
          const SizedBox(height: 14),
          _TotalRow(
            label: 'Total General',
            value: '${loan.summary.totalPayable}',
            valueColor: const Color(0xFF2EA043),
            isBold: true,
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final bool isBold;

  const _TotalRow({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.isBold,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold ? Colors.white : Colors.grey[400],
            fontSize: isBold ? 13 : 12,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: isBold ? 14 : 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Confirm Button
// ─────────────────────────────────────────────

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      color: const Color(0xFF0D1117),
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.check, size: 20),
        label: const Text(
          'Confirmar',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
