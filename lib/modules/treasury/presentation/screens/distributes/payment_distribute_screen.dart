import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

@RoutePage()
class PaymentSuccessDistributionScreen extends StatefulWidget {
  final String beneficiario;
  final String montoPagado;
  final String periodo;
  final String fechaHora;
  final String cajaOrigen;
  final String saldoRestante;

  const PaymentSuccessDistributionScreen({
    super.key,
    required this.beneficiario,
    required this.montoPagado,
    required this.periodo,
    required this.fechaHora,
    required this.cajaOrigen,
    required this.saldoRestante,
  });

  @override
  State<PaymentSuccessDistributionScreen> createState() =>
      _PaymentSuccessDistributionScreenState();
}

class _PaymentSuccessDistributionScreenState
    extends State<PaymentSuccessDistributionScreen> {
  bool _isGenerating = false;

  Future<void> _downloadComprobante() async {
    setState(() => _isGenerating = true);
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context ctx) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    'COMPROBANTE DE PAGO DE DIVIDENDOS',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Center(
                  child: pw.Text(
                    'Pago registrado exitosamente',
                    style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
                  ),
                ),
                pw.SizedBox(height: 24),
                pw.Divider(),
                pw.SizedBox(height: 12),
                _pdfRow('Beneficiario', widget.beneficiario),
                _pdfRow('Monto Pagado', widget.montoPagado),
                _pdfRow('Periodo', widget.periodo),
                _pdfRow('Fecha / Hora', widget.fechaHora),
                _pdfRow('Caja Origen', widget.cajaOrigen.toUpperCase()),
                pw.SizedBox(height: 12),
                pw.Divider(),
                pw.SizedBox(height: 12),
                pw.Container(
                  padding: const pw.EdgeInsets.all(14),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue50,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Saldo Restante en Caja Origen',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue800,
                        ),
                      ),
                      pw.Text(
                        widget.saldoRestante,
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      final fileName =
          'comprobante_${widget.periodo.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comprobante guardado')),
      );
      await OpenFilex.open(file.path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al generar el comprobante: $e')),
      );
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
          pw.Text(value,
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.surface,
      appBar: AppBar(
        backgroundColor: TColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: TColors.textPrimary, size: 18),
          onPressed: () =>context.router.back(),
        ),
        centerTitle: true,
        title: const Text(
          'Confirmación',
          style: TextStyle(
            color: TColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: TColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_outline_rounded,
                      color: TColors.primary,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Pago registrado\nexitosamente',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: TColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'La transferencia de dividendos se ha\nprocesado correctamente.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: TColors.textSecondary,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: TColors.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: TColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: TColors.background,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(14)),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.receipt_long_outlined,
                                  color: TColors.textSecondary, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'DETALLES DE LA TRANSACCIÓN',
                                style: TextStyle(
                                  color: TColors.textPrimary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(height: 1, color: TColors.border),
                        _DetailRow(
                            label: 'Beneficiario', value: widget.beneficiario),
                        Divider(
                            height: 1,
                            color: TColors.border,
                            indent: 16,
                            endIndent: 16),
                        _DetailRow(
                            label: 'Monto Pagado', value: widget.montoPagado),
                        Divider(
                            height: 1,
                            color: TColors.border,
                            indent: 16,
                            endIndent: 16),
                        _DetailRow(label: 'Periodo', value: widget.periodo),
                        Divider(
                            height: 1,
                            color: TColors.border,
                            indent: 16,
                            endIndent: 16),
                        _DetailRow(label: 'Fecha/Hora', value: widget.fechaHora),
                        Divider(
                            height: 1,
                            color: TColors.border,
                            indent: 16,
                            endIndent: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Caja Origen',
                                style: TextStyle(
                                  color: TColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: TColors.border,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  widget.cajaOrigen.toUpperCase(),
                                  style: const TextStyle(
                                    color: TColors.textSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: TColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: TColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.account_balance_wallet_outlined,
                                color: TColors.primary, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Saldo Restante en Caja\nOrigen',
                              style: TextStyle(
                                color: TColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.saldoRestante,
                          style: const TextStyle(
                            color: TColors.textPrimary,
                            fontSize: 22,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _isGenerating ? null : _downloadComprobante,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.primary,
                      foregroundColor: TColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: _isGenerating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: TColors.white,
                            ),
                          )
                        : const Icon(Icons.download_outlined, size: 20),
                    label: Text(
                      _isGenerating ? 'Generando...' : 'Descargar Comprobante',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: TColors.textPrimary,
                      side: const BorderSide(color: TColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Volver',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
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

// ─── Fila de detalle ─────────────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: TColors.textSecondary,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: TColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}