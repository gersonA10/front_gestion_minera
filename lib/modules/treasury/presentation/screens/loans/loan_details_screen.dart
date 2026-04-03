import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/widgets/widgtes.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

@RoutePage()
class LoanDetailsScreen extends StatelessWidget {
  const LoanDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.bgColor,
      appBar: AppBar(
        backgroundColor: TColors.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: TColors.white, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'Detalle del Préstamo',
          style: TextStyle(
            color: TColors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _LoanInfoCard(),
            const SizedBox(height: 24),
            Text(
              'Cronograma de Pagos',
              style: TextStyle(
                color: TColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              itemCount: 3,
              itemBuilder: (context, index) {
                return _buildInstallment(
                  month: 'JUL',
                  day: '15',
                  number: 0,
                  label: '(Ejemplo)',
                  amount: 4200.00,
                  status: InstallmentStatus.overdue,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstallment({
    required String month,
    required String day,
    required int number,
    String? label,
    required double amount,
    required InstallmentStatus status,
  }) {
    return InstallmentCard(
      month: month,
      day: day,
      number: number,
      label: label,
      amount: amount,
      status: status,
    );
  }
}

class _LoanInfoCard extends StatelessWidget {
  const _LoanInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: TColors.cardBgDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TColors.cardBorderDark, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  TColors.amber.withValues(alpha: 0.15),
                  TColors.cardBgDark,
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: TColors.amberLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_balance,
                        color: TColors.amber,
                        size: 22,
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: TColors.green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: TColors.green.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              color: TColors.green,
                              size: 13,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Activo',
                              style: TextStyle(
                                color: TColors.green,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Préstamo #LN-2023-8492',
                  style: TextStyle(
                    color: TColors.textSecondary1,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '\$45,000.00',
                      style: TextStyle(
                        color: TColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'MXN',
                      style: TextStyle(
                        color: TColors.textSecondary1,
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: const [
                Expanded(
                  child: _InfoBox(
                    icon: Icons.percent,
                    label: 'INTERÉS\nTOTAL',
                    value: '\$5,400.00',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _InfoBox(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'TOTAL A\nPAGAR',
                    value: '\$50,400.00',
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: TColors.cardInnerBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: TColors.cardBorderDark.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SALDO PENDIENTE',
                        style: TextStyle(
                          color: TColors.amber.withValues(alpha: 0.7),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '\$32,150.00',
                        style: TextStyle(
                          color: TColors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: 0.36,
                          strokeWidth: 4,
                          backgroundColor: TColors.inputBg,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            TColors.amber,
                          ),
                        ),
                        const Text(
                          '36%',
                          style: TextStyle(
                            color: TColors.amber,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoBox({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TColors.cardInnerBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TColors.cardBorderDark.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: TColors.amber, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: TColors.amber.withValues(alpha: 0.7),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: TColors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Payment Schedule Header
// ─────────────────────────────────────────────

enum InstallmentStatus { overdue, paid, pending, scheduled }

class InstallmentCard extends StatelessWidget {
  final String month;
  final String day;
  final int number;
  final String? label;
  final double amount;
  final InstallmentStatus status;

  const InstallmentCard({
    super.key,
    required this.month,
    required this.day,
    required this.number,
    this.label,
    required this.amount,
    required this.status,
  });

  Color get _borderColor {
    switch (status) {
      case InstallmentStatus.overdue:
        return TColors.danger;
      case InstallmentStatus.paid:
        return TColors.green;
      case InstallmentStatus.pending:
        return TColors.pendingYellow;
      case InstallmentStatus.scheduled:
        return TColors.disabled;
    }
  }

  Color get _statusColor {
    switch (status) {
      case InstallmentStatus.overdue:
        return TColors.danger;
      case InstallmentStatus.paid:
        return TColors.green;
      case InstallmentStatus.pending:
        return TColors.pendingYellow;
      case InstallmentStatus.scheduled:
        return TColors.textSecondary1;
    }
  }

  String get _statusLabel {
    switch (status) {
      case InstallmentStatus.overdue:
        return 'Atrasado';
      case InstallmentStatus.paid:
        return 'Pagado';
      case InstallmentStatus.pending:
        return 'Pendiente';
      case InstallmentStatus.scheduled:
        return 'Programado';
    }
  }

  IconData get _statusIcon {
    switch (status) {
      case InstallmentStatus.overdue:
        return Icons.warning_amber_rounded;
      case InstallmentStatus.paid:
        return Icons.check_circle_outline;
      case InstallmentStatus.pending:
        return Icons.access_time;
      case InstallmentStatus.scheduled:
        return Icons.calendar_today_outlined;
    }
  }

  String? get _actionLabel {
    switch (status) {
      case InstallmentStatus.overdue:
        return 'Pagar Ahora';
      case InstallmentStatus.paid:
        return 'vía Nómina';
      case InstallmentStatus.pending:
        return null;
      case InstallmentStatus.scheduled:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isPending = status == InstallmentStatus.pending;

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
                    color: _borderColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  if (isPending)
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
                      isPending ? 6 : 14,
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
                                  color: _statusColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                day,
                                style: TextStyle(
                                  color: _statusColor,
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
                                'Cuota #$number${label != null ? ' $label' : ''}',
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
                                    _statusIcon,
                                    color: _statusColor,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
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
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: status == InstallmentStatus.overdue
                                    ? TColors.danger
                                    : TColors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (_actionLabel != null) ...[
                              const SizedBox(height: 3),
                              Text(
                                _actionLabel!,
                                style: TextStyle(
                                  color: status == InstallmentStatus.overdue
                                      ? TColors.danger
                                      : TColors.textSecondary1,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  decoration:
                                      status == InstallmentStatus.overdue
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
                  // Botón pago anticipado para pendiente
                  if (isPending)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                      child: SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: OutlinedButton.icon(
                          onPressed: () {},
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
