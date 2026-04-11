import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/modules/treasury/domain/entity/payment_history_entity.dart';
import 'package:intl/intl.dart';

import '../../../../../injector_container.dart';
import '../../bloc/treasury_bloc.dart';
import '../../widgets/widgtes.dart';

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

  // VARIABLES DE CACHÉ VISUAL 
  List<PaymentHistoryItemEntity>? _cachedItems;
  PaymentHistorySummaryEntity? _cachedSummary;
  int _cachedTotalRecords = 0;
  bool _cachedHasReachedMax = false;

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

          String apiPeriod = 'month';
          String? apiExactDate;

          switch (filter) {
            case DateFilterType.ultimos30Dias:
              apiPeriod = 'month';
              break;
            case DateFilterType.dia:
              apiPeriod = 'day';
              if (day != null) {
                apiExactDate = DateFormat('yyyy-MM-dd').format(day);
              }
              break;
            case DateFilterType.mes:
              apiPeriod = 'month';
              if (year != null && month != null) {
                final m = month.toString().padLeft(2, '0');
                apiExactDate = '$year-$m-01';
              }
              break;
            case DateFilterType.anio:
              apiPeriod = 'year';
              if (year != null) {
                apiExactDate = '$year-01-01';
              }
              break;
          }

          context.read<TreasuryBloc>().add(GetPaymentHistoryEvent(
                isRefresh: true,
                period: apiPeriod,
                exactDate: apiExactDate,
              ));

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
          bool isLoading = state is PaymentHistoryLoading;

          // Actualizamos la caché solo si los datos cargaron exitosamente
          if (state is PaymentHistoryLoaded) {
            _cachedItems = state.items;
            _cachedSummary = state.summary;
            _cachedTotalRecords = state.totalRecords;
            _cachedHasReachedMax = state.hasReachedMax;
          }

          // Si NO tenemos caché (es decir, es la primera vez que entramos a la pantalla)
          if (_cachedItems == null || _cachedSummary == null) {
            if (isLoading) {
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

            return const SizedBox.shrink();
          }

          //  Siempre usamos _cachedItems y _cachedSummary para pintar
          final grouped = _groupByDate(_cachedItems!);
          final sortedKeys = grouped.keys.toList()
            ..sort((a, b) => b.compareTo(a));

          final totalObtained =
              _cachedItems!.fold<double>(0, (sum, t) => sum + t.monto);

          return Stack(
            children: [
              RefreshIndicator(
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
                                value: _formatCurrency(
                                    _cachedSummary!.totalMontoHoy),
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
                                    '${_cachedSummary!.totalTransaccionesHoy}',
                                isHighlighted: false,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

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
                              '${_cachedItems!.length} de $_cachedTotalRecords',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (_cachedItems!.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: Text(
                            'Total listado: ${_formatCurrency(totalObtained)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                        ),
                      ),

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
                              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
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
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            sliver: SliverList.separated(
                              itemCount: txns.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (_, i) =>
                                  TransactionTile(item: txns[i]),
                            ),
                          ),
                        ]);
                      }),

                    if (!_cachedHasReachedMax)
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
              ),

              if (isLoading)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(color: Color(0xFF2563EB)),
                ),
              if (isLoading)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      color: const Color(0xFFF5F5F7).withValues(alpha: 0.5),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '${formatter.format(value)} Bs';
  }
}