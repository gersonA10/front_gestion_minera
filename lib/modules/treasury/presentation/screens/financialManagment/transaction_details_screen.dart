import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/bloc/treasury_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../widgets/widgtes.dart';

class TransactionPdfService {
  static Future<File> generateComprobante({
    required String concepto,
    required String responsable,
    required String cajaOrigen,
    required String fechaHora,
    required String referencia,
    required String monto,
    required String estado,
  }) async {
    final pdf = pw.Document();

    final primaryColor = PdfColor.fromHex('#1E293B');
    final accentColor = PdfColor.fromHex('#3B82F6');
    final successColor = PdfColor.fromHex('#16A34A');
    final lightGray = PdfColor.fromHex('#F3F4F6');
    final borderGray = PdfColor.fromHex('#E5E7EB');
    final textDark = PdfColor.fromHex('#1F2937');
    final textMuted = PdfColor.fromHex('#6B7280');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(24),
                decoration: pw.BoxDecoration(
                  color: primaryColor,
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'COMPROBANTE DE PAGO',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Gestión Minera',
                          style: pw.TextStyle(
                            color: PdfColor.fromHex('#94A3B8'),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: pw.BoxDecoration(
                        color: successColor,
                        borderRadius: pw.BorderRadius.circular(16),
                      ),
                      child: pw.Text(
                        estado,
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),

              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Monto Total',
                      style: pw.TextStyle(color: textMuted, fontSize: 12),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      monto,
                      style: pw.TextStyle(
                        color: textDark,
                        fontSize: 32,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),
              pw.Divider(color: borderGray, thickness: 1),
              pw.SizedBox(height: 20),

              pw.Text(
                'Información General',
                style: pw.TextStyle(
                  color: accentColor,
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),

              _pdfRow('Concepto', concepto, textMuted, textDark),
              _pdfDivider(lightGray),
              _pdfRow('Responsable', responsable, textMuted, textDark),
              _pdfDivider(lightGray),
              _pdfRow('Caja Origen', cajaOrigen, textMuted, textDark),
              _pdfDivider(lightGray),
              _pdfRow('Fecha y Hora', fechaHora, textMuted, textDark),
              _pdfDivider(lightGray),
              _pdfRow('ID Referencia', referencia, textMuted, textDark),

              pw.SizedBox(height: 40),

              // ── Pie de página ───────────────────────────────────
              pw.Divider(color: borderGray, thickness: 1),
              pw.SizedBox(height: 12),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Documento generado automáticamente',
                    style: pw.TextStyle(color: textMuted, fontSize: 9),
                  ),
                  pw.Text(
                    'Fecha de emisión: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                    style: pw.TextStyle(color: textMuted, fontSize: 9),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final sanitized = referencia.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    final file = File('${dir.path}/comprobante_$sanitized.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.Widget _pdfRow(
    String label,
    String value,
    PdfColor labelColor,
    PdfColor valueColor,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 10),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 2,
            child: pw.Text(
              label,
              style: pw.TextStyle(color: labelColor, fontSize: 11),
            ),
          ),
          pw.Expanded(
            flex: 3,
            child: pw.Text(
              value,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                color: valueColor,
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _pdfDivider(PdfColor color) {
    return pw.Divider(color: color, thickness: 0.5);
  }
}

@RoutePage()
class TransactionDetailsScreen extends StatelessWidget {
  final String idTransaction;

  const TransactionDetailsScreen({super.key, required this.idTransaction});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          InjectorContainer.getIt<TreasuryBloc>()
            ..add(TransactionDetailsEvent(idTransaction: idTransaction)),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
            onPressed: () => context.router.maybePop(),
          ),
          centerTitle: true,
          title: const Text(
            'Detalle de Transacción',
            style: TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: const Color(0xFFE5E7EB), height: 1),
          ),
        ),
        body: BlocConsumer<TreasuryBloc, TreasuryState>(
          listener: (context, state) {
            if (state is TransactionDetailsError) {
              context.router.maybePop();
              CustomAlert.show(
                context,
                title: 'Error',
                message: state.message,
                type: AlertType.error,
              );
            }
          },
          builder: (context, state) {
            if (state is TransactionDetailsLoading) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: Color(0xFF3B82F6),
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Cargando detalle...',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              );
            }
            if (state is TransactionDetailsLoaded) {
              return LoadedView(details: state.transactionDetails);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}


