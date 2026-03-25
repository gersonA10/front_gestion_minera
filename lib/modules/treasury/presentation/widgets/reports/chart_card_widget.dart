import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/utils/text_util.dart';
import '../../../domain/entity/entity.dart';

class ChartCardWidget extends StatelessWidget {
  const ChartCardWidget(this.colors, this.datosGrafica, {super.key});

  final ColorScheme colors;
  final List<ChartDataEntity> datosGrafica;

  @override
  Widget build(BuildContext context) {
    double maxY = 0;
    for (var data in datosGrafica) {
      if (data.ingresos > maxY) maxY = data.ingresos;
      if (data.egresos > maxY) maxY = data.egresos;
    }
    maxY = (maxY == 0) ? 100 : maxY * 1.2;

    const blueColor = Color(0xFF1D54F3);
    const greyColor = Color(0xFFD1D5DB);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.lead.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'COMPARATIVA DE FLUJOS',
            style: AppTextStyles.mainStyleGrey10(context).copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 30),
          datosGrafica.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      "No hay datos para la gráfica",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              : SizedBox(
                  height: 180,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxY,
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= 0 && value.toInt() < datosGrafica.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    'S${value.toInt() + 1}', // Simulando S1, S2, S3, S4 como en la imagen
                                    style: TextStyle(
                                      color: colors.lead.withValues(alpha: 0.7),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(datosGrafica.length, (i) {
                        return BarChartGroupData(
                          x: i,
                          barsSpace: 0, // Barras completamente pegadas
                          barRods: [
                            BarChartRodData(
                              toY: datosGrafica[i].ingresos,
                              color: blueColor,
                              width: 30, // Barras más anchas
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(2), topRight: Radius.circular(2)),
                            ),
                            BarChartRodData(
                              toY: datosGrafica[i].egresos,
                              color: greyColor,
                              width: 30,
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(2), topRight: Radius.circular(2)),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildLegendItem(context, blueColor, 'Ingresos', colors),
              const SizedBox(width: 16),
              _buildLegendItem(context, greyColor, 'Egresos', colors),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, Color color, String label, ColorScheme colors) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.mainStyle10(context).copyWith(
            color: colors.lead.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}