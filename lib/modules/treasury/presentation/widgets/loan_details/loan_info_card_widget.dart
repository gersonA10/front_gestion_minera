import 'package:intl/intl.dart';
import '../../../domain/entity/entity.dart';
import '../../screens/loans/loan_ui.dart';
import '../widgtes.dart';

class LoanInfoCard extends StatelessWidget {
  final CabeceraEntity cabecera;
  const LoanInfoCard({super.key, required this.cabecera});

  String _money(num v) =>
      '${NumberFormat('#,##0.##', 'es_PE').format(v)} ${cabecera.moneda}';

  /// (color, fondo, ícono) según la etiqueta de estado del préstamo.
  (Color, Color, IconData) _statusStyle() {
    final l = cabecera.estadoEtiqueta.toLowerCase();
    if (l.contains('mora') || l.contains('atras')) {
      return (LoanUi.mora, LoanUi.moraBg, Icons.error_outline_rounded);
    }
    if (l.contains('final') || l.contains('pagad')) {
      return (
        LoanUi.finalizado,
        LoanUi.finalizadoBg,
        Icons.check_circle_outline_rounded
      );
    }
    return (LoanUi.activo, LoanUi.activoBg, Icons.autorenew_rounded);
  }

  @override
  Widget build(BuildContext context) {
    final progress = cabecera.progresoPagoPct / 100.0;
    final (sColor, sBg, sIcon) = _statusStyle();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: LoanUi.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LoanUi.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera con leve degradado azul.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [LoanUi.primarySoft, LoanUi.surface],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: LoanUi.primarySoft,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: LoanUi.primary.withValues(alpha: 0.15),
                        ),
                      ),
                      child: const Icon(
                        Icons.account_balance_rounded,
                        color: LoanUi.primary,
                        size: 22,
                      ),
                    ),
                    LoanPill(
                      label: cabecera.estadoEtiqueta,
                      color: sColor,
                      bg: sBg,
                      icon: sIcon,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Préstamo #${cabecera.loanCode}',
                  style: const TextStyle(
                    color: LoanUi.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      NumberFormat('#,##0.##', 'es_PE')
                          .format(cabecera.montoPrincipal),
                      style: const TextStyle(
                        color: LoanUi.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      cabecera.moneda,
                      style: const TextStyle(
                        color: LoanUi.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: InfoBox(
                    icon: Icons.percent_rounded,
                    label: 'INTERÉS\nTOTAL',
                    value: _money(cabecera.interesTotal),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InfoBox(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'TOTAL A\nPAGAR',
                    value: _money(cabecera.totalAPagar),
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
                color: LoanUi.bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: LoanUi.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SALDO PENDIENTE',
                        style: TextStyle(
                          color: LoanUi.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _money(cabecera.saldoPendiente),
                        style: const TextStyle(
                          color: LoanUi.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 46,
                    height: 46,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          strokeWidth: 4,
                          backgroundColor: LoanUi.fieldBg,
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(LoanUi.primary),
                        ),
                        Text(
                          '${cabecera.progresoPagoPct.toStringAsFixed(cabecera.progresoPagoPct % 1 == 0 ? 0 : 1)}%',
                          style: const TextStyle(
                            color: LoanUi.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
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
