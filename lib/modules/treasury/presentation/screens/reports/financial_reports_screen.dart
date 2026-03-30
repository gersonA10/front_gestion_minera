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
    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    _bloc.add(
      GetFinancialReportEvent(period: _currentPeriod, exactDate: formattedDate),
    );
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
    if (_currentPeriod == 'month') {
      final dateStr = DateFormat.yMMMM('es').format(_selectedDate);
      return '${dateStr[0].toUpperCase()}${dateStr.substring(1)}';
    }
    return DateFormat.y().format(_selectedDate);
  }

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
          onPressed: () => context.router.maybePop(),
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

                        _buildDateSelector(context, colors),
                        SizedBox(height: smallSpacing * 1.5),

                        _buildSummaryCards(
                          context,
                          colors,
                          _cachedReport!.resumenGeneral,
                        ),
                        SizedBox(height: smallSpacing * 1.5),

                        _buildNetBalanceCard(
                          context,
                          colors,
                          _cachedReport!.resumenGeneral,
                        ),
                        SizedBox(height: smallSpacing * 1.5),

                        ChartCardWidget(colors, _cachedReport!.datosGrafica),
                        SizedBox(height: smallSpacing * 2),

                        Text(
                          'GASTOS POR RESPONSABLE',
                          style: AppTextStyles.mainStyleGrey10(context)
                              .copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                        ),
                        SizedBox(height: smallSpacing),

                        _buildExpensesList(
                          context,
                          colors,
                          _cachedReport!.gastosPorResponsable,
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
            setState(() => _currentPeriod = periodValue);
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
          child: Text(
            title,
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

  Widget _buildSummaryCards(
    BuildContext context,
    ColorScheme colors,
    GeneralSummaryEntity summary,
  ) {
    return Row(
      children: [
        MetricCardWidget(
          colors: colors,
          title: 'INGRESOS',
          amount: summary.ingresosTotales,
          icon: Icons.trending_up,
          iconColor: const Color(0xFF10B981),
          percentage: summary.ingresosTotales,
        ),
        const SizedBox(width: 12),
        MetricCardWidget(
          colors: colors,
          title: 'EGRESOS',
          amount: summary.egresosTotales,
          icon: Icons.trending_down,
          iconColor: const Color(0xFFEF4444),
          percentage: summary.egresosTotales,
        ),
      ],
    );
  }

  Widget _buildNetBalanceCard(
    BuildContext context,
    ColorScheme colors,
    GeneralSummaryEntity summary,
  ) {
    final formatCurrency = NumberFormat.currency(symbol: '', decimalDigits: 2);
    const mainColor = Color(0xFF1D54F3);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: mainColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BALANCE NETO HACIENDA',
                style: AppTextStyles.mainStyleGrey10(
                  context,
                ).copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),
              Text(
                '${formatCurrency.format(summary.balanceNeto)} Bs.',
                style: AppTextStyles.mainStyleBlue25Bold(
                  context,
                ).copyWith(fontSize: 26, color: mainColor),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: mainColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: mainColor,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesList(
    BuildContext context,
    ColorScheme colors,
    List<ExpenseByResponsibleEntity> expenses,
  ) {
    if (expenses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.lead.withValues(alpha: 0.15)),
        ),
        child: const Center(
          child: Text(
            "No hay gastos registrados",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final formatCurrency = NumberFormat.currency(symbol: '', decimalDigits: 2);

    return Container(
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.lead.withValues(alpha: 0.15)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: expenses.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: colors.lead.withValues(alpha: 0.1)),
        itemBuilder: (context, index) {
          final expense = expenses[index];

          IconData icon = Icons.payments_outlined;
          Color iconColor = colors.black;
          Color iconBg = colors.lead.withValues(alpha: 0.1);

          if (expense.area.contains("Urgentes")) {
            icon = Icons.priority_high;
            iconColor = const Color(0xFFEF4444);
            iconBg = const Color(0xFFFEF2F2);
          } else if (expense.area.contains("Máquinas")) {
            icon = Icons.settings_outlined;
          } else if (expense.area.contains("Campamento") ||
              expense.area.contains("Socios")) {
            icon = Icons.business_outlined;
          }

          return _buildExpenseItem(
            context: context,
            icon: icon,
            iconBg: iconBg,
            iconColor: iconColor,
            title: expense.area,
            subtitle: 'Egresos',
            amount: '${formatCurrency.format(expense.monto)} Bs.',
            percentage:
                '${expense.porcentajeDelTotal.toStringAsFixed(0)}% del total',
            colors: colors,
            isDanger: expense.area.contains("Urgentes"),
          );
        },
      ),
    );
  }

  Widget _buildExpenseItem({
    required BuildContext context,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String amount,
    required String percentage,
    required ColorScheme colors,
    bool isDanger = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.mainStyle14Bold(context).copyWith(
                    color: isDanger ? const Color(0xFFEF4444) : colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.mainStyle12(
                    context,
                  ).copyWith(color: colors.lead),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: AppTextStyles.mainStyle14Bold(context).copyWith(
                  color: isDanger ? const Color(0xFFEF4444) : colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                percentage,
                style: AppTextStyles.mainStyle10(
                  context,
                ).copyWith(color: colors.lead.withValues(alpha: 0.8)),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildExportButton(
    BuildContext context,
    ColorScheme colors,
    FinancialReportEntity report,
  ) {
    final String exportPeriod = _currentPeriod == 'month' ? 'Mensual' : 'Anual';

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

    final fileName =
        'Reporte_${_currentPeriod}_${_getFormattedDateLabel().replaceAll(" ", "_")}.pdf';
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
    final fileName = 'Reporte_${_currentPeriod}_${_getFormattedDateLabel().replaceAll(" ", "_")}.csv';
    final file = File('${directory.path}/$fileName');
    
    await file.writeAsBytes([239, 187, 191, ...utf8.encode(csvBuffer.toString())]);

    final xFile = XFile(file.path, mimeType: 'text/csv');
    await Share.shareXFiles([xFile], text: 'Adjunto Reporte Financiero de ${_getFormattedDateLabel()}');
  }
}