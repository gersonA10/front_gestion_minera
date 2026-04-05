import 'package:front_gestion_minera/modules/treasury/presentation/widgets/widgtes.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

import '../../../../domain/entity/entity.dart';

class DistributionCard extends StatelessWidget {
  final DistributionHistoryItemEntity item;
  final String Function(double) formatCurrency;

  const DistributionCard(
      {super.key, required this.item, required this.formatCurrency});

  bool get _isAbierto => item.status.toLowerCase() == 'abierto';

  Color get _avatarBg =>
      _isAbierto ? TColors.warningLight : TColors.successLight;
  Color get _avatarText => _isAbierto ? TColors.warning : TColors.success;
  Color get _statusColor => _isAbierto ? TColors.warning : TColors.success;
  String get _statusLabel => _isAbierto ? 'Pendiente' : 'Pagado';

  String get _initials {
    final parts = item.period.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return item.period.substring(0, 2).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TColors.border),
        boxShadow: [
          BoxShadow(
            color: TColors.textPrimary.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: _avatarBg, shape: BoxShape.circle),
                child: Center(
                  child: Text(_initials,
                      style: TextStyle(
                          color: _avatarText,
                          fontSize: 13,
                          fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.period,
                        style: const TextStyle(
                            color: TColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                    Text('Registrado: ${item.registeredDate}',
                        style: const TextStyle(
                            color: TColors.textSecondary, fontSize: 11)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: TColors.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _statusColor),
                ),
                child: Text(_statusLabel,
                    style: TextStyle(
                        color: _statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Divider(height: 1, color: TColors.border),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('MONTO',
                      style: TextStyle(
                          color: TColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4)),
                  const SizedBox(height: 2),
                  Text(formatCurrency(item.registeredAmount),
                      style: const TextStyle(
                          color: TColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700)),
                ],
              ),

              if (_isAbierto)
                ElevatedButton(
                  onPressed: () {
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.primary,
                    foregroundColor: TColors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Pagar',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700)),
                )
              else
                GestureDetector(
                  onTap: () {
                  },
                  child: Row(
                    children: const [
                      Icon(Icons.receipt_long_outlined,
                          color: TColors.textSecondary, size: 15),
                      SizedBox(width: 4),
                      Text('Ver recibo',
                          style: TextStyle(
                              color: TColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}