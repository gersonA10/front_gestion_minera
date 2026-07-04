import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/widgets/custom_date_selector.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/staff_ui.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:intl/intl.dart';

import '../../../domain/entity/entity.dart';
import '../../bloc/treasury_bloc.dart';
import '../../widgets/widgtes.dart';

enum LoteStatus { disponible, parcial, agotado }

// ─── Formatters compartidos ───────────────────────────────────────────────────
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
class GoldDashboardScreen extends StatefulWidget {
  const GoldDashboardScreen({super.key});

  @override
  State<GoldDashboardScreen> createState() => _GoldDashboardScreenState();
}

class _GoldDashboardScreenState extends State<GoldDashboardScreen> {
  //Guardar datos en cache
  GoldInventoryEntity? _cachedInventory;
  List<GoldBatchEntity>? _cachedBatches;
  bool _cachedHasReachedMax = false;

  int _selectedFilter = 0;
  int _selectedNav = 0;

  final List<String> _filters = ['Todos', 'Disponible', 'Parcial', 'Agotado'];

  final ScrollController _scrollController = ScrollController();

  late final TreasuryBloc _treasuryBloc;

  bool _fabVisible = true;
  double _lastScrollOffset = 0;
  static const double _scrollThreshold = 10.0;

  String _formatDate(DateTime date) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  @override
  void initState() {
    super.initState();
    _treasuryBloc = InjectorContainer.getIt<TreasuryBloc>()
      ..add(FetchGoldDashboardDataEvent());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final current = _scrollController.position.pixels;
    final diff = current - _lastScrollOffset;

    if (diff > _scrollThreshold && _fabVisible) {
      setState(() => _fabVisible = false);
    } else if (diff < -_scrollThreshold && !_fabVisible) {
      setState(() => _fabVisible = true);
    }

    _lastScrollOffset = current;

    if (current >= _scrollController.position.maxScrollExtent - 200) {
      _treasuryBloc.add(LoadMoreGoldBatchesEvent());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _treasuryBloc,
      child: Scaffold(
        backgroundColor: TColors.background,
        body: SafeArea(
          child: _selectedNav == 0 ? _buildInicio() : _buildHistorial(),
        ),
        floatingActionButton: ScrollAwareFabs(
          visible: _fabVisible,
          onAddTap: () async {
            await context.router.push(NewExtractionRoute());
            if (context.mounted) {
              _treasuryBloc.add(FetchGoldDashboardDataEvent());
            }
          },
          onMoneyTap: () async {
            await context.router.push(RegisterSellRoute());
            if (context.mounted) {
              _treasuryBloc.add(FetchGoldDashboardDataEvent());
            }
          },
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildInicio() {
    return BlocBuilder<TreasuryBloc, TreasuryState>(
      buildWhen: (previous, current) =>
          current is GoldDashboardLoading ||
          current is GoldDashboardLoaded ||
          current is GoldDashboardError,
      builder: (context, state) {
        if (state is GoldDashboardLoaded) {
          _cachedInventory = state.inventory;
          _cachedBatches = state.batches;
          _cachedHasReachedMax = state.hasReachedMax;
        }

        final bool isLoading = state is GoldDashboardLoading;

        if (_cachedInventory == null) {
          if (isLoading) {
            return const StaffLoader();
          }
          if (state is GoldDashboardError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox();
        }

        final inventory = _cachedInventory!;
        final batches = _cachedBatches!;
        final hasReachedMax = _cachedHasReachedMax;

        return Column(
          children: [
            AppBarDashboardGoldWidget(context: context),
            Expanded(
              child: Stack(
                children: [
                  RefreshIndicator(
                    color: TColors.primary,
                    onRefresh: () async {
                      String? currentStatus;
                      if (_selectedFilter == 1) currentStatus = 'Disponible';
                      if (_selectedFilter == 2) currentStatus = 'Parcial';
                      if (_selectedFilter == 3) currentStatus = 'Agotado';

                      context.read<TreasuryBloc>().add(
                        FetchGoldDashboardDataEvent(
                          isRefresh: true,
                          status: currentStatus,
                        ),
                      );

                      await context.read<TreasuryBloc>().stream.firstWhere(
                        (state) =>
                            state is GoldDashboardLoaded ||
                            state is GoldDashboardError,
                      );
                    },
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          ValueEstimateWidget(
                            estimateValue: inventory.estimateValue,
                            totalGramsVault: inventory.totalGramsVault,
                          ),
                          const SizedBox(height: 16),
                          _buildFilterTabs(),
                          const SizedBox(height: 20),
                          const Text(
                            'LOTES',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: TColors.textSecondary,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...batches.map((lote) => _buildLoteCard(lote)),
                          if (batches.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 48),
                              child: _GoldEmptyState(
                                icon: Icons.inventory_2_outlined,
                                title: 'No hay lotes con este estado',
                                subtitle: 'Prueba con otro filtro o registra una extracción',
                              ),
                            ),
                          if (!hasReachedMax && batches.isNotEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: StaffLoader(),
                              ),
                            ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                  if (isLoading)
                    const Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(color: TColors.primary),
                    ),
                  if (isLoading)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          color: TColors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHistorial() {
    return HistoryWidget(
      context: context,
      onFabVisibilityChanged: (isvible) {
        setState(() {
          _fabVisible = isvible;
        });
      },
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: TColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TColors.border),
      ),
      child: Row(
        children: List.generate(_filters.length, (index) {
          final selected = _selectedFilter == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedFilter = index);
                String? statusFilter;
                if (index == 1) statusFilter = 'Disponible';
                if (index == 2) statusFilter = 'Parcial';
                if (index == 3) statusFilter = 'Agotado';
                _treasuryBloc.add(
                  FetchGoldDashboardDataEvent(
                    isRefresh: true,
                    status: statusFilter,
                  ),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: selected ? TColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  _filters[index],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? TColors.white : TColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLoteCard(GoldBatchEntity lote) {
    final statusColor = _statusColor(lote.status);

    double disponibilidadPorcentaje = 0.0;
    if (lote.originalWeight > 0) {
      disponibilidadPorcentaje = lote.avilableWeight / lote.originalWeight;
    }

    return GestureDetector(
      onTap: () {
        context.router.push(BatchDetailRoute(batchId: lote.batchId));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildStatusBadge(lote.status, statusColor),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      lote.batchCode,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: TColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(lote.extractionDate),
                    style: const TextStyle(
                      fontSize: 11,
                      color: TColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: TColors.border),
              const SizedBox(height: 14),
              Row(
                children: [
                  _buildStatCol(
                    'PESO ORIG.',
                    _formatGrams(lote.originalWeight),
                    TColors.textPrimary,
                  ),
                  const SizedBox(width: 20),
                  _buildStatCol(
                    'DISPONIBLE',
                    _formatGrams(lote.avilableWeight),
                    statusColor,
                  ),
                  const SizedBox(width: 20),
                  _buildStatCol(
                    'PUREZA',
                    '${lote.purity}%',
                    TColors.textPrimary,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: disponibilidadPorcentaje.clamp(0.0, 1.0),
                        backgroundColor: TColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${(disponibilidadPorcentaje * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCol(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: TColors.textSecondary,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {
        'icon': Icons.home_outlined,
        'activeIcon': Icons.home,
        'label': 'Inicio',
      },
      {
        'icon': Icons.history_outlined,
        'activeIcon': Icons.history,
        'label': 'Historial',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: TColors.surface,
        boxShadow: [
          BoxShadow(
            color: TColors.textPrimary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(items.length, (index) {
              final selected = _selectedNav == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedNav = index),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        selected
                            ? items[index]['activeIcon'] as IconData
                            : items[index]['icon'] as IconData,
                        size: 24,
                        color: selected
                            ? TColors.primary
                            : TColors.textSecondary,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        items[index]['label'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                          color: selected
                              ? TColors.primary
                              : TColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Disponible':
        return TColors.success;
      case 'Parcial':
        return TColors.warning;
      case 'Agotado':
      default:
        return TColors.textSecondary;
    }
  }
}

// ─── Estado vacío reutilizable ────────────────────────────────────────────────
class _GoldEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _GoldEmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: TColors.background,
              shape: BoxShape.circle,
              border: Border.all(color: TColors.border),
            ),
            child: Icon(icon, size: 30, color: TColors.textSecondary),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: TColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: TColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Vista Historial ──────────────────────────────────────────────────────────
class HistoryWidget extends StatefulWidget {
  const HistoryWidget({
    super.key,
    required this.context,
    required this.onFabVisibilityChanged,
  });

  final BuildContext context;
  final void Function(bool) onFabVisibilityChanged;
  @override
  State<HistoryWidget> createState() => _HistoryWidgetState();
}

class _HistoryWidgetState extends State<HistoryWidget> {
  late final TreasuryBloc treasuryBloc;
  final ScrollController _scrollController = ScrollController();

  bool _fabVisible = true;
  double _lastScrollOffset = 0;
  bool _isFiltering = false;

  static const double _scrollThreshold = 10.0;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);

    treasuryBloc = context.read<TreasuryBloc>()..add(FetchHistorySalesEvent());
  }

  void _onScroll() {
    final current = _scrollController.position.pixels;
    final diff = current - _lastScrollOffset;

    bool newFabVisible = _fabVisible;

    if (diff > _scrollThreshold) {
      newFabVisible = false;
    } else if (diff < -_scrollThreshold) {
      setState(() => newFabVisible = true);
    }

    if (newFabVisible != _fabVisible) {
      setState(() => _fabVisible = newFabVisible);
      widget.onFabVisibilityChanged.call(newFabVisible);
    }
    _lastScrollOffset = current;

    if (current >= _scrollController.position.maxScrollExtent - 200) {
      treasuryBloc.add(LoadMoreHistorySalesEvent());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  StatsSaleHistoryEntity? _cachedStatsSales;
  List<SaleHistoryEntity>? _cachedSales;
  bool _cachedHasReachedSalesMax = false;

  String _selectedFilterDate = "Reciente";
  String? _periodToFetch;
  String? _exactDateToFetch;

  List<SaleHistoryEntity> _applyFilter(List<SaleHistoryEntity> items) {
    final date = DateTime.parse(_exactDateToFetch ?? DateTime.now().toString());
    switch (_periodToFetch) {
      case 'day':
        return items
            .where(
              (t) =>
                  t.fecha.year == date.year &&
                  t.fecha.month == date.month &&
                  t.fecha.day == date.day,
            )
            .toList();
      case 'month':
        return items
            .where(
              (t) => t.fecha.year == date.year && t.fecha.month == date.month,
            )
            .toList();
      case 'year':
        return items.where((t) => t.fecha.year == date.year).toList();
      default:
        return items;
    }
  }

  String _dateview(SaleHistoryEntity item) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    return '${item.fecha.day} ${months[item.fecha.month - 1]} ${item.fecha.year}';
  }

  Future<void> _selectCustomDate() async {
    final result = await CustomDateSelector.show(context);

    if (result != null) {
      setState(() {
        _isFiltering = true;
        _selectedFilterDate = result.displayTitle;
        _periodToFetch = result.period;
        _exactDateToFetch = result.exactDate;

        _cachedSales = [];
        _cachedHasReachedSalesMax = true;
      });
      treasuryBloc.add(FetchHistorySalesEvent(isRefresh: true));
    }
  }

  void _clearFilter() {
    setState(() {
      _isFiltering = true;
      _exactDateToFetch = null;
      _periodToFetch = null;
      _selectedFilterDate = 'Reciente';

      _cachedSales = [];
      _cachedHasReachedSalesMax = true;
    });

    treasuryBloc.add(FetchHistorySalesEvent(isRefresh: true));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TreasuryBloc, TreasuryState>(
      listener: (context, state) {
        if (state is RegistersaleGetSucces) {
          context.router.push(
            SellSummaryRoute(saleData: state.data, isFromHistory: true),
          );
        }
      },
      child: BlocBuilder<TreasuryBloc, TreasuryState>(
        buildWhen: (previous, current) =>
            current is SalesGoldHistoryLoading ||
            current is SalesGoldHistoryLoaded ||
            current is SalesGoldHistoryError,
        builder: (context, state) {
          if (state is SalesGoldHistoryLoaded) {
            _isFiltering = false;
            _cachedStatsSales = state.stats;
            _cachedSales = state.sales;
            _cachedHasReachedSalesMax = state.hasReachedMax;
          }

          final bool isLoading = state is SalesGoldHistoryLoading;

          if (_cachedStatsSales == null) {
            if (isLoading) {
              return const StaffLoader();
            }
            if (state is SalesGoldHistoryError) {
              return Center(child: Text(state.message));
            }
          }
          final statSales = _cachedStatsSales;
          final hasCache = (_cachedSales ?? []).isNotEmpty;

          final sales = isLoading && !hasCache
              ? <SaleHistoryEntity>[]
              : _applyFilter(_cachedSales ?? []);

          if (!isLoading &&
              !_isFiltering &&
              sales.isEmpty &&
              !(_cachedHasReachedSalesMax)) {
            treasuryBloc.add(LoadMoreHistorySalesEvent());
          }
          final hashReachedMax = sales.isEmpty
              ? true
              : _cachedHasReachedSalesMax;

          return Column(
            children: [
              AppBarDashboardGoldWidget(context: context),
              Expanded(
                child: Stack(
                  children: [
                    RefreshIndicator(
                      color: TColors.primary,
                      onRefresh: () async {
                        context.read<TreasuryBloc>().add(
                          FetchHistorySalesEvent(isRefresh: true),
                        );

                        await treasuryBloc.stream.firstWhere(
                          (state) =>
                              state is SalesGoldHistoryLoaded ||
                              state is SalesGoldHistoryError,
                        );
                      },
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            // ── Tarjetas de estadísticas ──────────────
                            SizedBox(
                              height: 116,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                children: [
                                  _HistoryStatCard(
                                    icon: Icons.calendar_month_outlined,
                                    label: 'Vendido este mes',
                                    value: _formatGrams(
                                      statSales?.vendidoEsteMesG ?? 0,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  _HistoryStatCard(
                                    icon: Icons.bar_chart_rounded,
                                    label: 'Vendido este año',
                                    value: _formatGrams(
                                      statSales?.vendidoDelAnioG ?? 0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            // ── Encabezado de transacciones ───────────
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  const Text(
                                    'Transacciones',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: TColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: TColors.primaryLight,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _selectedFilterDate,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: TColors.primary,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  if (_selectedFilterDate != 'Reciente')
                                    _HistoryIconButton(
                                      icon: Icons.close_rounded,
                                      onTap: _clearFilter,
                                    ),
                                  if (_selectedFilterDate != 'Reciente')
                                    const SizedBox(width: 8),
                                  _HistoryIconButton(
                                    icon: Icons.tune_rounded,
                                    onTap: _selectCustomDate,
                                  ),
                                ],
                              ),
                            ),
                            // ── Lista de transacciones ────────────────
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: MediaQuery.of(context).size.height,
                              ),
                              child: Column(
                                children: [
                                  if (sales.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 120),
                                      child:
                                          state is SalesGoldHistoryLoading
                                          ? const StaffLoader()
                                          : const _GoldEmptyState(
                                              icon: Icons.receipt_long_outlined,
                                              title: 'No hay transacciones',
                                              subtitle:
                                                  'Intenta con otro filtro de fecha',
                                            ),
                                    ),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.fromLTRB(
                                      16, 4, 16, 16,
                                    ),
                                    itemCount:
                                        sales.length +
                                        (hashReachedMax ? 0 : 1),
                                    itemBuilder: (context, index) {
                                      if (index >= sales.length) {
                                        return const Padding(
                                          padding: EdgeInsets.all(16),
                                          child: StaffLoader(),
                                        );
                                      }
                                      final item = sales[index];
                                      return _SaleTransactionCard(
                                        item: item,
                                        dateLabel: _dateview(item),
                                        onTapDetail: () {
                                          treasuryBloc.add(
                                            GetSaleDetailEvent(
                                              idSale: item.saleId,
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isLoading)
                      const Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: LinearProgressIndicator(color: TColors.primary),
                      ),
                    if (isLoading)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Container(
                            color: TColors.background.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Tarjeta de estadística (historial) ───────────────────────────────────────
class _HistoryStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _HistoryStatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TColors.border),
        boxShadow: [
          BoxShadow(
            color: TColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: TColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: TColors.primary, size: 16),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: TColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: TColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HistoryIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: TColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: TColors.border),
        ),
        child: Icon(icon, size: 18, color: TColors.textSecondary),
      ),
    );
  }
}

// ─── Tarjeta de transacción (historial) ───────────────────────────────────────
class _SaleTransactionCard extends StatelessWidget {
  final SaleHistoryEntity item;
  final String dateLabel;
  final VoidCallback onTapDetail;

  const _SaleTransactionCard({
    required this.item,
    required this.dateLabel,
    required this.onTapDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TColors.border),
        boxShadow: [
          BoxShadow(
            color: TColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: TColors.successLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  color: TColors.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Venta ${item.saleCode}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: TColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateLabel,
                      style: const TextStyle(
                        color: TColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: TColors.successLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: TColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      item.estado,
                      style: const TextStyle(
                        color: TColors.success,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: TColors.border),
          const SizedBox(height: 12),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PESO TOTAL',
                    style: TextStyle(
                      color: TColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatGrams(item.pesoTotalG),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: TColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'MONTO TOTAL',
                    style: TextStyle(
                      color: TColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatCurrency(item.montoTotalBs),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: TColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: TColors.border),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.storefront_outlined,
                size: 16,
                color: TColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.comprador,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: TColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onTapDetail,
                child: const Row(
                  children: [
                    Text(
                      'Ver detalle',
                      style: TextStyle(
                        color: TColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 11,
                      color: TColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Tarjeta hero: Valor estimado + Bóveda ────────────────────────────────────
class ValueEstimateWidget extends StatelessWidget {
  final double estimateValue;
  final double totalGramsVault;

  const ValueEstimateWidget({
    super.key,
    required this.estimateValue,
    required this.totalGramsVault,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Valor estimado (hero con gradiente sutil) ──
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [TColors.vaultGradientStart, TColors.vaultGradientEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: TColors.vaultGradientStart.withValues(alpha: 0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: TColors.goldAccent.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.diamond_outlined,
                        size: 15,
                        color: TColors.goldAccent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'VALOR ESTIMADO',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _formatCurrency(estimateValue),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // ── Bóveda (card blanca plana) ──
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: TColors.border),
              boxShadow: [
                BoxShadow(
                  color: TColors.textPrimary.withValues(alpha: 0.04),
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
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: TColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.account_balance_outlined,
                        size: 15,
                        color: TColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'BÓVEDA',
                        style: TextStyle(
                          color: TColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _formatGrams(totalGramsVault),
                    style: const TextStyle(
                      color: TColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Total acumulado',
                  style: TextStyle(
                    color: TColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
        ],
      ),
    );
  }
}
