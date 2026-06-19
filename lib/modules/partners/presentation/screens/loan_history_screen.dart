import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/core/widgets/excavator_loader.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/partners/domain/entity/loan_histori_entity.dart';
import 'package:front_gestion_minera/modules/partners/domain/entity/loan_metrics_entity.dart';
import 'package:front_gestion_minera/modules/partners/presentation/bloc/partners_bloc.dart';
import 'package:front_gestion_minera/utils/date_util.dart';

class _LoanColors {
  static const primary = Color(0xFF1A56FF);
  static const primaryDeep = Color(0xFF0B33B8);
  static const gold = Color(0xFFEFC805);
  static const background = Color(0xFFF5F7FB);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF0D1B3E);
  static const textSecondary = Color(0xFF6B7A99);
  static const border = Color(0xFFE8EDF5);
}

String _fmt(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

/// Filtros: la etiqueta visible y el `status` que viaja al backend.
const _filters = <_FilterDef>[
  _FilterDef('Todos', null),
  _FilterDef('En revisión', 'pendiente'),
  _FilterDef('Vigente', 'aprobado'),
  _FilterDef('Pagado', 'pagado'),
  _FilterDef('Rechazado', 'rechazado'),
  _FilterDef('Cancelado', 'cancelado'),
];

class _FilterDef {
  final String label;
  final String? status;
  const _FilterDef(this.label, this.status);
}

@RoutePage()
class LoanHistoryScreen extends StatefulWidget {
  const LoanHistoryScreen({super.key});

  @override
  State<LoanHistoryScreen> createState() => _LoanHistoryScreenState();
}

class _LoanHistoryScreenState extends State<LoanHistoryScreen> {
  late final PartnersBloc _bloc;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  String _activeFilter = 'Todos';

  LoanMetricsEntity? _metrics;
  List<LoanHistoryDataEntity> _items = const [];
  bool _hasReachedMax = false;

  @override
  void initState() {
    super.initState();
    _bloc = InjectorContainer.getIt<PartnersBloc>()..add(LoanHistoryFetchEvent());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_hasReachedMax) _bloc.add(LoanHistoryLoadMoreEvent());
    }
  }

  String? get _statusQuery =>
      _filters.firstWhere((f) => f.label == _activeFilter).status;

  void _fetch() {
    final search = _searchController.text.trim();
    _bloc.add(
      LoanHistoryFetchEvent(
        status: _statusQuery,
        search: search.isEmpty ? null : search,
      ),
    );
  }

  void _onSelectFilter(String label) {
    _searchFocusNode.unfocus();
    _searchController.clear();
    setState(() => _activeFilter = label);
    _fetch();
  }

  void _performSearch() {
    _searchFocusNode.unfocus();
    _fetch();
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _LoanColors.background,
      body: Column(
        children: [
          _Header(onBack: () => Navigator.of(context).maybePop()),
          _SearchField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onSubmitted: (_) => _performSearch(),
            onSearchTap: _performSearch,
            onClear: _clearSearch,
          ),
          _FilterBar(active: _activeFilter, onTap: _onSelectFilter),
          Expanded(
            child: BlocBuilder<PartnersBloc, PartnersState>(
              bloc: _bloc,
              builder: (context, state) {
                final bool isLoading = state is LoanHistoryLoading;
                if (state is LoanHistoryLoaded) {
                  _metrics = state.metrics;
                  _items = state.items;
                  _hasReachedMax = state.hasReachedMax;
                }

                final bool hasData = _metrics != null;
                if (!hasData) {
                  if (isLoading) {
                    return const Center(child: ExcavatorLoader());
                  }
                  if (state is LoanHistoryError) {
                    return _ErrorState(message: state.message);
                  }
                  return const SizedBox.shrink();
                }

                return Stack(
                  children: [
                    RefreshIndicator(
                      color: _LoanColors.primary,
                      onRefresh: () async => _fetch(),
                      child: ListView(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          _MetricsCard(metrics: _metrics!),
                          const SizedBox(height: 18),
                          if (_items.isEmpty)
                            _EmptyState(filter: _activeFilter)
                          else ...[
                            ..._items.map(
                              (e) => _LoanCard(
                                item: e,
                                onTap: () => context.router.push(
                                  MemberLoanDetailRoute(loanId: e.loanId),
                                ),
                              ),
                            ),
                            if (!_hasReachedMax)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: _LoanColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                    if (isLoading) ...[
                      const Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: LinearProgressIndicator(
                          minHeight: 2.5,
                          color: _LoanColors.primary,
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Container(
                            color: _LoanColors.background.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final VoidCallback onBack;
  const _Header({required this.onBack});

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
          colors: [_LoanColors.primary, _LoanColors.primaryDeep],
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
            top: 26,
            right: 36,
            child: _circle(64, _LoanColors.gold.withValues(alpha: 0.18)),
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
                      GestureDetector(
                        onTap: onBack,
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'Historial de Préstamos',
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
                      'Tus préstamos a la empresa: estado, interés y pagos.',
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
          color: _LoanColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _LoanColors.border),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            const Icon(Icons.search_rounded,
                size: 20, color: _LoanColors.textSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                textInputAction: TextInputAction.search,
                onSubmitted: onSubmitted,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: _LoanColors.textPrimary,
                ),
                decoration: const InputDecoration(
                  isCollapsed: true,
                  filled: false,
                  fillColor: Colors.transparent,
                  hintText: 'Buscar por motivo',
                  hintStyle: TextStyle(
                    fontSize: 13.5,
                    color: _LoanColors.textSecondary,
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
                    child: Icon(Icons.close_rounded,
                        size: 20, color: _LoanColors.textSecondary),
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
                    colors: [_LoanColors.primary, _LoanColors.primaryDeep],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Filtros ─────────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  final String active;
  final ValueChanged<String> onTap;
  const _FilterBar({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final f = _filters[index];
          return _Chip(
            label: f.label,
            active: active == f.label,
            onTap: () => onTap(f.label),
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.active, required this.onTap});

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
                  colors: [_LoanColors.primary, _LoanColors.primaryDeep],
                )
              : null,
          color: active ? null : _LoanColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? Colors.transparent : _LoanColors.border,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: _LoanColors.primary.withValues(alpha: 0.25),
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
            color: active ? Colors.white : _LoanColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─── Tarjeta de métricas (dinero + oro) ──────────────────────────────────────

class _MetricsCard extends StatelessWidget {
  final LoanMetricsEntity metrics;
  const _MetricsCard({required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_LoanColors.primary, _LoanColors.primaryDeep],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _LoanColors.primary.withValues(alpha: 0.25),
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
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.handshake_rounded,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                'Tus préstamos a la empresa',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _UnitColumn(title: 'DINERO', unit: 'Bs', m: metrics.dinero)),
              Container(
                width: 1,
                height: 78,
                margin: const EdgeInsets.symmetric(horizontal: 14),
                color: Colors.white.withValues(alpha: 0.18),
              ),
              Expanded(child: _UnitColumn(title: 'ORO', unit: 'g', m: metrics.gramos)),
            ],
          ),
        ],
      ),
    );
  }
}

class _UnitColumn extends StatelessWidget {
  final String title;
  final String unit;
  final LoanMetricUnitEntity m;
  const _UnitColumn({required this.title, required this.unit, required this.m});

  String _v(double v) => unit == 'Bs' ? 'Bs ${_fmt(v)}' : '${_fmt(v)} g';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _v(m.totalPrestado),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 8),
        _kv('Pendiente', _v(m.totalPendiente)),
        const SizedBox(height: 3),
        _kv('Interés pagado', _v(m.interesPagado)),
      ],
    );
  }

  Widget _kv(String k, String v) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              k,
              style: TextStyle(
                fontSize: 10.5,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            v,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      );
}

// ─── Tarjeta de préstamo ─────────────────────────────────────────────────────

class _StatusStyle {
  final Color fg;
  final Color bg;
  final IconData icon;
  final String label;
  const _StatusStyle(this.fg, this.bg, this.icon, this.label);
}

_StatusStyle _statusStyle(String status) {
  switch (status.toLowerCase()) {
    case 'pagado':
      return const _StatusStyle(
          Color(0xFF17A05D), Color(0xFFE7F7EE), Icons.check_circle_rounded, 'Pagado');
    case 'vigente':
    case 'aprobado':
      return const _StatusStyle(
          Color(0xFF2457C5), Color(0xFFE8F0FE), Icons.verified_rounded, 'Vigente');
    case 'rechazado':
      return const _StatusStyle(
          Color(0xFFD32F2F), Color(0xFFFFEBEE), Icons.cancel_rounded, 'Rechazado');
    case 'cancelado':
      return const _StatusStyle(
          Color(0xFF6B7A99), Color(0xFFEDEFF4), Icons.block_rounded, 'Cancelado');
    case 'en revisión':
    case 'pendiente':
    default:
      return const _StatusStyle(
          Color(0xFFC47A00), Color(0xFFFFF4E5), Icons.hourglass_top_rounded, 'En Revisión');
  }
}

class _LoanCard extends StatelessWidget {
  final LoanHistoryDataEntity item;
  final VoidCallback onTap;
  const _LoanCard({required this.item, required this.onTap});

  String get _amount =>
      item.isGrams ? '${_fmt(item.amountOrQuantity)} g' : 'Bs ${_fmt(item.amountOrQuantity)}';

  String? get _interestLabel {
    if (!item.hasInterest || item.interestRate == null) return null;
    return item.isGrams
        ? '${_fmt(item.interestRate!)} g/mes'
        : '${_fmt(item.interestRate!)} %/mes';
  }

  @override
  Widget build(BuildContext context) {
    final st = _statusStyle(item.status);
    final showPending = (item.status.toLowerCase() == 'vigente' ||
            item.status.toLowerCase() == 'aprobado') &&
        item.outstandingPrincipal != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _LoanColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _LoanColors.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D1B3E).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                        color: (item.isGrams
                                ? _LoanColors.gold
                                : _LoanColors.primary)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        item.isGrams
                            ? Icons.diamond_outlined
                            : Icons.payments_rounded,
                        color: item.isGrams
                            ? const Color(0xFFB8930A)
                            : _LoanColors.primary,
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
                              color: _LoanColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded,
                                  size: 12, color: _LoanColors.textSecondary),
                              const SizedBox(width: 5),
                              Text(
                                formatDate(item.createdAt),
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: _LoanColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusBadge(style: st),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: _LoanColors.border),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.isGrams ? 'Gramos' : 'Monto total',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: _LoanColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _amount,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: _LoanColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (_interestLabel != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: _LoanColors.gold.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.percent_rounded,
                                size: 12, color: Color(0xFFB8930A)),
                            const SizedBox(width: 4),
                            Text(
                              _interestLabel!,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFB8930A),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                if (showPending) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _LoanColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Capital pendiente',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: _LoanColors.textSecondary,
                          ),
                        ),
                        Text(
                          item.isGrams
                              ? '${_fmt(item.outstandingPrincipal!)} g'
                              : 'Bs ${_fmt(item.outstandingPrincipal!)}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: _LoanColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final _StatusStyle style;
  const _StatusBadge({required this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: style.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 13, color: style.fg),
          const SizedBox(width: 4),
          Text(
            style.label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: style.fg,
            ),
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
      case 'En revisión':
        return 'No tienes préstamos en revisión';
      case 'Vigente':
        return 'No tienes préstamos vigentes';
      case 'Pagado':
        return 'No tienes préstamos pagados';
      case 'Rechazado':
        return 'No tienes préstamos rechazados';
      case 'Cancelado':
        return 'No tienes préstamos cancelados';
      default:
        return 'Aún no tienes préstamos';
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
                color: _LoanColors.primary.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.inbox_rounded,
                  size: 44, color: _LoanColors.primary.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 16),
            Text(
              _message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _LoanColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Ofrece un préstamo desde "Registrar Préstamo".',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: _LoanColors.textSecondary),
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
                color: _LoanColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 12.5, color: _LoanColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
