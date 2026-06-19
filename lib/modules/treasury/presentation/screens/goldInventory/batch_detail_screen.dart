import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/widgets/excavator_loader.dart';
import 'package:front_gestion_minera/core/widgets/zoomable_evidence_image.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/widgets/batch_details/batch_details_widgets.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:intl/intl.dart';

import '../../../domain/entity/entity.dart';
import '../../bloc/treasury_bloc.dart';

String _formatCurrency(double value) => NumberFormat.currency(
      locale: 'es_BO',
      symbol: 'Bs',
      decimalDigits: 2,
    ).format(value);

String _formatGrams(double value) {
  final formatter = NumberFormat.decimalPatternDigits(
    locale: 'es_BO',
    decimalDigits: value == value.roundToDouble() ? 0 : 2,
  );
  return '${formatter.format(value)} g';
}

@RoutePage()
class BatchDetailScreen extends StatelessWidget {
  final String batchId;
  const BatchDetailScreen({super.key, required this.batchId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InjectorContainer.getIt<TreasuryBloc>()
        ..add(BatchLotDetailsEvent(batchId: batchId)),
      child: BlocBuilder<TreasuryBloc, TreasuryState>(
        builder: (context, state) => Scaffold(
          backgroundColor: TColors.background,
          appBar: AppBar(
            backgroundColor: TColors.surface,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: TColors.textPrimary,
                size: 18,
              ),
              onPressed: () => context.router.back(),
            ),
            title: _AppBarTitle(state: state),
          ),
          body: _Body(state: state, batchId: batchId),
        ),
      ),
    );
  }
}

// ─── AppBar title ───

class _AppBarTitle extends StatelessWidget {
  final TreasuryState state;
  const _AppBarTitle({required this.state});

  Color _statusColor(int pct) {
    if (pct == 0) return TColors.success;
    if (pct < 100) return TColors.warning;
    return TColors.textSecondary;
  }

  String _statusLabel(int pct) {
    if (pct == 0) return 'DISPONIBLE';
    if (pct < 100) return 'PARCIAL';
    return 'AGOTADO';
  }

  @override
  Widget build(BuildContext context) {
    if (state is! BatchLotDetailsLoaded) {
      return const Text(
        'Detalle de Lote',
        style: TextStyle(
          color: TColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      );
    }
    final data = (state as BatchLotDetailsLoaded).lotDetails;
    final color = _statusColor(data.progresoConsumoPct);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Lote #${data.batchCode}',
          style: const TextStyle(
            color: TColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            Text(
              _statusLabel(data.progresoConsumoPct),
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Body extends StatelessWidget {
  final TreasuryState state;
  final String batchId;
  const _Body({required this.state, required this.batchId});

  @override
  Widget build(BuildContext context) {
    if (state is BatchLotDetailsLoading) {
      return const Center(child: ExcavatorLoader());
    }
    if (state is BatchLotDetailsError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: TColors.danger, size: 48),
            const SizedBox(height: 12),
            Text(
              (state as BatchLotDetailsError).message,
              style: const TextStyle(color: TColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context
                  .read<TreasuryBloc>()
                  .add(BatchLotDetailsEvent(batchId: batchId)),
              style: TextButton.styleFrom(foregroundColor: TColors.primary),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }
    if (state is BatchLotDetailsLoaded) {
      return _Content(data: (state as BatchLotDetailsLoaded).lotDetails);
    }
    return const SizedBox.shrink();
  }
}

class _Content extends StatelessWidget {
  final LotDetailsDataEntity data;
  const _Content({required this.data});

  String _formatDate(DateTime date) =>
      DateFormat('dd MMM yyyy', 'es').format(date);

  Color get _statusColor {
    final pct = data.progresoConsumoPct;
    if (pct == 0) return TColors.success;
    if (pct < 100) return TColors.warning;
    return TColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    final pct = (data.progresoConsumoPct / 100.0).clamp(0.0, 1.0);
    final accent = _statusColor;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Progreso card ──────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: TColors.border),
                boxShadow: [
                  BoxShadow(
                    color: TColors.textPrimary.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: TColors.goldAccentLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.inventory_2_outlined,
                          color: TColors.goldAccent,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'REFERENCIA DE INVENTARIO',
                              style: TextStyle(
                                color: TColors.textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Lote ID: ${data.batchCode}',
                              style: const TextStyle(
                                color: TColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Progreso de consumo',
                        style: TextStyle(
                          color: TColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${data.progresoConsumoPct}%',
                        style: TextStyle(
                          color: accent,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 8,
                      backgroundColor: TColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(accent),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Vendido: ${_formatGrams(data.pesoVendido)}',
                        style: const TextStyle(
                          color: TColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Restante: ${_formatGrams(data.pesoDisponible)}',
                        style: TextStyle(
                          color: accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      StatBox(
                        label: 'INICIAL',
                        value: _formatGrams(data.pesoInicial),
                      ),
                      const SizedBox(width: 10),
                      StatBox(
                        label: 'VENDIDO',
                        value: _formatGrams(data.pesoVendido),
                      ),
                      const SizedBox(width: 10),
                      StatBox(
                        label: 'DISPONIBLE',
                        value: _formatGrams(data.pesoDisponible),
                        highlight: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SectionTitle(title: 'DETALLES DE EXTRACCIÓN'),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: TColors.border),
              ),
              child: Row(
                children: [
                  ExtractionDetail(
                    icon: Icons.calendar_today_outlined,
                    label: 'FECHA',
                    value: _formatDate(data.detallesExtraccion.fecha),
                  ),
                  const SizedBox(width: 16),
                  ExtractionDetail(
                    icon: Icons.person_outline,
                    label: 'RESPONSABLE',
                    value: data.detallesExtraccion.responsable,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SectionTitle(title: 'EVIDENCIA Y OBSERVACIONES'),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: TColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (data.evidenciaUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: double.infinity,
                        height: 160,
                        child: ZoomableEvidenceImage(
                          imageUrl: data.evidenciaUrl,
                          height: 250,
                          heroTag: 'evidencia_${data.batchCode}',
                        ),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      height: 80,
                      decoration: BoxDecoration(
                        color: TColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: TColors.border),
                      ),
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: TColors.textSecondary,
                        size: 28,
                      ),
                    ),
                  const SizedBox(height: 12),
                  const Text(
                    'OBSERVACIONES ORIGINALES',
                    style: TextStyle(
                      color: TColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data.observaciones.isNotEmpty
                        ? data.observaciones
                        : 'Sin observaciones.',
                    style: const TextStyle(
                      color: TColors.textPrimary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SectionTitle(title: 'HISTORIAL DE MOVIMIENTOS'),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: TColors.border),
              ),
              child: Column(
                children: [
                  ...data.historialMovimientos.asMap().entries.map((entry) {
                    final i = entry.key;
                    final mov = entry.value;
                    final isFirst = i == 0;
                    final isLast =
                        i == data.historialMovimientos.length - 1;
                    final isIngreso = mov.monto.startsWith('+');
                    return MovementItem(
                      icon: isFirst
                          ? Icons.add_circle_outline_rounded
                          : Icons.sell_outlined,
                      iconColor: isFirst ? TColors.primary : TColors.textSecondary,
                      iconBg:
                          isFirst ? TColors.primaryLight : TColors.background,
                      title: mov.tipo,
                      date: _formatDate(mov.fecha),
                      amount: mov.monto,
                      amountColor:
                          isIngreso ? TColors.success : TColors.danger,
                      isFirst: isFirst,
                      isLast: isLast,
                    );
                  }),
                  if (data.historialMovimientos.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Sin movimientos registrados.',
                        style: TextStyle(
                          color: TColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SectionTitle(title: 'RESUMEN FINANCIERO'),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TColors.primaryLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: TColors.primary.withValues(alpha: 0.12)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TOTAL VENDIDO',
                            style: TextStyle(
                              color: TColors.textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatCurrency(
                              data.resumenFinanciero.totalVendidoBs,
                            ),
                            style: const TextStyle(
                              color: TColors.primary,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'VENTAS TOTALES',
                            style: TextStyle(
                              color: TColors.textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${data.resumenFinanciero.ventasTotales}',
                            style: const TextStyle(
                              color: TColors.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(height: 1, color: TColors.border),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PRECIO PROMEDIO / GRAMO',
                          style: TextStyle(
                            color: TColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatCurrency(
                            data.resumenFinanciero.precioPromedio,
                          ),
                          style: const TextStyle(
                            color: TColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
