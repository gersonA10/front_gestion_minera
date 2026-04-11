import 'package:auto_route/auto_route.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/widgets/widgtes.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

import '../../../../domain/entity/entity.dart';

class DistribucionCardHome extends StatelessWidget {
  final DistributionHistoryItemEntity item;
  final String Function(double) formatCurrency;

  const DistribucionCardHome({
    super.key,
    required this.item,
    required this.formatCurrency,
  });

  bool get _isAbierto => item.status.toLowerCase() == 'abierto';
  bool get _isCerrado => item.status.toLowerCase() == 'cerrado';
  bool get _tieneEstado => item.status.isNotEmpty;

  Color get _estadoColor =>
      _isAbierto ? const Color(0xFF0EA5E9) : TColors.success;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: TColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TColors.border),
        boxShadow: [
          BoxShadow(
            color: TColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                Container(
                  height: 110,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _isCerrado
                          ? [const Color(0xFF1A2A1A), const Color(0xFF2D4A2D)]
                          : _isAbierto
                          ? [const Color(0xFF0C2340), const Color(0xFF1A4060)]
                          : [const Color(0xFF0D2137), const Color(0xFF1A3A55)],
                    ),
                  ),
                  child: CustomPaint(
                    painter: GeometricPainter(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Registro: ${item.registeredDate}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.period,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_tieneEstado)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _estadoColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _estadoColor.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _estadoColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            item.status,
                            style: TextStyle(
                              color: _estadoColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DataColumn(
                      label: 'Monto Registrado',
                      value: formatCurrency(item.registeredAmount),
                      labelColor: TColors.primary,
                      valueColor: TColors.textPrimary,
                    ),
                    DataColumn(
                      label: 'Pendiente',
                      value: formatCurrency(item.amountDue),
                      labelColor: TColors.primary,
                      valueColor: item.amountDue > 0
                          ? TColors.primary
                          : TColors.textPrimary,
                      alignRight: true,
                    ),
                  ],
                ),

                if (item.progressPct > 0 && item.progressPct < 100) ...[
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: item.progressPct / 100,
                      minHeight: 5,
                      backgroundColor: TColors.border,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF0EA5E9),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    DataColumn(
                      label: 'Pagado',
                      value: formatCurrency(item.amountPaid),
                      labelColor: TColors.textSecondary,
                      valueColor: TColors.textPrimary,
                      alignRight: true,
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Divider(height: 1, color: TColors.border),

                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      context.router.push(
                        DividendDistributionDetailsRoute(
                          distributionId: item.distributionId,
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: _isAbierto
                          ? TColors.primary
                          : TColors.textSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Ver detalle',
                          style: TextStyle(
                            color: _isAbierto
                                ? TColors.primary
                                : TColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Icon(
                          Icons.arrow_forward,
                          size: 15,
                          color: _isAbierto
                              ? TColors.primary
                              : TColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DataColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color labelColor;
  final Color valueColor;
  final bool alignRight;

  const DataColumn({
    super.key,
    required this.label,
    required this.value,
    required this.labelColor,
    required this.valueColor,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class GeometricPainter extends CustomPainter {
  final Color color;
  const GeometricPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path1 = Path()
      ..moveTo(size.width * 0.55, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width * 0.4, size.height)
      ..close();
    canvas.drawPath(path1, paint);

    final paint2 = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final path2 = Path()
      ..moveTo(size.width * 0.7, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.6)
      ..close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(GeometricPainter old) => false;
}
