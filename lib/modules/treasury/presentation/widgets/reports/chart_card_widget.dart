import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:front_gestion_minera/utils/text_util.dart';
import '../../../domain/entity/entity.dart';

class ChartCardWidget extends StatefulWidget {
  const ChartCardWidget(this.colors, this.datosGrafica, {super.key});

  final ColorScheme colors;
  final List<ChartDataEntity> datosGrafica;

  @override
  State<ChartCardWidget> createState() => _ChartCardWidgetState();
}

class _ChartCardWidgetState extends State<ChartCardWidget> {
  int? _touchedIndex;

  static const _blueColor = Color(0xFF2563EB);
  static const _orangeColor = Color(0xFFF97316);

  static const double _leftReserved = 56;
  static const double _bottomReserved = 28;

  String _formatY(double v) {
    final abs = v.abs();
    String formatted;
    if (abs >= 1000000) {
      formatted = '${(v / 1000000).toStringAsFixed(1)}M';
    } else if (abs >= 1000) {
      formatted = '${(v / 1000).toStringAsFixed(0)}k';
    } else {
      formatted = v.toStringAsFixed(0);
    }
    return 'Bs.$formatted';
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.datosGrafica;
    final colors = widget.colors;

    double maxVal = 1;
    double minVal = 0;
    for (final d in data) {
      if (d.ingresos > maxVal) maxVal = d.ingresos;
      if (d.egresos > maxVal) maxVal = d.egresos;
      if (d.margen < minVal) minVal = d.margen;
    }
    final maxY = maxVal * 1.28;
    final minY = minVal < 0 ? minVal * 1.25 : -(maxY * 0.04);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 20, 16),
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.lead.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, colors),
          const SizedBox(height: 20),
          data.isEmpty
              ? _buildEmpty()
              : _buildChart(data, colors, maxY, minY),
          const SizedBox(height: 14),
          _buildLegend(context, colors),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colors) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: _blueColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FLUJO FINANCIERO',
              style: AppTextStyles.mainStyleGrey10(context).copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              'Ingresos · Egresos',
              style: AppTextStyles.mainStyle10(context).copyWith(
                color: widget.colors.lead.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return const SizedBox(
      height: 200,
      child: Center(
        child: Text(
          'Sin datos para este período',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildChart(
    List<ChartDataEntity> data,
    ColorScheme colors,
    double maxY,
    double minY,
  ) {
    final n = data.length;

    return SizedBox(
      height: 220,
      child: Stack(
        children: [
          BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              minY: minY,
              maxY: maxY,
              barTouchData: BarTouchData(
                enabled: true,
                touchCallback: (FlTouchEvent event, BarTouchResponse? response) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        response == null ||
                        response.spot == null) {
                      _touchedIndex = null;
                    } else {
                      _touchedIndex = response.spot!.touchedBarGroupIndex;
                    }
                  });
                },
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => const Color(0xFF1E293B),
                  tooltipPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final d = data[groupIndex];
                    final isIngreso = rodIndex == 0;
                    return BarTooltipItem(
                      '${isIngreso ? 'Ingresos' : 'Egresos'}\n',
                      TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        TextSpan(
                          text: _formatY(isIngreso ? d.ingresos : d.egresos),
                          style: TextStyle(
                            color: isIngreso ? _blueColor : _orangeColor,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: _leftReserved,
                    interval: (maxY - minY) / 4,
                    getTitlesWidget: (value, meta) {
                      if (value == meta.max || value == meta.min) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Text(
                          _formatY(value),
                          style: TextStyle(
                            color: colors.lead.withValues(alpha: 0.55),
                            fontSize: 8.5,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: _bottomReserved,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i < 0 || i >= n) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          data[i].etiqueta,
                          style: TextStyle(
                            color: colors.lead.withValues(alpha: 0.65),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: (maxY - minY) / 4,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: colors.lead.withValues(alpha: 0.07),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(n, (i) {
                final d = data[i];
                final touched = _touchedIndex == i;
                return BarChartGroupData(
                  x: i,
                  barsSpace: 4,
                  barRods: [
                    BarChartRodData(
                      toY: d.ingresos,
                      color: TColors.appMainColor.withValues(alpha: touched ? 1.0 : 0.82),
                      width: touched ? 18 : 13,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                    BarChartRodData(
                      toY: d.egresos,
                      color: _orangeColor.withValues(alpha: touched ? 1.0 : 0.82),
                      width: touched ? 18 : 13,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),

          // ── Line overlay (margen neto) ──
          IgnorePointer(
            child: Padding(
              padding: const EdgeInsets.only(bottom: _bottomReserved),
              child: LineChart(
                LineChartData(
                  minX: -0.5,
                  maxX: n - 0.5,
                  minY: minY,
                  maxY: maxY,
                  lineTouchData: const LineTouchData(enabled: false),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                        reservedSize: _leftReserved,
                      ),
                    ),
                    bottomTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(BuildContext context, ColorScheme colors) {
    return Row(
      children: [
        _barLegend(context, _blueColor, 'Ingresos', colors),
        const SizedBox(width: 20),
        _barLegend(context, _orangeColor, 'Egresos', colors),
      ],
    );
  }

  Widget _barLegend(
    BuildContext context,
    Color color,
    String label,
    ColorScheme colors,
  ) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: AppTextStyles.mainStyle10(context).copyWith(
            color: colors.lead.withValues(alpha: 0.75),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _lineLegend(
    BuildContext context,
    Color color,
    String label,
    ColorScheme colors,
  ) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 2.5,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: AppTextStyles.mainStyle10(context).copyWith(
            color: colors.lead.withValues(alpha: 0.75),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
