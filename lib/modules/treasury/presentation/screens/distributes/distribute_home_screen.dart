import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/core/widgets/excavator_loader.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/bloc/treasury_bloc.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/widgets/distributes/distributes_home/distribution_card_home_widget.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:intl/intl.dart';
import '../../../domain/entity/entity.dart';
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

  @override
  void initState() {
    super.initState();
    _bloc = InjectorContainer.getIt<TreasuryBloc>()
      ..add(GetDistributionHistoryEvent(isRefresh: true));
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _bloc.add(LoadMoreDistributionHistoryEvent());
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _extractYear(DistributionHistoryItemEntity item) {
    final parts = item.period.trim().split(' ');
    return parts.isNotEmpty ? parts.last : '';
  }

  List<DistributionHistoryItemEntity> _applyFilter(
      List<DistributionHistoryItemEntity> items) {
    if (_filtroAnio == 'Todos') return items;
    return items.where((i) => _extractYear(i) == _filtroAnio).toList();
  }

  List<String> _availableYears(List<DistributionHistoryItemEntity> items) {
    final years = items.map(_extractYear).where((y) => y.isNotEmpty).toSet().toList();
    years.sort((a, b) => b.compareTo(a));
    return years;
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
          onPressed: () async{
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
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: TColors.textPrimary, size: 22),
              onPressed: () {},
            ),
          ],
        ),
        body: BlocBuilder<TreasuryBloc, TreasuryState>(
          buildWhen: (_, curr) =>
              curr is DistributionHistoryLoading ||
              curr is DistributionHistoryLoaded ||
              curr is DistributionHistoryError,
          builder: (context, state) {
            if (state is DistributionHistoryLoading) {
              return const Center(child: ExcavatorLoader());
            }

            if (state is DistributionHistoryError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        color: TColors.danger, size: 48),
                    const SizedBox(height: 12),
                    Text(state.message,
                        style: const TextStyle(
                            color: TColors.textSecondary, fontSize: 13),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          _bloc.add(GetDistributionHistoryEvent(isRefresh: true)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.primary,
                        foregroundColor: TColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (state is DistributionHistoryLoaded) {
              final allItems = state.items;
              final years = _availableYears(allItems);
              final filtered = _applyFilter(allItems);

              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    color: TColors.surface,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: ['Todos', ...years].map((anio) {
                          final selected = _filtroAnio == anio;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _filtroAnio = anio),
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
                  Expanded(
                    child: RefreshIndicator(
                      color: TColors.primary,
                      onRefresh: () async {
                        _bloc.add(GetDistributionHistoryEvent(isRefresh: true));
                        await _bloc.stream.firstWhere((s) =>
                            s is DistributionHistoryLoaded ||
                            s is DistributionHistoryError);
                      },
                      child: filtered.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: const [
                                Padding(
                                  padding: EdgeInsets.only(top: 80),
                                  child: Center(
                                    child: Text(
                                      'Sin registros',
                                      style: TextStyle(
                                          color: TColors.textSecondary,
                                          fontSize: 13),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
                              itemCount: filtered.length +
                                  (state.hasReachedMax ? 0 : 1),
                              itemBuilder: (context, index) {
                                if (index == filtered.length) {
                                  return const Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 16),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                          color: TColors.primary),
                                    ),
                                  );
                                }
                                return DistribucionCardHome(
                                  item: filtered[index],
                                  formatCurrency: _formatCurrency,
                                );
                              },
                            ),
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
