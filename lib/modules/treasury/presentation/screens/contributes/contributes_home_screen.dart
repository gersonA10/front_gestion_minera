import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/widgets/excavator_loader.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/bloc/treasury_bloc.dart';
import 'package:intl/intl.dart';
import '../../../domain/entity/entity.dart';
import '../../widgets/widgtes.dart';
import 'contributes_ui.dart';

@RoutePage()
class ContributesHomeScreen extends StatefulWidget {
  const ContributesHomeScreen({super.key});

  @override
  State<ContributesHomeScreen> createState() => _ContributesHomeScreenState();
}

class _ContributesHomeScreenState extends State<ContributesHomeScreen> {
  late final TreasuryBloc _bloc;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final _money = NumberFormat('#,##0', 'es_PE');

  @override
  void initState() {
    super.initState();
    _bloc = InjectorContainer.getIt<TreasuryBloc>()
      ..add(GetContributionsEvent(isRefresh: true));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _bloc.add(GetContributionsEvent(
      isRefresh: true,
      search: value.trim().isEmpty ? null : value.trim(),
    ));
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _bloc.add(LoadMoreContributionsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: CUi.bg,
        body: Column(
          children: [
            // Header hero con métricas (solo las métricas se reconstruyen).
            ContribHeader(
              title: 'Aportes',
              subtitle: 'Aportaciones de capital de los socios',
              bottom: BlocBuilder<TreasuryBloc, TreasuryState>(
                buildWhen: (p, c) =>
                    c is ContributionsLoading ||
                    c is ContributionsLoaded ||
                    c is ContributionsError,
                builder: (context, state) {
                  final metrics =
                      state is ContributionsLoaded ? state.metrics : null;
                  return _heroMetrics(metrics);
                },
              ),
            ),
            // Buscador persistente (fuera del área que se reconstruye).
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: _searchBar(),
            ),
            Expanded(
              child: BlocBuilder<TreasuryBloc, TreasuryState>(
                buildWhen: (previous, current) =>
                    current is ContributionsLoading ||
                    current is ContributionsLoaded ||
                    current is ContributionsError,
                builder: (context, state) {
                  if (state is ContributionsLoading) {
                    return const Center(child: ExcavatorLoader());
                  }
                  if (state is ContributionsError) {
                    return CStateView(
                      icon: Icons.cloud_off_rounded,
                      color: CUi.danger,
                      title: 'No pudimos cargar los aportes',
                      subtitle: state.message,
                    );
                  }
                  if (state is ContributionsLoaded) {
                    return _buildContent(state);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Hero de métricas sobre el degradado ──────────────────────────────────
  Widget _heroMetrics(ContributeMetricsEntity? m) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _heroItem(
              Icons.savings_outlined,
              'RECAUDADO',
              m == null ? '—' : '${_money.format(m.totalCollected)} Bs',
              'Total recaudado',
            ),
          ),
          Container(
            width: 1,
            height: 46,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.white.withValues(alpha: 0.18),
          ),
          Expanded(
            child: _heroItem(
              Icons.pending_outlined,
              'PENDIENTE',
              m == null ? '—' : '${_money.format(m.totalPending)} Bs',
              m == null ? '' : 'De ${m.totalSocio ?? '—'} socios',
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroItem(IconData icon, String label, String value, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white.withValues(alpha: 0.85), size: 15),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        if (sub.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            sub,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ],
    );
  }

  // ── Buscador ─────────────────────────────────────────────────────────────
  Widget _searchBar() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: CUi.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CUi.border),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(fontSize: 14, color: CUi.textPrimary),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          hintText: 'Buscar por motivo o socio...',
          hintStyle: const TextStyle(color: CUi.muted, fontSize: 13.5),
          prefixIcon: const Icon(Icons.search_rounded, color: CUi.muted, size: 20),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18, color: CUi.muted),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                    setState(() {});
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildContent(ContributionsLoaded state) {
    return RefreshIndicator(
      color: CUi.primary,
      onRefresh: () async {
        _bloc.add(GetContributionsEvent(isRefresh: true));
      },
      child: ListView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        children: [
          CSectionTitle(
            'Listado de Aportes',
            icon: Icons.list_alt_rounded,
            trailing: state.items.isNotEmpty ? '${state.items.length}' : null,
          ),
          const SizedBox(height: 12),
          if (state.items.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: CStateView(
                icon: Icons.savings_outlined,
                color: CUi.primary,
                title: 'No hay aportes',
                subtitle: 'No se encontraron convocatorias para estos criterios.',
              ),
            )
          else
            ...state.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AporteCard(item: item),
              ),
            ),
          if (state.items.isNotEmpty && !state.hasReachedMax)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CircularProgressIndicator(color: CUi.primary),
              ),
            )
          else if (state.items.isNotEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'No hay más aportes.',
                  style: TextStyle(fontSize: 13, color: CUi.textSecondary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
