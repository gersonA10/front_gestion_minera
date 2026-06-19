import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/modules/treasury/domain/entity/financial_report_entity.dart';
import 'package:front_gestion_minera/utils/text_util.dart';
import 'package:intl/intl.dart';

/// Donut interactivo de la distribución de gastos por responsable.
class ExpenseDonutWidget extends StatefulWidget {
  const ExpenseDonutWidget(this.colors, this.expenses, {super.key});

  final ColorScheme colors;
  final List<ExpenseByResponsibleEntity> expenses;

  @override
  State<ExpenseDonutWidget> createState() => _ExpenseDonutWidgetState();
}

class _ExpenseDonutWidgetState extends State<ExpenseDonutWidget> {
  int _touched = -1;

  static const _palette = <Color>[
    Color(0xFF1D54F3),
    Color(0xFFF97316),
    Color(0xFF10B981),
    Color(0xFF8B5CF6),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF14B8A6),
    Color(0xFFEC4899),
  ];

  Color _colorFor(int i) => _palette[i % _palette.length];

  String _money(double v) =>
      '${NumberFormat.currency(symbol: '', decimalDigits: 2).format(v)} Bs';

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final expenses = widget.expenses;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.lead.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DISTRIBUCIÓN DE GASTOS',
                    style: AppTextStyles.mainStyleGrey10(context).copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Toca una porción para ver el detalle',
                    style: AppTextStyles.mainStyle10(context).copyWith(
                      color: colors.lead.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (expenses.isEmpty)
            SizedBox(
              height: 120,
              child: Center(
                child: Text(
                  'No hay gastos registrados',
                  style: TextStyle(color: colors.lead),
                ),
              ),
            )
          else ...[
            _buildDonut(context, colors, expenses),
            const SizedBox(height: 20),
            ..._buildLegend(context, colors, expenses),
          ],
        ],
      ),
    );
  }

  Widget _buildDonut(
    BuildContext context,
    ColorScheme colors,
    List<ExpenseByResponsibleEntity> expenses,
  ) {
    final total = expenses.fold<double>(0, (s, e) => s + e.monto);
    final showTouched = _touched >= 0 && _touched < expenses.length;
    final centerTitle =
        showTouched ? expenses[_touched].area.toUpperCase() : 'TOTAL EGRESOS';
    final centerValue =
        showTouched ? _money(expenses[_touched].monto) : _money(total);
    final centerColor = showTouched ? _colorFor(_touched) : colors.black;

    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 60,
              startDegreeOffset: -90,
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        response == null ||
                        response.touchedSection == null) {
                      _touched = -1;
                      return;
                    }
                    _touched =
                        response.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              sections: List.generate(expenses.length, (i) {
                final isT = i == _touched;
                final e = expenses[i];
                final v = e.monto <= 0 ? 0.0001 : e.monto;
                return PieChartSectionData(
                  value: v,
                  color: _colorFor(i),
                  radius: isT ? 36 : 28,
                  showTitle: isT,
                  title: '${e.porcentajeDelTotal.toStringAsFixed(0)}%',
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  titlePositionPercentageOffset: 0.55,
                );
              }),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  centerTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.mainStyleGrey10(context).copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 110,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    centerValue,
                    style: AppTextStyles.mainStyle16Bold(context)
                        .copyWith(color: centerColor),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLegend(
    BuildContext context,
    ColorScheme colors,
    List<ExpenseByResponsibleEntity> expenses,
  ) {
    return List.generate(expenses.length, (i) {
      final e = expenses[i];
      final isLast = i == expenses.length - 1;
      return Padding(
        padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: _colorFor(i),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                e.area,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.mainStyle12(context).copyWith(
                  color: colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _money(e.monto),
              style: AppTextStyles.mainStyle12(context).copyWith(
                color: colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: _colorFor(i).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${e.porcentajeDelTotal.toStringAsFixed(0)}%',
                style: TextStyle(
                  color: _colorFor(i),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
