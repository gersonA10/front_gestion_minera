import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/widgets/excavator_loader.dart';
import 'package:front_gestion_minera/core/widgets/zoomable_evidence_image.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/widgets/batch_details/batch_details_widgets.dart';
import 'package:intl/intl.dart';

import '../../../domain/entity/entity.dart';
import '../../bloc/treasury_bloc.dart';

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
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
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
    if (pct == 0) return const Color(0xFF22C55E);
    if (pct < 100) return const Color(0xFFF59E0B);
    return const Color(0xFF6B7280);
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
          color: Color(0xFF0F172A),
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      );
    }
    final data = (state as BatchLotDetailsLoaded).lotDetails;
    return Column(
      children: [
        Text(
          'Lote #${data.batchCode}',
          style: const TextStyle(
            color: Color(0xFF0F172A),
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
              decoration: BoxDecoration(
                color: _statusColor(data.progresoConsumoPct),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              _statusLabel(data.progresoConsumoPct),
              style: TextStyle(
                color: _statusColor(data.progresoConsumoPct),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
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
            const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 48),
            const SizedBox(height: 12),
            Text(
              (state as BatchLotDetailsError).message,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context
                  .read<TreasuryBloc>()
                  .add(BatchLotDetailsEvent(batchId: batchId)),
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

  @override
  Widget build(BuildContext context) {
    final pct = (data.progresoConsumoPct / 100.0).clamp(0.0, 1.0);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
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
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.device_hub_outlined,
                          color: Color(0xFF2563EB),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'REFERENCIA DE INVENTARIO',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Lote ID: ${data.batchCode}',
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Progreso de Consumo',
                        style: TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${data.progresoConsumoPct}%',
                        style: const TextStyle(
                          color: Color(0xFF2563EB),
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
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF2563EB),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Vendido: ${data.pesoVendido}g',
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Restante: ${data.pesoDisponible}g',
                        style: const TextStyle(
                          color: Color(0xFF2563EB),
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
                          label: 'INICIAL', value: '${data.pesoInicial}g'),
                      const SizedBox(width: 10),
                      StatBox(
                          label: 'VENDIDO', value: '${data.pesoVendido}g'),
                      const SizedBox(width: 10),
                      StatBox(
                        label: 'DISPONIBLE',
                        value: '${data.pesoDisponible}g',
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  ExtractionDetail(
                    icon: Icons.calendar_today_outlined,
                    label: 'FECHA',
                    value: _formatDate(data.detallesExtraccion.fecha),
                  ),
                  const SizedBox(width: 32),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (data.evidenciaUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
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
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: Color(0xFF94A3B8),
                        size: 28,
                      ),
                    ),
                  const SizedBox(height: 12),
                  const Text(
                    'OBSERVACIONES ORIGINALES',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data.observaciones.isNotEmpty
                        ? data.observaciones
                        : 'Sin observaciones.',
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SectionTitle(title: 'HISTORIAL DE MOVIMIENTOS'),
            const SizedBox(height: 10),
            ...data.historialMovimientos.asMap().entries.map((entry) {
              final i = entry.key;
              final mov = entry.value;
              final isFirst = i == 0;
              final isLast = i == data.historialMovimientos.length - 1;
              final isIngreso = mov.monto.startsWith('+');
              return MovementItem(
                icon: isFirst ? Icons.add_circle : Icons.sell_outlined,
                iconColor: isFirst
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF64748B),
                iconBg: isFirst
                    ? const Color(0xFFEFF6FF)
                    : const Color(0xFFF1F5F9),
                title: mov.tipo,
                date: _formatDate(mov.fecha),
                amount: mov.monto,
                amountColor: isIngreso
                    ? const Color(0xFF22C55E)
                    : const Color(0xFFEF4444),
                isFirst: isFirst,
                isLast: isLast,
              );
            }),
            const SizedBox(height: 20),
            const SectionTitle(title: 'RESUMEN FINANCIERO'),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFDBEAFE)),
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
                              color: Color(0xFF94A3B8),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Bs ${data.resumenFinanciero.totalVendidoBs.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Color(0xFF2563EB),
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
                              color: Color(0xFF94A3B8),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${data.resumenFinanciero.ventasTotales}',
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(height: 1, color: const Color(0xFFE2E8F0)),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PRECIO PROMEDIO / GRAMO',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Bs ${data.resumenFinanciero.precioPromedio.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
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
