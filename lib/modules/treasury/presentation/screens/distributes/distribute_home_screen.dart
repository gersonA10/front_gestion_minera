import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/widgets/excavator_loader.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/bloc/treasury_bloc.dart';
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
  String _filtro = 'Todos';
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

  bool _esAbierto(DistributionHistoryItemEntity i) =>
      i.status.toLowerCase() == 'abierto';

  List<DistributionHistoryItemEntity> _applyFilter(
      List<DistributionHistoryItemEntity> items) {
    if (_filtro == 'Todos') return items;
    if (_filtro == 'Pendientes') return items.where(_esAbierto).toList();
    return items.where((i) => !_esAbierto(i)).toList(); 
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
        appBar: AppBar(
          backgroundColor: TColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios,
                color: TColors.textPrimary, size: 18),
            onPressed: () => context.router.back(),
          ),
          title: const Text(
            'Detalle de distribución\nde dividendos',
            style: TextStyle(
              color: TColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
        ),
        body: BlocBuilder<TreasuryBloc, TreasuryState>(
          buildWhen: (_, curr) =>
              curr is DistributionHistoryLoading ||
              curr is DistributionHistoryLoaded ||
              curr is DistributionHistoryError,
          builder: (context, state) {
            if (state is DistributionHistoryLoading) {
              return const Center(
                  child: ExcavatorLoader());
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
                      onPressed: () => _bloc
                          .add(GetDistributionHistoryEvent(isRefresh: true)),
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
              final filtered = _applyFilter(allItems);

              final totalRegistered =
                  allItems.fold<double>(0, (s, i) => s + i.registeredAmount);
              final totalPaid =
                  allItems.fold<double>(0, (s, i) => s + i.amountPaid);
              final totalDue =
                  allItems.fold<double>(0, (s, i) => s + i.amountDue);
              final totalPagados =
                  allItems.where((i) => !_esAbierto(i)).length;
              final totalPendientes =
                  allItems.where(_esAbierto).length;

              return RefreshIndicator(
                color: TColors.primary,
                onRefresh: () async {
                  _bloc.add(GetDistributionHistoryEvent(isRefresh: true));
                  await _bloc.stream.firstWhere((s) =>
                      s is DistributionHistoryLoaded ||
                      s is DistributionHistoryError);
                },
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: SummaryCardDistributes(
                              label: 'Monto Registrado',
                              value: _formatCurrency(totalRegistered),
                              valueColor: TColors.textPrimary,
                              bgColor: TColors.primaryLight,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SummaryCardDistributes(
                              label: 'Saldo Pendiente',
                              value: _formatCurrency(totalDue),
                              valueColor: TColors.warning,
                              bgColor: TColors.warningLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SummaryCardDistributes(
                        label: 'Total Pagado',
                        value: _formatCurrency(totalPaid),
                        valueColor: TColors.success,
                        bgColor: TColors.successLight,
                        fullWidth: true,
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: TColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: TColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CounterItem(
                              value: '${state.totalRecords}',
                              label: 'TOTAL',
                              color: TColors.textPrimary,
                            ),
                            Container(
                                width: 1, height: 36, color: TColors.border),
                            CounterItem(
                              value: '$totalPagados',
                              label: 'PAGADOS',
                              color: TColors.success,
                            ),
                            Container(
                                width: 1, height: 36, color: TColors.border),
                            CounterItem(
                              value: '$totalPendientes',
                              label: 'PENDIENTES',
                              color: TColors.warning,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: ['Todos', 'Pendientes', 'Pagados']
                            .map((f) {
                          final selected = _filtro == f;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => _filtro = f),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 9),
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
                                  f,
                                  style: TextStyle(
                                    color: selected
                                        ? TColors.white
                                        : TColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),
                      if (filtered.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: Center(
                            child: Text('Sin registros',
                                style: TextStyle(
                                    color: TColors.textSecondary,
                                    fontSize: 13)),
                          ),
                        )
                      else
                        ...filtered.map((item) => DistributionCard(
                              item: item,
                              formatCurrency: _formatCurrency,
                            )),

                      if (!state.hasReachedMax)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                              child: CircularProgressIndicator(
                                  color: TColors.primary)),
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
