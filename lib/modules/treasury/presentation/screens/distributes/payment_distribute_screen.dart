import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/widgets/excavator_loader.dart';
import 'package:front_gestion_minera/modules/treasury/domain/entity/distribute/receipt_entity.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/bloc/treasury_bloc.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

@RoutePage()
class PaymentSuccessDistributionScreen extends StatefulWidget {
  final TreasuryBloc bloc;
  final String receiptId;
  final bool isFromDetails;
  const PaymentSuccessDistributionScreen({super.key, required this.receiptId, required this.bloc, required this.isFromDetails});

  @override
  State<PaymentSuccessDistributionScreen> createState() =>
      _PaymentSuccessDistributionScreenState();
}

class _PaymentSuccessDistributionScreenState
    extends State<PaymentSuccessDistributionScreen> {
  bool _isGenerating = false;
  ReceiptResponseEneity? _receipt;

  @override
  void initState() {
    super.initState();
    widget.bloc.add(ReceiptEvent(transactionId:  widget.receiptId));
  }



  String _formatDate(DateTime date) =>
      DateFormat('dd/MM/yyyy HH:mm').format(date);

  Future<void> _downloadComprobante() async {
    final receipt = _receipt;
    if (receipt == null) return;

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
                    style: const pw.TextStyle(
                      fontSize: 11,
                      color: PdfColors.grey700,
                    ),
                  ),
                ),
                pw.SizedBox(height: 24),
                pw.Divider(),
                pw.SizedBox(height: 12),
                _pdfRow('Beneficiario', receipt.memberName),
                _pdfRow('Monto Pagado', receipt.paidAmount.toString()),
                _pdfRow('Periodo', receipt.period),
                _pdfRow('Fecha / Hora', _formatDate(receipt.paymentDate)),
                _pdfRow('Caja Origen', receipt.affectedCashbox.toUpperCase()),
                _pdfRow('Referencia', receipt.reference),
                pw.SizedBox(height: 12),
                pw.Divider(),
              ],
            );
          },
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      final fileName =
          'comprobante_${receipt.period.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Comprobante guardado')));
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
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.bloc,
      child: Scaffold(
        backgroundColor: TColors.surface,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: TColors.surface,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Confirmación',
            style: TextStyle(
              color: TColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SafeArea(
          child: BlocConsumer<TreasuryBloc, TreasuryState>(
            listenWhen: (_, curr) =>
                curr is ReceiptSuccess ||
                curr is ReceiptLoading ||
                curr is ReceiptError,
            listener: (context, state) {
              if (state is ReceiptSuccess) {
                setState(() => _receipt = state.data);
              }
            },
            buildWhen: (_, curr) =>
                curr is ReceiptLoading ||
                curr is ReceiptSuccess ||
                curr is ReceiptError,
            builder: (context, state) {
              if (_receipt != null) {
                final res = _receipt!;
                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 24,
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                color: TColors.successLight,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: const BoxDecoration(
                                    color: TColors.success,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    color: TColors.white,
                                    size: 34,
                                  ),
                                ),
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
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(14),
                                      ),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.receipt_long_outlined,
                                          color: TColors.textSecondary,
                                          size: 18,
                                        ),
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
                                    label: 'Beneficiario',
                                    value: res.memberName,
                                  ),
                                  Divider(
                                    height: 1,
                                    color: TColors.border,
                                    indent: 16,
                                    endIndent: 16,
                                  ),
                                  _DetailRow(
                                    label: 'Monto Pagado',
                                    value: res.paidAmount.toString(),
                                  ),
                                  Divider(
                                    height: 1,
                                    color: TColors.border,
                                    indent: 16,
                                    endIndent: 16,
                                  ),
                                  _DetailRow(
                                    label: 'Periodo',
                                    value: res.period,
                                  ),
                                  Divider(
                                    height: 1,
                                    color: TColors.border,
                                    indent: 16,
                                    endIndent: 16,
                                  ),
                                  _DetailRow(
                                    label: 'Fecha/Hora',
                                    value: _formatDate(res.paymentDate),
                                  ),
                                  Divider(
                                    height: 1,
                                    color: TColors.border,
                                    indent: 16,
                                    endIndent: 16,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: TColors.border,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            res.affectedCashbox.toUpperCase(),
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
                              onPressed: _isGenerating
                                  ? null
                                  : _downloadComprobante,
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
                                _isGenerating
                                    ? 'Generando...'
                                    : 'Descargar Comprobante',
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
                              onPressed: () {if (widget.isFromDetails) {
                                 context.router.back();
                                  context.router.back();
                              } else {
                                context.router.back();
                              }} ,
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
                );
              }
              if (state is ReceiptError) {
                return Center(
                  child: Text(
                    state.message,
                    style: const TextStyle(color: TColors.textSecondary),
                  ),
                );
              }
              return const Center(
                child: ExcavatorLoader()
              );
            },
          ),
        ),
      ),
    );
  }
}

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
            style: const TextStyle(color: TColors.textSecondary, fontSize: 13),
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
