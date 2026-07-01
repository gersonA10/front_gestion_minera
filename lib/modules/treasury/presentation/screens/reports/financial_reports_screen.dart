import 'dart:convert'; // Para codificar el CSV (Excel)
import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/utils/text_util.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

// Importaciones para PDF y Share
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/treasury/domain/entity/financial_report_entity.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/bloc/treasury_bloc.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/widgets/reports/chart_card_widget.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/widgets/reports/metric_card_widget.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/widgets/reports/expense_donut_widget.dart';
import 'package:fl_chart/fl_chart.dart';

@RoutePage()
class FinancialReportsScreen extends StatefulWidget {
  const FinancialReportsScreen({super.key});

  @override
  State<FinancialReportsScreen> createState() => _FinancialReportsScreenState();
}

class _FinancialReportsScreenState extends State<FinancialReportsScreen> {
  late final TreasuryBloc _bloc;

  String _currentPeriod = 'month';
  late DateTime _selectedDate;
  final DateTime _currentDate = DateTime.now();

  // Rango personalizado (period == 'custom')
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  FinancialReportEntity? _cachedReport;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es', null);
    _bloc = InjectorContainer.getIt<TreasuryBloc>();
    _selectedDate = DateTime(_currentDate.year, _currentDate.month, 1);
    _fetchReport();
  }

  void _fetchReport() {
    if (_currentPeriod == 'custom') {
      if (_rangeStart == null || _rangeEnd == null) return;
      final fmt = DateFormat('yyyy-MM-dd');
      _bloc.add(
        GetFinancialReportEvent(
          period: 'custom',
          startDate: fmt.format(_rangeStart!),
          endDate: fmt.format(_rangeEnd!),
        ),
      );
      return;
    }

    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    _bloc.add(
      GetFinancialReportEvent(period: _currentPeriod, exactDate: formattedDate),
    );
  }

  Future<void> _pickDateRange() async {
    final initialRange = (_rangeStart != null && _rangeEnd != null)
        ? DateTimeRange(start: _rangeStart!, end: _rangeEnd!)
        : DateTimeRange(
            start: DateTime(_currentDate.year, _currentDate.month, 1),
            end: _currentDate,
          );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: _currentDate,
      initialDateRange: initialRange,
      locale: const Locale('es'),
      helpText: 'Selecciona el rango de fechas',
      saveText: 'Aplicar',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: const Color(0xFF1D54F3)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _rangeStart = picked.start;
        _rangeEnd = picked.end;
      });
      _fetchReport();
    }
  }

  void _changeDate(int offset) {
    setState(() {
      if (_currentPeriod == 'month') {
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month + offset,
          1,
        );
      } else {
        _selectedDate = DateTime(
          _selectedDate.year + offset,
          _selectedDate.month,
          1,
        );
      }
    });
    _fetchReport();
  }

  bool _canGoForward() {
    if (_currentPeriod == 'month') {
      return _selectedDate.year < _currentDate.year ||
          (_selectedDate.year == _currentDate.year &&
              _selectedDate.month < _currentDate.month);
    }
    return _selectedDate.year < _currentDate.year;
  }

  String _getFormattedDateLabel() {
    if (_currentPeriod == 'custom') {
      if (_rangeStart == null || _rangeEnd == null) return 'Rango personalizado';
      final f = DateFormat('dd/MM/yyyy');
      return '${f.format(_rangeStart!)} - ${f.format(_rangeEnd!)}';
    }
    if (_currentPeriod == 'month') {
      final dateStr = DateFormat.yMMMM('es').format(_selectedDate);
      return '${dateStr[0].toUpperCase()}${dateStr.substring(1)}';
    }
    return DateFormat.y().format(_selectedDate);
  }

  /// Etiqueta apta para nombre de archivo (sin espacios ni '/').
  String _safeFileLabel() =>
      _getFormattedDateLabel().replaceAll(' ', '_').replaceAll('/', '-');

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final smallSpacing = MediaQuery.of(context).size.height * 0.02;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colors.black, size: 20),
          onPressed: () => context.router.back(),
        ),
        title: Text(
          'Reportes Financieros',
          style: AppTextStyles.mainStyle16Bold(
            context,
          ).copyWith(color: colors.black),
        ),
      ),
      body: BlocBuilder<TreasuryBloc, TreasuryState>(
        bloc: _bloc,
        builder: (context, state) {
          final isLoading = state is FinancialReportLoading;

          if (state is FinancialReportLoaded) {
            _cachedReport = state.report;
          }

          if (_cachedReport == null && isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1D54F3)),
            );
          }

          if (_cachedReport == null && state is FinancialReportError) {
            return _buildErrorState(context, colors, state.message);
          }

          if (_cachedReport != null) {
            return Stack(
              children: [
                RefreshIndicator(
                  onRefresh: () async => _fetchReport(),
                  color: const Color(0xFF1D54F3),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 8.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTabSelector(context, colors),
                        SizedBox(height: smallSpacing),

                        _currentPeriod == 'custom'
                            ? _buildRangeSelector(context, colors)
                            : _buildDateSelector(context, colors),
                        SizedBox(height: smallSpacing * 1.5),

                        _buildHeroBalance(context, colors, _cachedReport!),
                        SizedBox(height: smallSpacing * 1.5),

                        _buildSummaryCards(
                          context,
                          colors,
                          _cachedReport!.resumenGeneral,
                        ),
                        SizedBox(height: smallSpacing * 1.5),

                        _buildSectionLabel(context, 'INDICADORES CLAVE'),
                        SizedBox(height: smallSpacing),
                        _buildKpiSection(context, colors, _cachedReport!),
                        SizedBox(height: smallSpacing * 1.5),

                        ChartCardWidget(colors, _cachedReport!.datosGrafica),
                        SizedBox(height: smallSpacing * 2),

                        ExpenseDonutWidget(
                          colors,
                          _cachedReport!.gastosPorResponsable,
                        ),
                        SizedBox(height: smallSpacing * 2),

                        _buildReconciliationSection(
                          context,
                          colors,
                          _cachedReport!.conciliacion,
                        ),
                        SizedBox(height: smallSpacing * 2),

                        _buildExportButton(
                          context,
                          colors,
                          _cachedReport!,
                        ),
                        SizedBox(height: smallSpacing * 4),
                      ],
                    ),
                  ),
                ),

                if (isLoading)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: const LinearProgressIndicator(
                      color: Color(0xFF1D54F3),
                    ),
                  ),
                if (isLoading)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        color: colors.backgroundColor.withValues(alpha:  0.3),
                      ),
                    ),
                  ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // --- WIDGETS DE ESTADOS ---
  Widget _buildErrorState(
    BuildContext context,
    ColorScheme colors,
    String message,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: colors.red.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchReport,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D54F3),
            ),
            child: const Text(
              "Reintentar",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS DE LA UI PRINCIPAL ---
  Widget _buildTabSelector(BuildContext context, ColorScheme colors) {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.lead.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _buildTabItem(context, colors, 'Mensual', 'month'),
          _buildTabItem(context, colors, 'Anual', 'year'),
          _buildTabItem(context, colors, 'Personalizado', 'custom'),
        ],
      ),
    );
  }

  Widget _buildTabItem(
    BuildContext context,
    ColorScheme colors,
    String title,
    String periodValue,
  ) {
    final isSelected = _currentPeriod == periodValue;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (!isSelected) {
            setState(() {
              _currentPeriod = periodValue;
              // Al entrar por primera vez al rango, precargamos el mes actual.
              if (periodValue == 'custom' &&
                  (_rangeStart == null || _rangeEnd == null)) {
                _rangeStart = DateTime(
                  _currentDate.year,
                  _currentDate.month,
                  1,
                );
                _rangeEnd = _currentDate;
              }
            });
            _fetchReport();
          }
        },
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : [],
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              maxLines: 1,
              style: isSelected
                  ? AppTextStyles.mainStyle12Bold(
                      context,
                    ).copyWith(color: colors.black)
                  : AppTextStyles.mainStyle12(
                      context,
                    ).copyWith(color: colors.lead.withValues(alpha: 0.8)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context, ColorScheme colors) {
    final canGoForward = _canGoForward();
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.lead.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: colors.lead),
            onPressed: () => _changeDate(-1),
          ),
          Text(
            _getFormattedDateLabel(),
            style: AppTextStyles.mainStyle14Bold(
              context,
            ).copyWith(color: colors.black),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              color: canGoForward
                  ? colors.lead
                  : colors.lead.withValues(alpha: 0.3),
            ),
            onPressed: canGoForward ? () => _changeDate(1) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildRangeSelector(BuildContext context, ColorScheme colors) {
    final hasRange = _rangeStart != null && _rangeEnd != null;
    return InkWell(
      onTap: _pickDateRange,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.lead.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Icon(Icons.date_range_rounded, color: colors.lead, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hasRange ? _getFormattedDateLabel() : 'Seleccionar rango',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.mainStyle14Bold(
                  context,
                ).copyWith(color: colors.black),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.edit_calendar_outlined,
              color: Color(0xFF1D54F3),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(
    BuildContext context,
    ColorScheme colors,
    GeneralSummaryEntity summary,
  ) {
    final total = summary.ingresosTotales + summary.egresosTotales;
    final ingresoShare =
        total == 0 ? 0.0 : (summary.ingresosTotales / total) * 100;
    final egresoShare =
        total == 0 ? 0.0 : (summary.egresosTotales / total) * 100;

    return Row(
      children: [
        MetricCardWidget(
          colors: colors,
          title: 'INGRESOS',
          amount: summary.ingresosTotales,
          icon: Icons.trending_up,
          iconColor: const Color(0xFF10B981),
          subtitle: '${ingresoShare.toStringAsFixed(0)}% del flujo',
        ),
        const SizedBox(width: 12),
        MetricCardWidget(
          colors: colors,
          title: 'EGRESOS',
          amount: summary.egresosTotales,
          icon: Icons.trending_down,
          iconColor: const Color(0xFFEF4444),
          subtitle: '${egresoShare.toStringAsFixed(0)}% del flujo',
        ),
      ],
    );
  }

  // ---------- Conciliación (reposiciones de Campamento) ----------
  Widget _buildReconciliationSection(
    BuildContext context,
    ColorScheme colors,
    ReconciliationSummaryEntity c,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(context, 'CONCILIACIÓN DE CAMPAMENTO'),
        const SizedBox(height: 10),
        Row(
          children: [
            MetricCardWidget(
              colors: colors,
              title: 'DEVOLUCIONES',
              amount: c.totalDevoluciones,
              icon: Icons.south_west_rounded,
              iconColor: const Color(0xFF10B981),
              subtitle:
                  '${c.countDevoluciones} ${c.countDevoluciones == 1 ? 'sobrante' : 'sobrantes'}',
            ),
            const SizedBox(width: 12),
            MetricCardWidget(
              colors: colors,
              title: 'COMPENSACIONES',
              amount: c.totalCompensaciones,
              icon: Icons.north_east_rounded,
              iconColor: const Color(0xFFF59E0B),
              subtitle:
                  '${c.countCompensaciones} ${c.countCompensaciones == 1 ? 'reintegro' : 'reintegros'}',
            ),
          ],
        ),
        if (c.hasActivity) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A56FF).withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF1A56FF).withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.sync_alt_rounded,
                  size: 16,
                  color: Color(0xFF1A56FF),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Neto recuperado por conciliación',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7A99),
                    ),
                  ),
                ),
                Text(
                  _money(c.neto),
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: c.neto >= 0
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ---------- Helpers de KPIs ----------
  double _pct(double part, double whole) => whole == 0 ? 0 : (part / whole) * 100;

  String _money(double v) =>
      '${NumberFormat.currency(symbol: '', decimalDigits: 2).format(v)} Bs';

  /// Color del estado de salud financiera según su texto.
  Color _healthColor(String estado) {
    final e = estado.toLowerCase();
    if (e.contains('salud') ||
        e.contains('positiv') ||
        e.contains('estable') ||
        e.contains('bueno') ||
        e.contains('óptim') ||
        e.contains('optim') ||
        e.contains('super')) {
      return const Color(0xFF10B981); // verde
    }
    if (e.contains('riesgo') ||
        e.contains('alerta') ||
        e.contains('crit') ||
        e.contains('crít') ||
        e.contains('negativ') ||
        e.contains('defic') ||
        e.contains('défic') ||
        e.contains('malo')) {
      return const Color(0xFFEF4444); // rojo
    }
    return const Color(0xFFF59E0B); // ámbar (neutro / desconocido)
  }

  Widget _buildSectionLabel(BuildContext context, String text) {
    return Text(
      text,
      style: AppTextStyles.mainStyleGrey10(
        context,
      ).copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5),
    );
  }

  // ---------- Hero: Balance neto + estado de salud ----------
  Widget _buildHeroBalance(
    BuildContext context,
    ColorScheme colors,
    FinancialReportEntity report,
  ) {
    final s = report.resumenGeneral;
    final margen = _pct(s.balanceNeto, s.ingresosTotales);
    final healthColor = _healthColor(s.estadoSalud);
    final isPositive = s.balanceNeto >= 0;
    final estadoLabel = s.estadoSalud.length > 16
        ? '${s.estadoSalud.substring(0, 15)}…'
        : s.estadoSalud;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0C2340), Color(0xFF153D63)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0C2340).withValues(alpha: 0.30),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'BALANCE NETO · ${_getFormattedDateLabel().toUpperCase()}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: healthColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: healthColor.withValues(alpha: 0.45),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: healthColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      estadoLabel,
                      style: TextStyle(
                        color: healthColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '${_money(s.balanceNeto)}.',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                isPositive
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                size: 16,
                color: isPositive
                    ? const Color(0xFF34D399)
                    : const Color(0xFFF87171),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${margen.toStringAsFixed(1)}% de margen sobre ingresos',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (report.datosGrafica.length >= 2) ...[
            const SizedBox(height: 16),
            _heroSparkline(report.datosGrafica),
          ],
          const SizedBox(height: 16),
          _heroFlowRow(context, s),
        ],
      ),
    );
  }

  Widget _heroSparkline(List<ChartDataEntity> data) {
    double minY = data.first.margen;
    double maxY = data.first.margen;
    for (final d in data) {
      if (d.margen < minY) minY = d.margen;
      if (d.margen > maxY) maxY = d.margen;
    }
    if (minY == maxY) {
      minY -= 1;
      maxY += 1;
    }
    final pad = (maxY - minY) * 0.18;

    return SizedBox(
      height: 46,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (data.length - 1).toDouble(),
          minY: minY - pad,
          maxY: maxY + pad,
          lineTouchData: const LineTouchData(enabled: false),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (int i = 0; i < data.length; i++)
                  FlSpot(i.toDouble(), data[i].margen),
              ],
              isCurved: true,
              preventCurveOverShooting: true,
              color: Colors.white.withValues(alpha: 0.9),
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.28),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroFlowRow(BuildContext context, GeneralSummaryEntity s) {
    return Row(
      children: [
        Expanded(
          child: _heroMiniStat(
            'Ingresos',
            _money(s.ingresosTotales),
            const Color(0xFF34D399),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          width: 1,
          height: 30,
          color: Colors.white.withValues(alpha: 0.15),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _heroMiniStat(
            'Egresos',
            _money(s.egresosTotales),
            const Color(0xFFF87171),
          ),
        ),
      ],
    );
  }

  Widget _heroMiniStat(String label, String value, Color dot) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  // ---------- Sección de KPIs (derivados de datos reales) ----------
  Widget _buildKpiSection(
    BuildContext context,
    ColorScheme colors,
    FinancialReportEntity report,
  ) {
    final s = report.resumenGeneral;
    final detalle = report.detalleAbsolutoPdf;

    final margen = _pct(s.balanceNeto, s.ingresosTotales);
    final gastoPct = _pct(s.egresosTotales, s.ingresosTotales);
    final movimientos = detalle.length;
    final ticket = detalle.isEmpty
        ? 0.0
        : detalle.fold<double>(0, (sum, e) => sum + e.monto) / detalle.length;
    final mayor = detalle.isEmpty
        ? 0.0
        : detalle.map((e) => e.monto).reduce((a, b) => a > b ? a : b);
    final cajas = detalle
        .map((e) => e.caja)
        .where((c) => c.trim().isNotEmpty)
        .toSet()
        .length;

    final margenColor = s.balanceNeto >= 0
        ? const Color(0xFF10B981)
        : const Color(0xFFEF4444);
    const primary = Color(0xFF1D54F3);

    final tiles = <Widget>[
      _buildKpiTile(
        context,
        colors,
        icon: Icons.savings_outlined,
        accent: margenColor,
        label: 'MARGEN NETO',
        value: '${margen.toStringAsFixed(1)}%',
        sub: 'sobre ingresos',
      ),
      _buildKpiTile(
        context,
        colors,
        icon: Icons.pie_chart_outline,
        accent: const Color(0xFFF59E0B),
        label: 'TASA DE GASTO',
        value: '${gastoPct.toStringAsFixed(1)}%',
        sub: 'egresos / ingresos',
      ),
      _buildKpiTile(
        context,
        colors,
        icon: Icons.receipt_long_outlined,
        accent: primary,
        label: 'MOVIMIENTOS',
        value: '$movimientos',
        sub: 'transacciones',
      ),
      _buildKpiTile(
        context,
        colors,
        icon: Icons.sell_outlined,
        accent: primary,
        label: 'TICKET PROMEDIO',
        value: _money(ticket),
        sub: 'por movimiento',
      ),
      _buildKpiTile(
        context,
        colors,
        icon: Icons.arrow_outward_rounded,
        accent: const Color(0xFFEF4444),
        label: 'MAYOR MOVIMIENTO',
        value: _money(mayor),
        sub: 'monto máximo',
      ),
      _buildKpiTile(
        context,
        colors,
        icon: Icons.account_balance_outlined,
        accent: primary,
        label: 'CAJAS ACTIVAS',
        value: '$cajas',
        sub: 'con movimiento',
      ),
    ];

    final rows = <Widget>[];
    for (var i = 0; i < tiles.length; i += 2) {
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: tiles[i]),
            const SizedBox(width: 12),
            if (i + 1 < tiles.length)
              Expanded(child: tiles[i + 1])
            else
              const Spacer(),
          ],
        ),
      );
      if (i + 2 < tiles.length) rows.add(const SizedBox(height: 12));
    }
    return Column(children: rows);
  }

  Widget _buildKpiTile(
    BuildContext context,
    ColorScheme colors, {
    required IconData icon,
    required Color accent,
    required String label,
    required String value,
    String? sub,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.lead.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: accent),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: AppTextStyles.mainStyleGrey10(
              context,
            ).copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.4),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTextStyles.mainStyle20Bold(
                context,
              ).copyWith(fontSize: 18, color: colors.black),
            ),
          ),
          if (sub != null) ...[
            const SizedBox(height: 3),
            Text(
              sub,
              style: AppTextStyles.mainStyle10(
                context,
              ).copyWith(color: colors.lead.withValues(alpha: 0.8)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExportButton(
    BuildContext context,
    ColorScheme colors,
    FinancialReportEntity report,
  ) {
    final String exportPeriod = _currentPeriod == 'month'
        ? 'Mensual'
        : _currentPeriod == 'year'
        ? 'Anual'
        : 'Personalizado';

    return InkWell(
      onTap: () => _showExportModal(context, report),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.share_outlined, color: Colors.white, size: 20),
            Expanded(
              child: Center(
                child: Text(
                  'Exportar Reporte\n$exportPeriod',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.mainStyleWhite14Bold(
                    context,
                  ).copyWith(height: 1.3),
                ),
              ),
            ),
            Container(
              height: 24,
              width: 1,
              color: Colors.white.withValues(alpha: 0.2),
              margin: const EdgeInsets.symmetric(horizontal: 16),
            ),
            Text(
              'PDF  XLS',
              style: AppTextStyles.mainStyleWhite10Bold(
                context,
              ).copyWith(fontSize: 11, letterSpacing: 1.0),
            ),
          ],
        ),
      ),
    );
  }

  void _showExportModal(BuildContext context, FinancialReportEntity report) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exportar Reporte',
              style: AppTextStyles.mainStyle16Bold(context),
            ),
            const SizedBox(height: 8),
            Text(
              'Selecciona el formato en el que deseas descargar el detalle completo de este periodo.',
              style: AppTextStyles.mainStyle12(context),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(
                Icons.picture_as_pdf,
                color: Colors.redAccent,
                size: 30,
              ),
              title: const Text(
                'Documento PDF',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Ideal para impresión y lectura'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _generateAndSharePDF(report);
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(
                Icons.table_chart,
                color: Colors.green,
                size: 30,
              ),
              title: const Text(
                'Hoja de cálculo Excel',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Ideal para análisis de datos (.csv)'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _generateAndShareExcel(report);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

Future<void> _generateAndSharePDF(FinancialReportEntity report) async {
    final pdf = pw.Document();
    final formatCurrency = NumberFormat.currency(
      symbol: 'Bs. ',
      decimalDigits: 2,
    );

    // Fuentes Unicode para soportar acentos y ñ
    final fontRegular = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    // Limpiamos la fecha de la base de datos
    String formatPdfDate(String rawDate) {
      try {
        final DateTime dt = DateTime.parse(rawDate);
        return DateFormat('dd/MM/yyyy HH:mm').format(dt);
      } catch (e) {
        return rawDate.split('.').first;
      }
    }

    pdf.addPage(
      pw.MultiPage(
        // Cambiado a PORTRAIT (PdfPageFormat.a4 por defecto es Vertical)
        pageFormat: PdfPageFormat.a4, 
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold),
        header: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Reporte Financiero Detallado',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'Periodo: ${_getFormattedDateLabel()}',
                style: const pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 15),
            ],
          );
        },
        build: (pw.Context context) {
          return [
            // Resumen de Cabecera
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Ingresos Totales',
                        style: pw.TextStyle(
                          color: PdfColors.grey700,
                          fontSize: 10,
                        ),
                      ),
                      pw.Text(
                        formatCurrency.format(
                          report.resumenGeneral.ingresosTotales,
                        ),
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.green,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Egresos Totales',
                        style: pw.TextStyle(
                          color: PdfColors.grey700,
                          fontSize: 10,
                        ),
                      ),
                      pw.Text(
                        formatCurrency.format(
                          report.resumenGeneral.egresosTotales,
                        ),
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.red,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Balance Neto',
                        style: pw.TextStyle(
                          color: PdfColors.grey700,
                          fontSize: 10,
                        ),
                      ),
                      pw.Text(
                        formatCurrency.format(
                          report.resumenGeneral.balanceNeto,
                        ),
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            pw.Text(
              'Listado de Transacciones',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),

            // TABLA CON TODO (Portrait)
            pw.TableHelper.fromTextArray(
              context: context,
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.blue900,
              ),
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: 9, // Letra ligeramente más pequeña para Portrait
              ),
              cellStyle: const pw.TextStyle(fontSize: 7), // Compacto para que entre en la hoja vertical
              rowDecoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                ),
              ),
              cellPadding: const pw.EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 6,
              ),

              // Proporciones ajustadas para la hoja angosta (Vertical)
              columnWidths: {
                0: const pw.FlexColumnWidth(1.4), // Fecha
                1: const pw.FlexColumnWidth(1.6), // Tipo de Mov.
                2: const pw.FlexColumnWidth(1.2), // Caja
                3: const pw.FlexColumnWidth(2.0), // Responsable
                4: const pw.FlexColumnWidth(3.0), // Concepto (Se lleva más espacio para bajar a 2 líneas fluidamente)
                5: const pw.FlexColumnWidth(1.5), // Monto
              },

              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.centerLeft,
                4: pw.Alignment.centerLeft,
                5: pw.Alignment.centerRight,
              },

              headers: [
                'Fecha',
                'Tipo',
                'Caja',
                'Responsable',
                'Concepto',
                'Monto',
              ],

              data: report.detalleAbsolutoPdf.map((item) {
                return [
                  formatPdfDate(item.fecha),
                  item.tipo,
                  item.caja,
                  item.responsable,
                  item.concepto,
                  formatCurrency.format(item.monto),
                ];
              }).toList(),
            ),
          ];
        },
      ),
    );

    final fileName = 'Reporte_${_currentPeriod}_${_safeFileLabel()}.pdf';
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: fileName,
    );
  }

  Future<void> _generateAndShareExcel(FinancialReportEntity report) async {
    final StringBuffer csvBuffer = StringBuffer();
    
    csvBuffer.writeln('REPORTE FINANCIERO DETALLADO');
    csvBuffer.writeln('Periodo:;${_getFormattedDateLabel()}');
    csvBuffer.writeln('');
    
    csvBuffer.writeln('RESUMEN GENERAL');
    csvBuffer.writeln('Ingresos Totales;Egresos Totales;Balance Neto;Estado');
    csvBuffer.writeln('${report.resumenGeneral.ingresosTotales};${report.resumenGeneral.egresosTotales};${report.resumenGeneral.balanceNeto};${report.resumenGeneral.estadoSalud}');
    csvBuffer.writeln('');
    
    csvBuffer.writeln('LISTADO DE TRANSACCIONES');
    csvBuffer.writeln('Fecha;Tipo de Movimiento;Caja;Responsable;Concepto;Monto(Bs)');

    for (var item in report.detalleAbsolutoPdf) {
      final cleanConcepto = item.concepto.replaceAll('\n', ' ').replaceAll(';', ',');
      final cleanFecha = item.fecha.split('.').first; 

      csvBuffer.writeln('$cleanFecha;${item.tipo};${item.caja};${item.responsable};$cleanConcepto;${item.monto}');
    }

    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'Reporte_${_currentPeriod}_${_safeFileLabel()}.csv';
    final file = File('${directory.path}/$fileName');
    
    await file.writeAsBytes([239, 187, 191, ...utf8.encode(csvBuffer.toString())]);

    final xFile = XFile(file.path, mimeType: 'text/csv');
    await Share.shareXFiles([xFile], text: 'Adjunto Reporte Financiero de ${_getFormattedDateLabel()}');
  }
}