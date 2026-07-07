import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/staff_ui.dart';
import 'package:front_gestion_minera/modules/treasury/domain/entity/contributes/contribution_receipt_entity.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/bloc/treasury_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'contributes_ui.dart';

@RoutePage()
class ReceiptsHistoryScreen extends StatefulWidget {
  final String contributionId;
  const ReceiptsHistoryScreen({super.key, required this.contributionId});

  @override
  State<ReceiptsHistoryScreen> createState() => _ReceiptsHistoryScreenState();
}

class _ReceiptsHistoryScreenState extends State<ReceiptsHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  late final TreasuryBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = InjectorContainer.getIt<TreasuryBloc>()
      ..add(
        GetContributionReceiptsEvent(contributionId: widget.contributionId),
      );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ContributionReceiptEntity> _filtered(
    List<ContributionReceiptEntity> all,
  ) =>
      _query.isEmpty
          ? all
          : all
              .where((r) =>
                  r.memberName.toLowerCase().contains(_query.toLowerCase()))
              .toList();

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) context.router.back();
        },
        child: Scaffold(
          backgroundColor: CUi.bg,
          appBar: contribAppBar(context, title: 'Historial de Recibos'),
          body: BlocBuilder<TreasuryBloc, TreasuryState>(
            buildWhen: (_, state) =>
                state is ContributionReceiptsLoading ||
                state is ContributionReceiptsLoaded ||
                state is ContributionReceiptsError,
            builder: (context, state) {
              if (state is ContributionReceiptsLoading) {
                return const Center(child: StaffLoader(),);
              }
              if (state is ContributionReceiptsError) {
                return CStateView(
                  icon: Icons.cloud_off_rounded,
                  color: CUi.danger,
                  title: 'No pudimos cargar los recibos',
                  subtitle: state.message,
                );
              }
              if (state is ContributionReceiptsLoaded) {
                final lista = _filtered(state.receipts);
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: CUi.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: CUi.border),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (v) => setState(() => _query = v),
                          textAlignVertical: TextAlignVertical.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: CUi.textPrimary,
                          ),
                          decoration: const InputDecoration(
                            isDense: true,
                            hintText: 'Buscar socio por nombre...',
                            hintStyle: TextStyle(
                              fontSize: 13.5,
                              color: CUi.muted,
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: CUi.muted,
                              size: 20,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: lista.isEmpty
                          ? const CStateView(
                              icon: Icons.receipt_long_outlined,
                              color: CUi.primary,
                              title: 'Sin recibos',
                              subtitle: 'No se encontraron resultados.',
                            )
                          : ListView.separated(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 6, 16, 24),
                              itemCount: lista.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (_, i) =>
                                  ReciboCard(item: lista[i]),
                            ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

class ReciboCard extends StatelessWidget {
  final ContributionReceiptEntity item;

  const ReciboCard({super.key, required this.item});

  static const List<Color> _bgColors = [
    Color(0xFFDDE8FF),
    Color(0xFFFFEDD5),
    Color(0xFFEDE9FE),
    Color(0xFFDCFCE7),
  ];
  static const List<Color> _fgColors = [
    CUi.primary,
    Color(0xFFD97706),
    Color(0xFF7C3AED),
    CUi.success,
  ];

  String get _initials {
    final parts = item.memberName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }

  String get _formattedDate {
    try {
      final dt = DateTime.parse(item.payDate).toLocal();
      return DateFormat('dd MMM, yyyy', 'es').format(dt);
    } catch (_) {
      return item.payDate;
    }
  }

  Future<void> _generarPdf(BuildContext context) async {
    final formattedDate = _formattedDate;
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(
                'RECIBO DE PAGO',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Center(
              child: pw.Text(
                'Cooperativa Minera',
                style: pw.TextStyle(fontSize: 13, color: PdfColors.grey600),
              ),
            ),
            pw.SizedBox(height: 24),
            pw.Divider(),
            pw.SizedBox(height: 16),
            _pdfRow('Socio', item.memberName),
            _pdfRow('Referencia', item.referenceCode),
            _pdfRow('Fecha de pago', formattedDate),
            pw.SizedBox(height: 16),
            pw.Divider(),
            pw.SizedBox(height: 16),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'MONTO PAGADO',
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Bs ${item.amount.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green700,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 24),
            pw.Divider(),
            pw.SizedBox(height: 12),
            pw.Center(
              child: pw.Text(
                'Estado: PAGADO',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.green700,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) async => doc.save(),
      name: 'recibo_${item.referenceCode}.pdf',
    );
  }

  pw.Widget _pdfRow(String label, String value) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 10),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label,
                style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
            pw.Text(value,
                style:
                    pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00', 'es_PE');
    final int idx = item.memberName.codeUnitAt(0) % _bgColors.length;
    return CCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: _bgColors[idx],
                child: Text(
                  _initials,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _fgColors[idx],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.memberName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: CUi.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.referenceCode,
                      style: const TextStyle(
                        fontSize: 12,
                        color: CUi.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const CPill(
                label: 'Pagado',
                color: CUi.success,
                bg: CUi.successBg,
                icon: Icons.check_circle_rounded,
              ),
            ],
          ),
          const SizedBox(height: 12),
          DetalleRow(label: 'Fecha de pago', value: _formattedDate),
          const SizedBox(height: 6),
          DetalleRow(
            label: 'Monto',
            value: '${fmt.format(item.amount)} Bs',
            valueColor: CUi.primary,
            valueBold: true,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: CUi.border, height: 1),
          ),
          Row(
            children: [
              Expanded(
                child: ActionBtn(
                  icon: Icons.visibility_outlined,
                  label: 'Ver',
                  onTap: () => context.router.push(
                    PaymentConfirmationRoute(
                      transactionId: item.detailId,
                      screen: false,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ActionBtn(
                  icon: Icons.download_outlined,
                  label: 'PDF',
                  onTap: () => _generarPdf(context),
                  filled: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  const ActionBtn({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final fg = filled ? CUi.primary : CUi.textPrimary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: filled ? CUi.primarySoft : CUi.bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: filled ? CUi.primary.withValues(alpha: 0.25) : CUi.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetalleRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool valueBold;

  const DetalleRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.valueBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: CUi.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: valueBold ? FontWeight.w800 : FontWeight.w500,
            color: valueColor ?? CUi.textPrimary,
          ),
        ),
      ],
    );
  }
}
