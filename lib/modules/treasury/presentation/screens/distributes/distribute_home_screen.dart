import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/staff_ui.dart';
import 'package:front_gestion_minera/modules/treasury/domain/entity/distribute/distribution_history_entity.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/bloc/treasury_bloc.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/widgets/distributes/distributes_home/distribution_card_home_widget.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:intl/intl.dart';
import '../../widgets/widgtes.dart';

@RoutePage()
class DistributeHomeScreen extends StatefulWidget {
  const DistributeHomeScreen({super.key});

  @override
  State<DistributeHomeScreen> createState() => _DistributeHomeScreenState();
}

class _DistributeHomeScreenState extends State<DistributeHomeScreen> {
  String _filtroAnio = 'Todos';
  late final TreasuryBloc _bloc;
  final ScrollController _scrollController = ScrollController();

  List<DistributionHistoryItemEntity> _cachedItems = [];

  bool _hasMax = true;

  bool _isInitialLoading = false;

  @override
  void initState() {
    super.initState();
    _bloc = InjectorContainer.getIt<TreasuryBloc>()
      ..add(GetDistributionHistoryEvent(isRefresh: true));

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels < _scrollController.position.maxScrollExtent - 200) return;

    if (_hasMax || _isInitialLoading) return;

    _bloc.add(LoadMoreDistributionHistoryEvent());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<String> _availableYears() {
    final currentYear = DateTime.now().year;
    return List.generate(3, (i) => '${currentYear - i}');
  }

  void _onYearSelected(String anio) {
    setState(() => _filtroAnio = anio);
    final year = int.tryParse(anio);
    _bloc.add(GetDistributionHistoryEvent(isRefresh: true, year: year));
  }

  String _formatCurrency(double value) => NumberFormat.currency(
        locale: 'es_BO',
        symbol: 'Bs',
        decimalDigits: 2,
      ).format(value);

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: TColors.background,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            await context.router.push(const NewDistributionRoute());
            _bloc.add(GetDistributionHistoryEvent(isRefresh: true));
          },
          backgroundColor: TColors.primary,
          foregroundColor: TColors.white,
          icon: const Icon(Icons.add, size: 18),
          label: const Text(
            'Nuevo Dividendo',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        appBar: AppBar(
          backgroundColor: TColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios,
                color: TColors.textPrimary, size: 18),
            onPressed: () => context.router.back(),
          ),
          centerTitle: true,
          title: const Text(
            'Dividendos',
            style: TextStyle(
              color: TColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          // actions: [
          //   IconButton(
          //     icon: const Icon(Icons.search,
          //         color: TColors.textPrimary, size: 22),
          //     onPressed: () {},
          //   ),
          // ],
        ),
        body: BlocConsumer<TreasuryBloc, TreasuryState>(
          listenWhen: (_, curr) =>
              curr is DistributionHistoryLoading ||
              curr is DistributionHistoryLoaded ||
              curr is DistributionHistoryError,
          listener: (context, state) {
            if (state is DistributionHistoryLoading) {
              // FIX: cuando empieza el refresh bloqueamos el scroll listener
              setState(() => _isInitialLoading = true);
            }
            if (state is DistributionHistoryLoaded ||
                state is DistributionHistoryError) {
              // FIX: cuando termina, desbloqueamos
              setState(() => _isInitialLoading = false);
            }
          },
          buildWhen: (_, curr) =>
              curr is DistributionHistoryLoading ||
              curr is DistributionHistoryLoaded ||
              curr is DistributionHistoryError,
          builder: (context, state) {
            final isLoading = state is DistributionHistoryLoading;

            if (state is DistributionHistoryLoaded) {
              _cachedItems = state.items;
              // FIX: solo actualizamos _hasMax cuando llegó la respuesta real
              _hasMax = state.hasReachedMax;
            }

            final years = _availableYears();

            return Stack(
              children: [
                Column(
                  children: [
                    // Chips de año
                    Container(
                      width: double.infinity,
                      color: TColors.surface,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ['Todos', ...years].map((anio) {
                            final selected = _filtroAnio == anio;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () => _onYearSelected(anio),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? TColors.textPrimary
                                        : TColors.surface,
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: selected
                                          ? TColors.textPrimary
                                          : TColors.border,
                                    ),
                                  ),
                                  child: Text(
                                    anio,
                                    style: TextStyle(
                                      color: selected
                                          ? TColors.white
                                          : TColors.textSecondary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    // Lista
                    Expanded(
                      child: RefreshIndicator(
                        color: TColors.primary,
                        onRefresh: () async {
                          _bloc.add(GetDistributionHistoryEvent(
                            isRefresh: true,
                            year: int.tryParse(_filtroAnio),
                          ));
                          await _bloc.stream.firstWhere((s) =>
                              s is DistributionHistoryLoaded ||
                              s is DistributionHistoryError);
                        },
                        child: _cachedItems.isEmpty && !isLoading
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  if (state is DistributionHistoryError)
                                    Padding(
                                      padding: const EdgeInsets.all(32),
                                      child: Column(
                                        children: [
                                          const Icon(Icons.error_outline,
                                              color: TColors.danger, size: 48),
                                          const SizedBox(height: 12),
                                          Text(state.message,
                                              style: const TextStyle(
                                                  color: TColors.textSecondary,
                                                  fontSize: 13),
                                              textAlign: TextAlign.center),
                                          const SizedBox(height: 16),
                                          ElevatedButton(
                                            onPressed: () => _bloc.add(
                                                GetDistributionHistoryEvent(
                                                    isRefresh: true)),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: TColors.primary,
                                              foregroundColor: TColors.white,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                            ),
                                            child: const Text('Reintentar'),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    Padding(
                                      padding: const EdgeInsets.only(top: 90),
                                      child: Center(
                                        child: Column(
                                          children: [
                                            Container(
                                              width: 72,
                                              height: 72,
                                              decoration: BoxDecoration(
                                                color: TColors.primaryLight,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.pie_chart_outline_rounded,
                                                color: TColors.primary,
                                                size: 34,
                                              ),
                                            ),
                                            const SizedBox(height: 18),
                                            const Text(
                                              'Aún no hay dividendos',
                                              style: TextStyle(
                                                color: TColors.textPrimary,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            const Text(
                                              'Crea tu primer dividendo con el\nbotón "Nuevo Dividendo"',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: TColors.textSecondary,
                                                fontSize: 13,
                                                height: 1.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                    16, 14, 16, 100),
                                // FIX: solo mostrar el loader del final
                                // cuando hay más páginas Y no estamos en refresh
                                itemCount: _cachedItems.length +
                                    (!_hasMax && !_isInitialLoading ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == _cachedItems.length) {
                                    return const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16),
                                      child: StaffLoader(),
                                    );
                                  }
                                  return DistribucionCardHome(
                                    item: _cachedItems[index],
                                    formatCurrency: _formatCurrency,
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),

                // Overlay de carga del refresh (barra superior)
                if (isLoading)
                  Positioned(
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
            );
          },
        ),
      ),
    );
  }
}