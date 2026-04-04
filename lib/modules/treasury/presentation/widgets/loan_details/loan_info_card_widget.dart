import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import '../../../domain/entity/entity.dart';
import '../widgtes.dart';

class LoanInfoCard extends StatelessWidget {
  final CabeceraEntity cabecera;
  const LoanInfoCard({super.key, required this.cabecera});

  @override
  Widget build(BuildContext context) {
    final progress = cabecera.progresoPagoPct / 100.0;
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
                    Container(
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: TColors.green,
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            cabecera.estadoEtiqueta,
                            style: const TextStyle(
                              color: TColors.green,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Préstamo #${cabecera.loanCode}',
                  style: const TextStyle(
                    color: TColors.textSecondary1,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      cabecera.montoPrincipal.toString(),
                      style: const TextStyle(
                        color: TColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      cabecera.moneda,
                      style: const TextStyle(
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
              children: [
                Expanded(
                  child: InfoBox(
                    icon: Icons.percent,
                    label: 'INTERÉS\nTOTAL',
                    value: cabecera.interesTotal.toString(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InfoBox(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'TOTAL A\nPAGAR',
                    value: cabecera.totalAPagar.toString(),
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
                      Text(
                        cabecera.saldoPendiente.toString(),
                        style: const TextStyle(
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
                          value: progress,
                          strokeWidth: 4,
                          backgroundColor: TColors.inputBg,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            TColors.amber,
                          ),
                        ),
                        Text(
                          '${cabecera.progresoPagoPct}%',
                          style: const TextStyle(
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
