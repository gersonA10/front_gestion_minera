import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/entity/entity.dart';
import '../../screens/loans/loan_ui.dart';

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

  bool get _atrasado => status == 'Atrasado';
  bool get _pagado => status == 'Pagado';
  bool get _pendiente => status == 'Pendiente';

  Color get _accent {
    if (_atrasado) return LoanUi.mora;
    if (_pagado) return LoanUi.finalizado;
    if (_pendiente) return LoanUi.pendiente;
    return LoanUi.muted;
  }

  IconData get _icon {
    if (_atrasado) return Icons.warning_amber_rounded;
    if (_pagado) return Icons.check_circle_outline_rounded;
    if (_pendiente) return Icons.access_time_rounded;
    return Icons.calendar_today_outlined;
  }

  String get _statusText {
    if (_atrasado) return 'Atrasado';
    if (_pagado) return 'Pagado';
    if (_pendiente) return 'Pendiente';
    return 'Programado';
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00', 'es_PE');
    final showPayButton = _pendiente || _atrasado;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: LoanUi.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: LoanUi.border),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4, color: _accent),
                Expanded(
                  child: Column(
                    children: [
                      if (_pendiente)
                        Container(
                          width: double.infinity,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 12, top: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: LoanUi.pendienteBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'PRÓXIMO PAGO',
                              style: TextStyle(
                                color: LoanUi.pendiente,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          14,
                          _pendiente ? 6 : 14,
                          14,
                          showPayButton ? 6 : 14,
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
                                      color: _atrasado
                                          ? LoanUi.mora
                                          : LoanUi.textSecondary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    day,
                                    style: TextStyle(
                                      color: _atrasado
                                          ? LoanUi.mora
                                          : LoanUi.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
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
                                      color: LoanUi.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Icon(_icon, color: _accent, size: 13),
                                      const SizedBox(width: 4),
                                      Text(
                                        _statusText,
                                        style: TextStyle(
                                          color: _accent,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              fmt.format(amount),
                              style: TextStyle(
                                color: _atrasado
                                    ? LoanUi.mora
                                    : LoanUi.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (showPayButton)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                          child: SizedBox(
                            width: double.infinity,
                            height: 42,
                            child: ElevatedButton.icon(
                              onPressed: onTap,
                              icon: const Icon(
                                Icons.account_balance_wallet_outlined,
                                size: 16,
                              ),
                              label: Text(
                                _atrasado
                                    ? 'Registrar pago'
                                    : 'Registrar pago anticipado',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    _atrasado ? LoanUi.mora : LoanUi.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
