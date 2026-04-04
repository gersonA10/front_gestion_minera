import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import '../../../domain/entity/loans/payment_process_entity.dart';

@RoutePage()
class PaymentSuccessScreen extends StatefulWidget {
  final PayTheFeeResponseEntity paymentData;
  const PaymentSuccessScreen({super.key, required this.paymentData});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  bool _isSaving = false;
  bool _isSharing = false;

  Future<List<int>> _buildPdfBytes() async {
    final pdf = pw.Document();
    final data = widget.paymentData;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(
              'RECIBO DE PAGO',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Gestión Minera',
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 24),
            pw.Divider(),
            pw.SizedBox(height: 16),
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    'MONTO PAGADO',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    data.montoPagado.toStringAsFixed(2),
                    style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),
            pw.Divider(),
            pw.SizedBox(height: 16),
            _pdfRow('Referencia', data.referencia),
            pw.SizedBox(height: 10),
            _pdfRow('Fecha / Hora', data.fechaHora),
            pw.SizedBox(height: 10),
            _pdfRow('Caja afectada', data.cajaAfectada),
            pw.SizedBox(height: 10),
            _pdfRow('ID Transacción', data.transactionId),
            pw.SizedBox(height: 24),
            pw.Divider(),
            pw.SizedBox(height: 12),
            pw.Text(
              'Pago procesado correctamente.',
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
              ),
            ),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  pw.Widget _pdfRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  Future<void> _shareReceipt() async {
    setState(() => _isSharing = true);
    try {
      final bytes = await _buildPdfBytes();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/recibo_pago_${widget.paymentData.referencia}.pdf');
      await file.writeAsBytes(bytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/pdf')],
          subject: 'Recibo de pago - ${widget.paymentData.referencia}',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al compartir: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  Future<void> _saveReceipt() async {
    setState(() => _isSaving = true);
    try {
      final bytes = await _buildPdfBytes();
      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'recibo_${widget.paymentData.referencia}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Recibo guardado correctamente'),
            backgroundColor: const Color(0xFF22C55E),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Abrir',
              textColor: Colors.black,
              onPressed: () => OpenFilex.open(file.path),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A150C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A150C),
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'CONFIRMACIÓN',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF22C55E).withValues(
                              alpha: 0.45,
                            ),
                            blurRadius: 40,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Pago registrado\ncon éxito',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'La transacción se ha procesado correctamente. Puedes revisar los detalles de tu pago o compartir el recibo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF86ABAB),
                        fontSize: 13.5,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C2010),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF1C4020),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'MONTO PAGADO',
                            style: TextStyle(
                              color: Color(0xFF86ABAB),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.paymentData.montoPagado.toStringAsFixed(2),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Divider(
                            color: Color(0xFF1C4020),
                            thickness: 1,
                            height: 1,
                          ),
                          const SizedBox(height: 16),
                          _DetailRow(
                            label: 'Referencia',
                            value: widget.paymentData.referencia,
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(
                            label: 'Fecha / Hora',
                            value: widget.paymentData.fechaHora,
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(
                            label: 'Caja afectada',
                            value: widget.paymentData.cajaAfectada,
                            valueBold: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom actions
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        context.router.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Salir',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ActionButton(
                        icon: Icons.share_outlined,
                        label: 'Compartir',
                        isLoading: _isSharing,
                        onTap: _isSharing ? null : _shareReceipt,
                      ),
                      const SizedBox(width: 32),
                      _ActionButton(
                        icon: Icons.download_outlined,
                        label: 'Guardar Recibo',
                        isLoading: _isSaving,
                        onTap: _isSaving ? null : _saveReceipt,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool valueBold;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF86ABAB), fontSize: 13),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: valueBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isLoading;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          if (isLoading)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF86ABAB),
              ),
            )
          else
            Icon(icon, color: const Color(0xFF86ABAB), size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF86ABAB),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
