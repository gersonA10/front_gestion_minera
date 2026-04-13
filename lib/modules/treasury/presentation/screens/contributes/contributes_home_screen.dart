import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/widgets/excavator_loader.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/bloc/treasury_bloc.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import '../../widgets/widgtes.dart';

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
  bool _showSearch = false;

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
    _bloc.add(GetContributionsEvent(isRefresh: true, search: value.trim().isEmpty ? null : value.trim()));
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
      if (!_showSearch) {
        _searchController.clear();
        _bloc.add(GetContributionsEvent(isRefresh: true));
      }
    });
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
        backgroundColor: TColors.background,
        appBar: AppBar(
          backgroundColor: TColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: TColors.textPrimary,
              size: 22,
            ),
            onPressed: () => context.router.back(),
          ),
          title: _showSearch
              ? SizedBox(
                height: 40,
                child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Buscar socio...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: TColors.textSecondary),
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      color: TColors.textPrimary,
                    ),
                    onChanged: _onSearchChanged,
                  ),
              )
              : const Text(
                  'Aportes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: TColors.textPrimary,
                  ),
                ),
          centerTitle: !_showSearch,
          actions: [
            IconButton(
              icon: Icon(
                _showSearch ? Icons.close : Icons.search,
                color: TColors.textPrimary,
                size: 22,
              ),
              onPressed: _toggleSearch,
            ),
          ],
        ),
        body: BlocBuilder<TreasuryBloc, TreasuryState>(
          buildWhen: (previous, current) =>
              current is ContributionsLoading ||
              current is ContributionsLoaded ||
              current is ContributionsError,
          builder: (context, state) {
            if (state is ContributionsLoading) {
              return const Center(child: ExcavatorLoader());
            }
            if (state is ContributionsError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: TColors.textSecondary),
                ),
              );
            }
            if (state is ContributionsLoaded) {
              return _buildContent(state);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildContent(ContributionsLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        _bloc.add(GetContributionsEvent(isRefresh: true));
      },
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          Row(
            children: [
              Expanded(
                child: SummaryCardContributes(
                  icon: Icons.savings_outlined,
                  iconColor: TColors.primary,
                  label: 'RECAUDADO',
                  amount:
                      '${state.metrics.totalCollected.toStringAsFixed(0)} Bs',
                  subtitle: 'Total recaudado',
                  subtitleColor: TColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SummaryCardContributes(
                  icon: Icons.pending_outlined,
                  iconColor: TColors.pendingYellow,
                  label: 'PENDIENTE',
                  amount: '${state.metrics.totalPending.toStringAsFixed(0)} Bs',
                  subtitle: 'De ${state.metrics.totalSocio ?? '—'} socios',
                  subtitleColor: TColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Listado de Aportes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: TColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...state.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AporteCard(item: item),
            ),
          ),
          if (!state.hasReachedMax)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state.items.isNotEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'No hay más aportes.',
                  style: TextStyle(fontSize: 13, color: TColors.textSecondary),
                ),
              ),
            ),
          if (state.items.isEmpty)
            const Center(
              child: Text(
                'No hay convocatorias para estos criterios.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: TColors.textSecondary),
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

