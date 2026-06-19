import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/widgets/custom_date_selector.dart';
import 'package:front_gestion_minera/core/widgets/excavator_loader.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/partners/presentation/bloc/partners_bloc.dart';

import '../../domain/entity/entity.dart';

class _IncomeColors {
  static const primary = Color(0xFF1A56FF);
  static const primaryDeep = Color(0xFF0B33B8);
  static const gold = Color(0xFFEFC805);
  static const goldDeep = Color(0xFFB8930A);
  static const green = Color(0xFF17A05D);
  static const amber = Color(0xFFC47A00);
  static const background = Color(0xFFF5F7FB);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF0D1B3E);
  static const textSecondary = Color(0xFF6B7A99);
  static const border = Color(0xFFE8EDF5);
}

@RoutePage()
class DistributesScreen extends StatefulWidget {
  const DistributesScreen({super.key});

  @override
  State<DistributesScreen> createState() => _DistributesScreenState();
}

class _DistributesScreenState extends State<DistributesScreen> {
  late final PartnersBloc _bloc;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  String _selectedFilter = "Todo";
  final List<String> _statusFilters = ["Todo", "Pagados", "Pendientes"];

  String? _exactDateToFetch;
  String? _periodToFetch;
  String? _customDateTitle;

  DistributesMetricsEntity? _currentMetrics;
  Map<String, List<DistributesHistoryEntity>>? _currentHistory;

  @override
  void initState() {
    super.initState();
    _bloc = InjectorContainer.getIt<PartnersBloc>()
      ..add(FetchDistributesDataEvent());

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _bloc.add(LoadMoreDistributesEvent());
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _fetchData() {
    String? status;
    String? period;

    if (_selectedFilter == "Pagados") status = 'pagado';
    if (_selectedFilter == "Pendientes") status = 'pendiente';
    if (_selectedFilter == "Este mes") {
      period = 'month';
    } else if (_selectedFilter == "Personalizado") {
      period = _periodToFetch;
    }

    _bloc.add(
      FetchDistributesDataEvent(
        status: status,
        search: _searchController.text.trim(),
        period: period,
        exactDate: _selectedFilter == "Personalizado" ? _exactDateToFetch : null,
        isRefresh: true,
      ),
    );
  }

  void _onSelectStatus(String filter) {
    _searchFocusNode.unfocus();
    setState(() {
      _selectedFilter = filter;
      _periodToFetch = null;
      _exactDateToFetch = null;
      _customDateTitle = null;
    });
    _fetchData();
  }

  void _onTapThisMonth() {
    _searchFocusNode.unfocus();
    final bool wasActive = _selectedFilter == "Este mes";
    setState(() {
      _selectedFilter = wasActive ? "Todo" : "Este mes";
      _periodToFetch = null;
      _exactDateToFetch = null;
      _customDateTitle = null;
    });
    _fetchData();
  }

  Future<void> _selectCustomDate() async {
    final result = await CustomDateSelector.show(context);
    if (result != null) {
      setState(() {
        _selectedFilter = "Personalizado";
        _periodToFetch = result.period;
        _exactDateToFetch = result.exactDate;
        _customDateTitle = result.displayTitle;
      });
      _fetchData();
    }
  }

  void _clearCustomDate() {
    setState(() {
      _selectedFilter = "Todo";
      _periodToFetch = null;
      _exactDateToFetch = null;
      _customDateTitle = null;
    });
    _fetchData();
  }

  void _performSearch() {
    _searchFocusNode.unfocus();
    _fetchData();
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _IncomeColors.background,
      body: Column(
        children: [
          _IncomeHeader(onBack: () => Navigator.of(context).maybePop()),
          _SearchField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onSubmitted: (_) => _performSearch(),
            onSearchTap: _performSearch,
            onClear: _clearSearch,
          ),
          _FilterBar(
            statusFilters: _statusFilters,
            selectedFilter: _selectedFilter,
            customDateTitle: _customDateTitle,
            onSelectStatus: _onSelectStatus,
            onTapThisMonth: _onTapThisMonth,
            onTapDate: _selectCustomDate,
            onClearDate: _clearCustomDate,
          ),
          Expanded(
            child: BlocConsumer<PartnersBloc, PartnersState>(
              bloc: _bloc,
              listener: (context, state) {
                if (state is DistributesDataLoaded) {
                  _currentMetrics = state.metrics;
                  _currentHistory = state.groupedHistory;
                }
              },
              builder: (context, state) {
                final isLoading = state is DistributesDataLoading;
                final hasData =
                    _currentMetrics != null && _currentHistory != null;

                if (isLoading && !hasData) {
                  return const Center(child: ExcavatorLoader());
                }

                if (state is DistributesDataError && !hasData) {
                  return _ErrorState(message: state.message);
                }

                if (hasData) {
                  final isFetchingMore =
                      state is DistributesDataLoaded && !state.hasReachedMax;
                  return _buildHistoryContent(isLoading, isFetchingMore);
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryContent(bool isLoading, bool isFetchingMore) {
    final history = _currentHistory!;
    return RefreshIndicator(
      color: _IncomeColors.primary,
      onRefresh: () async => _fetchData(),
      child: Stack(
        children: [
          ListView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              _SummaryCard(metrics: _currentMetrics!),
              const SizedBox(height: 20),
              if (history.isEmpty)
                _EmptyState(filter: _selectedFilter)
              else
                ...history.entries.map(
                  (entry) =>
                      _DateGroup(label: entry.key, items: entry.value),
                ),
              if (isFetchingMore && !isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: ExcavatorLoader()),
                ),
            ],
          ),
          if (isLoading) ...[
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                minHeight: 2.5,
                color: _IncomeColors.primary,
                backgroundColor: Colors.transparent,
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: _IncomeColors.background.withValues(alpha: 0.4),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Header gradiente ────────────────────────────────────────────────────────

class _IncomeHeader extends StatelessWidget {
  final VoidCallback onBack;
  const _IncomeHeader({required this.onBack});

  Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_IncomeColors.primary, _IncomeColors.primaryDeep],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -24,
            child: _circle(120, Colors.white.withValues(alpha: 0.08)),
          ),
          Positioned(
            top: 30,
            right: 40,
            child: _circle(60, _IncomeColors.gold.withValues(alpha: 0.18)),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _GlassIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: onBack,
                      ),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'Historial de Ingresos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      'Consulta tus ingresos distribuidos, filtra por estado o por fecha.',
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.35,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
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

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

// ─── Búsqueda ────────────────────────────────────────────────────────────────

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onSearchTap;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
    required this.onSearchTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: _IncomeColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _IncomeColors.border),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            const Icon(
              Icons.search_rounded,
              size: 20,
              color: _IncomeColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                textInputAction: TextInputAction.search,
                onSubmitted: onSubmitted,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: _IncomeColors.textPrimary,
                ),
                decoration: const InputDecoration(
                  isCollapsed: true,
                  filled: false,
                  fillColor: Colors.transparent,
                  hintText: 'Buscar por detalle',
                  hintStyle: TextStyle(
                    fontSize: 13.5,
                    color: _IncomeColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                if (value.text.isEmpty) return const SizedBox.shrink();
                return GestureDetector(
                  onTap: onClear,
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: _IncomeColors.textSecondary,
                    ),
                  ),
                );
              },
            ),
            GestureDetector(
              onTap: onSearchTap,
              child: Container(
                margin: const EdgeInsets.all(6),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_IncomeColors.primary, _IncomeColors.primaryDeep],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Barra de filtros (estado + fecha) ───────────────────────────────────────

class _FilterBar extends StatelessWidget {
  final List<String> statusFilters;
  final String selectedFilter;
  final String? customDateTitle;
  final ValueChanged<String> onSelectStatus;
  final VoidCallback onTapThisMonth;
  final VoidCallback onTapDate;
  final VoidCallback onClearDate;

  const _FilterBar({
    required this.statusFilters,
    required this.selectedFilter,
    required this.customDateTitle,
    required this.onSelectStatus,
    required this.onTapThisMonth,
    required this.onTapDate,
    required this.onClearDate,
  });

  @override
  Widget build(BuildContext context) {
    final bool customActive = selectedFilter == "Personalizado";
    final bool monthActive = selectedFilter == "Este mes";

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _DateChip(
            active: customActive,
            title: customActive ? (customDateTitle ?? 'Fecha') : 'Fecha',
            onTap: onTapDate,
            onClear: customActive ? onClearDate : null,
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'Este mes',
            active: monthActive,
            onTap: onTapThisMonth,
          ),
          const SizedBox(width: 8),
          ...statusFilters.map((f) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _Chip(
                label: f,
                active: selectedFilter == f,
                onTap: () => onSelectStatus(f),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_IncomeColors.primary, _IncomeColors.primaryDeep],
                )
              : null,
          color: active ? null : _IncomeColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? Colors.transparent : _IncomeColors.border,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: _IncomeColors.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : _IncomeColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Chip especial para el filtro de fecha: ícono de calendario, periodo
/// seleccionado en dorado y una "X" para limpiarlo rápidamente.
class _DateChip extends StatelessWidget {
  final bool active;
  final String title;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _DateChip({
    required this.active,
    required this.title,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        alignment: Alignment.center,
        padding: EdgeInsets.only(left: 14, right: active ? 8 : 14),
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_IncomeColors.gold, _IncomeColors.goldDeep],
                )
              : null,
          color: active ? null : _IncomeColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? Colors.transparent : _IncomeColors.border,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: _IncomeColors.gold.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 14,
              color: active ? Colors.white : _IncomeColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : _IncomeColors.textSecondary,
              ),
            ),
            if (active && onClear != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onClear,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Tarjeta resumen ─────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final DistributesMetricsEntity metrics;
  const _SummaryCard({required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_IncomeColors.primary, _IncomeColors.primaryDeep],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _IncomeColors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 19,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Total Distribuido',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Bs ${metrics.totalDistribuido.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _MetricPill(
                  icon: Icons.check_circle_rounded,
                  label: 'COMPLETADO',
                  value: 'Bs ${metrics.totalPagado.toStringAsFixed(2)}',
                  valueColor: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricPill(
                  icon: Icons.hourglass_top_rounded,
                  label: 'PENDIENTE',
                  value: 'Bs ${metrics.totalPendiente.toStringAsFixed(2)}',
                  valueColor: const Color(0xFFFFD54F),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  const _MetricPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: Colors.white.withValues(alpha: 0.8)),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 9,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Grupo por fecha ─────────────────────────────────────────────────────────

class _DateGroup extends StatelessWidget {
  final String label;
  final List<DistributesHistoryEntity> items;

  const _DateGroup({required this.label, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _IncomeColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _IncomeColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${items.length} ${items.length == 1 ? 'registro' : 'registros'}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _IncomeColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...items.map((item) => _IncomeCard(item: item)),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ─── Tarjeta de ingreso ──────────────────────────────────────────────────────

class _IncomeCard extends StatelessWidget {
  final DistributesHistoryEntity item;
  const _IncomeCard({required this.item});

  static const _months = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
  ];

  String get _dateStr =>
      '${item.registeredDate.day.toString().padLeft(2, '0')} ${_months[item.registeredDate.month - 1]}, ${item.registeredDate.year}';

  @override
  Widget build(BuildContext context) {
    final bool isPaid = item.status.toLowerCase() == 'pagado';
    final Color statusColor =
        isPaid ? _IncomeColors.green : _IncomeColors.amber;
    final Color statusBg =
        isPaid ? const Color(0xFFE7F7EE) : const Color(0xFFFFF4E5);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _IncomeColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _IncomeColors.border),
        boxShadow: [
          BoxShadow(
            color: _IncomeColors.textPrimary.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  isPaid
                      ? Icons.payments_rounded
                      : Icons.pending_actions_rounded,
                  color: statusColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: _IncomeColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 12,
                          color: _IncomeColors.textSecondary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _dateStr,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: _IncomeColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPaid
                          ? Icons.check_circle_rounded
                          : Icons.hourglass_top_rounded,
                      size: 13,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isPaid ? 'Pagado' : 'Pendiente',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: _IncomeColors.border),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Monto recibido',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: _IncomeColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                'Bs ${item.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _IncomeColors.primary,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Estados vacío / error ───────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String filter;
  const _EmptyState({required this.filter});

  String get _message {
    switch (filter) {
      case 'Pagados':
        return 'No tienes ingresos pagados';
      case 'Pendientes':
        return 'No tienes ingresos pendientes';
      case 'Este mes':
        return 'Sin ingresos este mes';
      case 'Personalizado':
        return 'Sin ingresos en esta fecha';
      default:
        return 'Aún no tienes ingresos';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: _IncomeColors.primary.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inbox_rounded,
                size: 44,
                color: _IncomeColors.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _IncomeColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Aquí aparecerán tus ingresos distribuidos.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: _IncomeColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

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
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 44,
                color: Color(0xFFD32F2F),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No pudimos cargar los ingresos',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _IncomeColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                color: _IncomeColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
