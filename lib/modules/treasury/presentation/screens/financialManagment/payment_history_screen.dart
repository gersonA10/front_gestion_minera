import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/modules/treasury/domain/entity/payment_history_entity.dart';
import 'package:intl/intl.dart';

import '../../../../../injector_container.dart';
import '../../bloc/treasury_bloc.dart';
import '../../widgets/widgtes.dart';

// ─── Enums de filtro ──────────────────────────────────────────────────────────

enum DateFilterType { ultimos30Dias, dia, mes, anio }

extension DateFilterTypeExt on DateFilterType {
  String get label {
    switch (this) {
      case DateFilterType.ultimos30Dias:
        return 'Últimos 30 días';
      case DateFilterType.dia:
        return 'Día';
      case DateFilterType.mes:
        return 'Mes';
      case DateFilterType.anio:
        return 'Año';
    }
  }
}

// ─── Helpers de ícono por destino/tipo ────────────────────────────────────────

IconData iconForTransaction(String operationType, String destino) {
  if (operationType == 'INCOME') return Icons.arrow_downward_rounded;
  if (destino.toLowerCase().contains('chica')) return Icons.wallet_rounded;
  return Icons.account_balance_wallet_rounded;
}

Color iconColorForTransaction(String operationType, String destino) {
  if (operationType == 'INCOME') return const Color(0xFF10B981);
  if (destino.toLowerCase().contains('chica')) return const Color(0xFFF97316);
  return const Color(0xFF3B82F6);
}

Color iconBgForTransaction(String operationType, String destino) {
  if (operationType == 'INCOME') return const Color(0xFFD1FAE5);
  if (destino.toLowerCase().contains('chica')) return const Color(0xFFFFF7ED);
  return const Color(0xFFDBEAFE);
}

// ─── Pantalla principal ───────────────────────────────────────────────────────

@RoutePage()
class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InjectorContainer.getIt<TreasuryBloc>()
        ..add(GetPaymentHistoryEvent(isRefresh: true)),
      child: const _PaymentHistoryView(),
    );
  }
}

class _PaymentHistoryView extends StatefulWidget {
  const _PaymentHistoryView();

  @override
  State<_PaymentHistoryView> createState() => _PaymentHistoryViewState();
}

class _PaymentHistoryViewState extends State<_PaymentHistoryView> {
  DateFilterType _selectedFilter = DateFilterType.ultimos30Dias;
  DateTime? _selectedDay;
  int? _selectedMonth;
  int? _selectedYear;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<TreasuryBloc>().add(LoadMorePaymentHistoryEvent());
    }
  }

  List<PaymentHistoryItemEntity> _applyFilter(
    List<PaymentHistoryItemEntity> items,
  ) {
    switch (_selectedFilter) {
      case DateFilterType.ultimos30Dias:
        final cutoff = DateTime.now().subtract(const Duration(days: 30));
        return items.where((t) => t.fecha.isAfter(cutoff)).toList();
      case DateFilterType.dia:
        if (_selectedDay == null) return items;
        return items.where((t) =>
            t.fecha.year == _selectedDay!.year &&
            t.fecha.month == _selectedDay!.month &&
            t.fecha.day == _selectedDay!.day).toList();
      case DateFilterType.mes:
        if (_selectedMonth == null || _selectedYear == null) return items;
        return items.where((t) =>
            t.fecha.year == _selectedYear &&
            t.fecha.month == _selectedMonth).toList();
      case DateFilterType.anio:
        if (_selectedYear == null) return items;
        return items.where((t) => t.fecha.year == _selectedYear).toList();
    }
  }

  String get _filterDisplayText {
    switch (_selectedFilter) {
      case DateFilterType.ultimos30Dias:
        return 'Últimos 30 días';
      case DateFilterType.dia:
        if (_selectedDay != null) {
          return DateFormat('dd/MM/yyyy').format(_selectedDay!);
        }
        return 'Seleccionar día';
      case DateFilterType.mes:
        if (_selectedMonth != null && _selectedYear != null) {
          final monthName = DateFormat('MMMM', 'es')
              .format(DateTime(_selectedYear!, _selectedMonth!));
          return '${monthName[0].toUpperCase()}${monthName.substring(1)} $_selectedYear';
        }
        return 'Seleccionar mes';
      case DateFilterType.anio:
        if (_selectedYear != null) return '$_selectedYear';
        return 'Seleccionar año';
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FilterBottomSheet(
        currentFilter: _selectedFilter,
        selectedDay: _selectedDay,
        selectedMonth: _selectedMonth,
        selectedYear: _selectedYear,
        onApply: (filter, {DateTime? day, int? month, int? year}) {
          setState(() {
            _selectedFilter = filter;
            _selectedDay = day;
            _selectedMonth = month;
            _selectedYear = year;
          });
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  Map<String, List<PaymentHistoryItemEntity>> _groupByDate(
    List<PaymentHistoryItemEntity> items,
  ) {
    final map = <String, List<PaymentHistoryItemEntity>>{};
    for (final t in items) {
      final key = DateFormat('yyyy-MM-dd').format(t.fecha);
      map.putIfAbsent(key, () => []).add(t);
    }
    return map;
  }

  String _dateGroupLabel(String key) {
    final date = DateTime.parse(key);
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Hoy';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Ayer';
    }
    return DateFormat('dd MMM yyyy', 'es').format(date);
  }

  String _dateGroupSubtitle(String key) {
    final date = DateTime.parse(key);
    return DateFormat("d 'de' MMM", 'es').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: BlocBuilder<TreasuryBloc, TreasuryState>(
        buildWhen: (_, state) =>
            state is PaymentHistoryLoading ||
            state is PaymentHistoryLoaded ||
            state is PaymentHistoryError,
        builder: (context, state) {
          if (state is PaymentHistoryLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
            );
          }

          if (state is PaymentHistoryError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 56, color: Color(0xFFD1D5DB)),
                  const SizedBox(height: 12),
                  Text(
                    state.message,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context
                        .read<TreasuryBloc>()
                        .add(GetPaymentHistoryEvent(isRefresh: true)),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is PaymentHistoryLoaded) {
            final filtered = _applyFilter(state.items);
            final grouped = _groupByDate(filtered);
            final sortedKeys = grouped.keys.toList()
              ..sort((a, b) => b.compareTo(a));
            final totalFiltered =
                filtered.fold<double>(0, (sum, t) => sum + t.monto);

            return RefreshIndicator(
              color: const Color(0xFF3B82F6),
              onRefresh: () async {
                context
                    .read<TreasuryBloc>()
                    .add(GetPaymentHistoryEvent(isRefresh: true));
              },
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // ── Tarjetas resumen ─────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: SummaryCard(
                              icon: Icons.account_balance_wallet_rounded,
                              iconColor: const Color(0xFF3B82F6),
                              iconBg: const Color(0xFFDBEAFE),
                              label: 'TOTAL HOY',
                              value: _formatCurrency( state.summary.totalMontoHoy),
                              isHighlighted: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SummaryCard(
                              icon: Icons.receipt_long_rounded,
                              iconColor: const Color(0xFF6B7280),
                              iconBg: const Color(0xFFF3F4F6),
                              label: 'TRANSACCIONES HOY',
                              value:
                                  '${state.summary.totalTransaccionesHoy}',
                              isHighlighted: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Filtro de fecha ──────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: _showFilterBottomSheet,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                    color: const Color(0xFFE5E7EB)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Fecha: $_filterDisplayText',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF374151),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 18,
                                      color: Color(0xFF6B7280)),
                                ],
                              ),
                            ),
                          ),
                          Text(
                            '${filtered.length} de ${state.totalRecords}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Resumen monto filtrado ───────────────────────
                  if (filtered.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: Text(
                          'Total filtrado: ${_formatCurrency(totalFiltered)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3B82F6),
                          ),
                        ),
                      ),
                    ),

                  // ── Lista de transacciones agrupadas ─────────────
                  if (sortedKeys.isEmpty)
                    const SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.inbox_rounded,
                                size: 56, color: Color(0xFFD1D5DB)),
                            SizedBox(height: 12),
                            Text(
                              'No hay transacciones',
                              style: TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Intenta con otro filtro de fecha',
                              style: TextStyle(
                                color: Color(0xFFD1D5DB),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...sortedKeys.map((dateKey) {
                      final txns = grouped[dateKey]!;
                      return SliverMainAxisGroup(slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(16, 20, 16, 8),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _dateGroupLabel(dateKey),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                                Text(
                                  _dateGroupSubtitle(dateKey),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF3B82F6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverList.separated(
                            itemCount: txns.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (_, i) =>TransactionTile(item: txns[i]),
                          ),
                        ),
                      ]);
                    }),

                  if (!state.hasReachedMax)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF3B82F6),
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '${formatter.format(value)} Bs';
  }
}