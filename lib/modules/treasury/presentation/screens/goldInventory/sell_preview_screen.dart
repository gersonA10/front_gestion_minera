import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/core/idempotency/gold_operation_key_store.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/treasury/domain/entity/entity.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/bloc/treasury_bloc.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:intl/intl.dart';

String _formatCurrency(double value) => NumberFormat.currency(
  locale: 'es_BO',
  symbol: 'Bs',
  decimalDigits: 2,
).format(value);

String _formatGrams(double value) {
  final formatter = NumberFormat.decimalPatternDigits(
    locale: 'es_BO',
    decimalDigits: 2,
  );
  return '${formatter.format(value)} g';
}

@RoutePage()
class SellPreviewScreen extends StatelessWidget {
  final SalePreviewResponseEntity previewData;
  final String salesDate;
  final String buyer;
  final double totalGramsSold;
  final double priceBsPerGram;
  final String comprobanteFilePath;

  const SellPreviewScreen({
    super.key,
    required this.previewData,
    required this.salesDate,
    required this.buyer,
    required this.totalGramsSold,
    required this.priceBsPerGram,
    required this.comprobanteFilePath,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InjectorContainer.getIt<TreasuryBloc>(),
      child: _SellPreviewBody(
        previewData: previewData,
        salesDate: salesDate,
        buyer: buyer,
        totalGramsSold: totalGramsSold,
        priceBsPerGram: priceBsPerGram,
        comprobanteFilePath: comprobanteFilePath,
      ),
    );
  }
}

class _SellPreviewBody extends StatefulWidget {
  final SalePreviewResponseEntity previewData;
  final String salesDate;
  final String buyer;
  final double totalGramsSold;
  final double priceBsPerGram;
  final String comprobanteFilePath;

  const _SellPreviewBody({
    required this.previewData,
    required this.salesDate,
    required this.buyer,
    required this.totalGramsSold,
    required this.priceBsPerGram,
    required this.comprobanteFilePath,
  });

  @override
  State<_SellPreviewBody> createState() => _SellPreviewBodyState();
}

class _SellPreviewBodyState extends State<_SellPreviewBody> {
  GoldOperationKeyStore? _operationKeyStore;
  String? _activeIdempotencyKey;
  bool _isConfirming = false;

  SalePreviewResponseEntity get previewData => widget.previewData;
  String get salesDate => widget.salesDate;
  String get buyer => widget.buyer;
  double get totalGramsSold => widget.totalGramsSold;
  double get priceBsPerGram => widget.priceBsPerGram;
  String get comprobanteFilePath => widget.comprobanteFilePath;

  double get _estimatedTotal => totalGramsSold * priceBsPerGram;

  Future<GoldOperationKeyStore> _getOperationKeyStore() async {
    return _operationKeyStore ??= await GoldOperationKeyStore.create();
  }

  Future<void> _confirm() async {
    if (_isConfirming) return;
    setState(() => _isConfirming = true);

    final fingerprint = GoldOperationFingerprint.sale(
      salesDate: salesDate,
      buyer: buyer,
      totalGramsSold: totalGramsSold,
      priceBsPerGram: priceBsPerGram,
    );
    final store = await _getOperationKeyStore();
    final idempotencyKey = await store.getOrCreate(
      type: GoldOperationType.sale,
      fingerprint: fingerprint,
    );
    if (!mounted) return;
    _activeIdempotencyKey = idempotencyKey;

    context.read<TreasuryBloc>().add(
      RegisterSaleEvent(
        request: RegisterSaleRequestEntity(
          salesDate: salesDate,
          buyer: buyer,
          totalGramsSold: totalGramsSold,
          priceBsPerGram: priceBsPerGram,
          comprobante: comprobanteFilePath,
          idempotencyKey: idempotencyKey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return BlocListener<TreasuryBloc, TreasuryState>(
      listener: (listenerContext, state) async {
        if (state is RegisterSaleLoaded) {
          final completedKey = _activeIdempotencyKey;
          if (completedKey != null) {
            await (await _getOperationKeyStore()).complete(completedKey);
          }
          if (!listenerContext.mounted) return;
          _activeIdempotencyKey = null;
          _isConfirming = false;
          listenerContext.router.replace(
            SellSummaryRoute(saleData: state.sale),
          );
        } else if (state is RegisterSaleError) {
          final failedKey = _activeIdempotencyKey;
          if (state.isConflict && failedKey != null) {
            await (await _getOperationKeyStore()).complete(failedKey);
            _activeIdempotencyKey = null;
          }
          if (!listenerContext.mounted) return;
          setState(() => _isConfirming = false);
          CustomAlert.show(
            listenerContext,
            title: state.isConflict
                ? 'Revisa la operación'
                : 'No se pudo confirmar',
            message: state.message,
            type: AlertType.error,
          );
        }
      },
      child: Scaffold(
        backgroundColor: TColors.background,
        appBar: _buildAppBar(context),
        body: BlocBuilder<TreasuryBloc, TreasuryState>(
          builder: (context, state) {
            final isLoading = state is RegisterSaleLoading || _isConfirming;
            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                // ── Info header ────────────────────────────────────
                _InfoBanner(),

                const SizedBox(height: 20),

                // ── Resumen de la venta ────────────────────────────
                _SectionTitle(text: 'Resumen de la Venta'),
                const SizedBox(height: 12),
                _SummaryCard(
                  buyer: buyer,
                  salesDate: salesDate,
                  totalGrams: totalGramsSold,
                  pricePerGram: priceBsPerGram,
                  total: _estimatedTotal,
                ),

                const SizedBox(height: 24),

                // ── Distribución FIFO ──────────────────────────────
                _SectionTitle(text: 'Distribución FIFO de Lotes'),
                const SizedBox(height: 4),
                Text(
                  '${previewData.distribucionLotes.length} lote(s) afectado(s)',
                  style: const TextStyle(
                    fontSize: 12,
                    color: TColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                ...previewData.distribucionLotes.map(
                  (lot) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _LotCard(lot: lot),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Confirm button ─────────────────────────────────
                _ConfirmButton(
                  isLoading: isLoading,
                  onTap: isLoading ? null : _confirm,
                ),
                if (isLoading) ...[
                  const SizedBox(height: 10),
                  const Text(
                    'Estamos confirmando la venta y actualizando Caja Mayor. No cierres esta pantalla.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: TColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: Container(
        color: TColors.surface,
        child: SafeArea(
          bottom: false,
          child: Container(
            height: 56,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: TColors.border)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => context.router.back(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: TColors.textPrimary,
                    ),
                  ),
                ),
                const Text(
                  'Vista Previa',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: TColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TColors.primaryLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TColors.primary.withValues(alpha: 0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: TColors.primary, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Revisa la distribución FIFO antes de confirmar. Esta operación no se puede deshacer.',
              style: TextStyle(
                fontSize: 12,
                color: TColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section title ────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: TColors.textPrimary,
        letterSpacing: -0.2,
      ),
    );
  }
}

// ─── Summary card ─────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final String buyer;
  final String salesDate;
  final double totalGrams;
  final double pricePerGram;
  final double total;

  const _SummaryCard({
    required this.buyer,
    required this.salesDate,
    required this.totalGrams,
    required this.pricePerGram,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TColors.border),
      ),
      child: Column(
        children: [
          _SummaryRow(label: 'Comprador', value: buyer),
          const Divider(color: TColors.border, height: 20),
          _SummaryRow(label: 'Fecha', value: salesDate),
          const Divider(color: TColors.border, height: 20),
          _SummaryRow(
            label: 'Gramos a vender',
            value: _formatGrams(totalGrams),
          ),
          const Divider(color: TColors.border, height: 20),
          _SummaryRow(
            label: 'Precio por gramo',
            value: _formatCurrency(pricePerGram),
          ),
          const Divider(color: TColors.border, height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total estimado',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: TColors.textPrimary,
                ),
              ),
              Text(
                _formatCurrency(total),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: TColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: TColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: TColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ─── Lot card ─────────────────────────────────────────────────────────────────
class _LotCard extends StatelessWidget {
  final SalePreviewBatchDistributionEntity lot;
  const _LotCard({required this.lot});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: TColors.primaryLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  lot.batchCode,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: TColors.primary,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: TColors.warningLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Pureza ${lot.pureza.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: TColors.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _LotStat(
                  label: 'Disponible antes',
                  value: _formatGrams(lot.disponibleAntes),
                ),
              ),
              Expanded(
                child: _LotStat(
                  label: 'A descontar',
                  value: _formatGrams(lot.gramosDescontados),
                  valueColor: TColors.primary,
                ),
              ),
              Expanded(
                child: _LotStat(
                  label: 'Restante',
                  value: _formatGrams(lot.restanteDespues),
                  valueColor: TColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LotStat extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _LotStat({
    required this.label,
    required this.value,
    this.valueColor = TColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: TColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

// ─── Confirm button ───────────────────────────────────────────────────────────
class _ConfirmButton extends StatefulWidget {
  final VoidCallback? onTap;
  final bool isLoading;
  const _ConfirmButton({required this.onTap, required this.isLoading});

  @override
  State<_ConfirmButton> createState() => _ConfirmButtonState();
}

class _ConfirmButtonState extends State<_ConfirmButton> {
  bool _pressing = false;

  @override
  Widget build(BuildContext context) {
    const color = TColors.success;
    return GestureDetector(
      onTapDown: widget.onTap != null
          ? (_) => setState(() => _pressing = true)
          : null,
      onTapUp: widget.onTap != null
          ? (_) {
              setState(() => _pressing = false);
              widget.onTap!();
            }
          : null,
      onTapCancel: () => setState(() => _pressing = false),
      child: AnimatedScale(
        scale: _pressing ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 54,
          width: double.infinity,
          decoration: BoxDecoration(
            color: color.withValues(alpha: widget.isLoading ? 0.6 : 1.0),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: widget.isLoading
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Confirmando venta…',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Confirmar Venta',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
