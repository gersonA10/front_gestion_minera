import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/bloc/treasury_bloc.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import '../../widgets/widgtes.dart';

@RoutePage()
class ContributesDetailScreen extends StatefulWidget {
  final String contributionId;
  final DateTime dateContibution;
  final String titleContibuton;
  const ContributesDetailScreen({
    super.key,
    required this.contributionId,
    required this.dateContibution,
    required this.titleContibuton,
  });

  @override
  State<ContributesDetailScreen> createState() =>
      _ContributesDetailScreenState();
}

class _ContributesDetailScreenState extends State<ContributesDetailScreen> {
  int _selectedTab = 0;
  late final TreasuryBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = InjectorContainer.getIt<TreasuryBloc>()
      ..add(GetContributionDetailEvent(contributionId: widget.contributionId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: TColors.appBackgroundColor,
        appBar: AppBar(
          backgroundColor: TColors.lightContainerAccount,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: TColors.appMainTextColor,
              size: 22,
            ),
            onPressed: () => context.maybePop(),
          ),
          title: const Text(
            'Detalle de Aporte',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: TColors.appMainTextColor,
            ),
          ),
          centerTitle: true,
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(
                  Icons.credit_card_outlined,
                  size: 20,
                  color: TColors.white,
                ),
                label: const Text(
                  'Registrar Pago',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: TColors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.appMainColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ),
        ),
        body: BlocBuilder<TreasuryBloc, TreasuryState>(
          buildWhen: (_, state) =>
              state is ContributionDetailLoading ||
              state is ContributionDetailLoaded ||
              state is ContributionDetailError,
          builder: (context, state) {
            if (state is ContributionDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ContributionDetailError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: TColors.appSecondaryTextColor),
                ),
              );
            }
            if (state is ContributionDetailLoaded) {
              final pendientes = state.membersList
                  .where((m) => m.status.toLowerCase() == 'pendiente')
                  .toList();
              final pagados = state.membersList
                  .where((m) => m.status.toLowerCase() != 'pendiente')
                  .toList();
              final lista = _selectedTab == 0 ? pendientes : pagados;
              final cahs = state.cash;

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: TColors.lightContainerAccount,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: TColors.appSurfaceColor),
                        boxShadow: [
                          BoxShadow(
                            color: TColors.appMainColor.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Meta Total',
                            style: TextStyle(
                              fontSize: 13,
                              color: TColors.appSecondaryTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${state.headerMetrics.totalGoal.toStringAsFixed(2)} Bs',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: TColors.appMainTextColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.headerMetrics.reason,
                            style: const TextStyle(
                              fontSize: 12,
                              color: TColors.appSecondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ResumenCardContributes(
                            label: 'RECAUDADO',
                            amount:
                                '${state.headerMetrics.actualCollected.toStringAsFixed(2)} Bs',
                            accentColor: TColors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ResumenCardContributes(
                            label: 'PENDIENTE',
                            amount:
                                '${state.headerMetrics.pendingAmount.toStringAsFixed(2)} Bs',
                            accentColor: TColors.pendingYellow,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Container(
                      decoration: BoxDecoration(
                        color: TColors.appSurfaceColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          TabBtnContribute(
                            label: 'Pendientes',
                            count: pendientes.length,
                            active: _selectedTab == 0,
                            onTap: () => setState(() => _selectedTab = 0),
                          ),
                          TabBtnContribute(
                            label: 'Pagados',
                            count: pagados.length,
                            active: _selectedTab == 1,
                            onTap: () => setState(() => _selectedTab = 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: lista.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => SocioCard(
                        item: lista[i],
                        isPendiente: _selectedTab == 0,
                        dateContibution: widget.dateContibution,
                        titleContibuton: widget.titleContibuton,
                        cash: cahs,
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
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
