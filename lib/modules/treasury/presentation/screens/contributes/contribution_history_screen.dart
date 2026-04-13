import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/core/widgets/excavator_loader.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/treasury/domain/entity/contributes/contribution_receipt_entity.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/bloc/treasury_bloc.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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
  ) => _query.isEmpty
      ? all
      : all
            .where(
              (r) => r.memberName.toLowerCase().contains(_query.toLowerCase()),
            )
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
        backgroundColor: TColors.appBackgroundColor,
        appBar: AppBar(
          backgroundColor: TColors.lightContainerAccount,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: TColors.appMainTextColor,
              size: 22,
            ),
            onPressed: () => context.router.back(),
          ),
          title: const Text(
            'Historial de Recibos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: TColors.appMainTextColor,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<TreasuryBloc, TreasuryState>(
          buildWhen: (_, state) =>
              state is ContributionReceiptsLoading ||
              state is ContributionReceiptsLoaded ||
              state is ContributionReceiptsError,
          builder: (context, state) {
            if (state is ContributionReceiptsLoading) {
              return const Center(child: ExcavatorLoader());
            }
            if (state is ContributionReceiptsError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: TColors.appSecondaryTextColor,
                  ),
                ),
              );
            }
            if (state is ContributionReceiptsLoaded) {
              final lista = _filtered(state.receipts);
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: TColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: TColors.appSurfaceColor),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) => setState(() => _query = v),
                        style: const TextStyle(
                          fontSize: 14,
                          color: TColors.appMainTextColor,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Buscar socio por nombre...',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: TColors.appSecondaryTextColor,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: TColors.appSecondaryTextColor,
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),

                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: lista.isEmpty
                        ? const Center(
                            child: Text(
                              'No se encontraron resultados.',
                              style: TextStyle(
                                fontSize: 14,
                                color: TColors.appSecondaryTextColor,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                            itemCount: lista.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (_, i) => ReciboCard(item: lista[i]),
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
    TColors.appMainColor,
    Color(0xFFD97706),
    Color(0xFF7C3AED),
    TColors.green,
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
                style: pw.TextStyle(
                    fontSize: 12, fontWeight: pw.FontWeight.bold)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final int idx = item.memberName.codeUnitAt(0) % _bgColors.length;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TColors.lightContainerAccount,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TColors.appSurfaceColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:  0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                    fontWeight: FontWeight.w700,
                    color: _fgColors[idx],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.memberName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: TColors.appMainTextColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.referenceCode,
                      style: const TextStyle(
                        fontSize: 12,
                        color: TColors.appSecondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: TColors.green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Pagado',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: TColors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          DetalleRow(label: 'Referencia:', value: item.referenceCode),
          const SizedBox(height: 4),
          DetalleRow(label: 'Fecha de pago:', value: _formattedDate),
          const SizedBox(height: 4),
          DetalleRow(
            label: 'Monto:',
            value: '${item.amount.toStringAsFixed(2)} Bs',
            valueColor: TColors.appMainColor,
            valueBold: true,
          ),
          Divider(color: TColors.appSurfaceColor),
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
 
  const ActionBtn({super.key, 
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });
 
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: filled
              ? TColors.appMainColor.withValues(alpha: 0.08)
              : TColors.appBackgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: TColors.appSurfaceColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: filled
                  ? TColors.appMainColor
                  : TColors.appMainTextColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: filled
                    ? TColors.appMainColor
                    : TColors.appMainTextColor,
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

  const DetalleRow({super.key, 
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
          style: const TextStyle(
            fontSize: 13,
            color: TColors.appSecondaryTextColor,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: valueBold ? FontWeight.w700 : FontWeight.w400,
            color: valueColor ?? TColors.appMainTextColor,
          ),
        ),
      ],
    );
  }
}
