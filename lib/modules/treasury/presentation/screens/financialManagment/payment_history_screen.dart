import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/staff_ui.dart';
import 'package:front_gestion_minera/modules/treasury/domain/entity/payment_history_entity.dart';
import 'package:intl/intl.dart';

import '../../../../../injector_container.dart';
import '../../bloc/treasury_bloc.dart';
import '../../widgets/widgtes.dart';

class _C {
  static const primary = Color(0xFF1A56FF);
  static const background = Color(0xFFF5F7FB);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF0D1B3E);
  static const textSecondary = Color(0xFF6B7A99);
  static const border = Color(0xFFE8EDF5);
}

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

  // Caché visual para no perder la lista durante recargas.
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

  String _money(double value) =>
      'Bs ${NumberFormat('#,##0.00', 'en_US').format(value)}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.background,
      body: SafeArea(
        child: BlocBuilder<TreasuryBloc, TreasuryState>(
          buildWhen: (_, state) =>
              state is PaymentHistoryLoading ||
              state is PaymentHistoryLoaded ||
              state is PaymentHistoryError,
          builder: (context, state) {
            final isLoading = state is PaymentHistoryLoading;

            if (state is PaymentHistoryLoaded) {
              _cachedItems = state.items;
              _cachedSummary = state.summary;
              _cachedTotalRecords = state.totalRecords;
              _cachedHasReachedMax = state.hasReachedMax;
            }

            if (_cachedItems == null || _cachedSummary == null) {
              if (isLoading) {
                return const StaffLoader();
              }
              if (state is PaymentHistoryError) {
                return _ErrorView(
                  message: state.message,
                  onRetry: () => context
                      .read<TreasuryBloc>()
                      .add(GetPaymentHistoryEvent(isRefresh: true)),
                );
              }
              return const SizedBox.shrink();
            }

            final grouped = _groupByDate(_cachedItems!);
            final sortedKeys = grouped.keys.toList()
              ..sort((a, b) => b.compareTo(a));

            return Stack(
              children: [
                RefreshIndicator(
                  color: _C.primary,
                  onRefresh: () async {
                    context
                        .read<TreasuryBloc>()
                        .add(GetPaymentHistoryEvent(isRefresh: true));
                  },
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: Row(
                            children: [
                              Expanded(
                                child: SummaryCard(
                                  icon: Icons.payments_rounded,
                                  iconColor: _C.primary,
                                  iconBg: _C.primary.withValues(alpha: 0.12),
                                  label: 'Egresos de hoy',
                                  value: _money(_cachedSummary!.totalMontoHoy),
                                  isHighlighted: true,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SummaryCard(
                                  icon: Icons.receipt_long_rounded,
                                  iconColor: _C.textSecondary,
                                  iconBg: const Color(0xFFEDEFF4),
                                  label: 'Transacciones de hoy',
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
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: _showFilterBottomSheet,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 9),
                                  decoration: BoxDecoration(
                                    color: _C.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: _C.border),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.calendar_today_rounded,
                                          size: 14, color: _C.primary),
                                      const SizedBox(width: 7),
                                      Text(
                                        _filterDisplayText,
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                          color: _C.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          size: 18,
                                          color: _C.textSecondary),
                                    ],
                                  ),
                                ),
                              ),
                              Text(
                                '${_cachedItems!.length} de $_cachedTotalRecords',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: _C.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (sortedKeys.isEmpty)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: _EmptyView(),
                        )
                      else
                        ...sortedKeys.map((dateKey) {
                          final txns = grouped[dateKey]!;
                          return SliverMainAxisGroup(slivers: [
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 18, 16, 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _dateGroupLabel(dateKey),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: _C.textPrimary,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    Text(
                                      _dateGroupSubtitle(dateKey),
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: _C.primary,
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
                                separatorBuilder: (context, index) =>
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
                            child: StaffLoader(),
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
                    child: LinearProgressIndicator(
                      minHeight: 2.5,
                      color: _C.primary,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                if (isLoading)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        color: _C.background.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: _C.primary.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.inbox_rounded,
                size: 44, color: _C.primary.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay transacciones',
            style: TextStyle(
              color: _C.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Prueba con otro filtro de fecha.',
            style: TextStyle(color: _C.textSecondary, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: const Color(0xFFD32F2F).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_off_rounded,
                  size: 44, color: Color(0xFFD32F2F)),
            ),
            const SizedBox(height: 16),
            const Text(
              'No pudimos cargar el historial',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _C.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12.5, color: _C.textSecondary),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: const Text('Reintentar',
                  style: TextStyle(
                      color: _C.primary, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
