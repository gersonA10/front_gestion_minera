import 'package:flutter/material.dart';

class LoanSimulationScreen extends StatelessWidget {
  const LoanSimulationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'Simulación de Préstamo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _LoanSummaryCard(),
                  const SizedBox(height: 24),
                  const _PaymentScheduleHeader(),
                  const SizedBox(height: 12),
                  _PaymentInstallmentCard(
                    number: 1,
                    dueDate: '15 Mayo 2024',
                    amount: 933.33,
                    capital: 833.33,
                    interest: 100.00,
                    status: InstallmentStatus.pending,
                  ),
                  const SizedBox(height: 12),
                  _PaymentInstallmentCard(
                    number: 2,
                    dueDate: '15 Jun 2024',
                    amount: 933.33,
                    capital: 833.33,
                    interest: 100.00,
                    status: InstallmentStatus.future,
                  ),
                  const SizedBox(height: 12),
                  _PaymentInstallmentCard(
                    number: 3,
                    dueDate: '15 Jul 2024',
                    amount: 933.33,
                    capital: 833.33,
                    interest: 100.00,
                    status: InstallmentStatus.future,
                  ),
                  const SizedBox(height: 16),
                  const _TotalsCard(),
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

// ─────────────────────────────────────────────
// Loan Summary Card
// ─────────────────────────────────────────────

class _LoanSummaryCard extends StatelessWidget {
  const _LoanSummaryCard();

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
          const Text(
            '\$11,200.00',
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
                  value: '\$10,000.00',
                  valueColor: Colors.white,
                ),
              ),
              Expanded(
                child: _SummaryItem(
                  label: 'Interés Total',
                  value: '\$1,200.00',
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
                  value: '\$933.33',
                  valueColor: Colors.white,
                ),
              ),
              Expanded(
                child: _SummaryItem(
                  label: 'Nº Cuotas',
                  value: '12 Meses',
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

// ─────────────────────────────────────────────
// Payment Schedule Header
// ─────────────────────────────────────────────

class _PaymentScheduleHeader extends StatelessWidget {
  const _PaymentScheduleHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Cronograma de Pagos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: const Text(
            'Ver todo',
            style: TextStyle(
              color: Color(0xFF3B82F6),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Payment Installment Card
// ─────────────────────────────────────────────

enum InstallmentStatus { pending, future, paid }

class _PaymentInstallmentCard extends StatelessWidget {
  final int number;
  final String dueDate;
  final double amount;
  final double capital;
  final double interest;
  final InstallmentStatus status;

  const _PaymentInstallmentCard({
    required this.number,
    required this.dueDate,
    required this.amount,
    required this.capital,
    required this.interest,
    required this.status,
  });

  Color get _statusColor {
    switch (status) {
      case InstallmentStatus.pending:
        return const Color(0xFF2EA043);
      case InstallmentStatus.future:
        return Colors.grey;
      case InstallmentStatus.paid:
        return const Color(0xFF3B82F6);
    }
  }

  String get _statusLabel {
    switch (status) {
      case InstallmentStatus.pending:
        return 'Pendiente';
      case InstallmentStatus.future:
        return 'Futura';
      case InstallmentStatus.paid:
        return 'Pagada';
    }
  }

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
                      style: TextStyle(
                        color: Colors.grey[500],
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
                    '\$${amount.toStringAsFixed(2)}',
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
                          color: _statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _statusLabel,
                        style: TextStyle(
                          color: _statusColor,
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
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 11,
                ),
              ),
              Text(
                '\$${capital.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFF3B82F6),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 24),
              Text(
                'Interés: ',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 11,
                ),
              ),
              Text(
                '\$${interest.toStringAsFixed(2)}',
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

// ─────────────────────────────────────────────
// Totals Card
// ─────────────────────────────────────────────

class _TotalsCard extends StatelessWidget {
  const _TotalsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey[800]!,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          _TotalRow(
            label: 'Total Capital',
            value: '\$10,000.00',
            valueColor: Colors.white,
            isBold: false,
          ),
          const SizedBox(height: 12),
          _TotalRow(
            label: 'Total Interés',
            value: '\$1,200.00',
            valueColor: Colors.white,
            isBold: false,
          ),
          const SizedBox(height: 14),
          Divider(color: Colors.grey[800], height: 1),
          const SizedBox(height: 14),
          _TotalRow(
            label: 'Total General',
            value: '\$11,200.00',
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
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
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