import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/modules/surveillance/presentation/screen/register_contribution.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/surveillance/presentation/bloc/surveillance_bloc.dart';
import 'package:front_gestion_minera/modules/surveillance/presentation/widget/request_card_widget.dart';
import 'package:front_gestion_minera/utils/date_util.dart';
import 'package:front_gestion_minera/utils/text_util.dart';

@RoutePage()
class HomeSurveillanceScreen extends StatefulWidget {
  const HomeSurveillanceScreen({super.key});

  @override
  State<HomeSurveillanceScreen> createState() => _HomeSurveillanceScreenState();
}

class _HomeSurveillanceScreenState extends State<HomeSurveillanceScreen> {
  int _selectedIndex = 0;
  late final SurveillanceBloc _surveillanceBloc;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _surveillanceBloc = InjectorContainer.getIt<SurveillanceBloc>()
      ..add(MonitoringTrayEvent());

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _surveillanceBloc.add(LoadMoreRequestEvent());
    }
  }

void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    if (index == 0) {
      _surveillanceBloc.add(MonitoringTrayEvent(isRefresh: false));
    }
  }

  void _fetchHistory({bool isRefresh = false}) {
    _surveillanceBloc.add(MonitoringTrayEvent(isRefresh: isRefresh));
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final smallSpacing = screenSize.height * 0.02;
    final double topPadding = screenSize.height * 0.2;
    final colors = Theme.of(context).colorScheme;
    return BlocProvider.value(
      value: _surveillanceBloc,
      child: Scaffold(
        backgroundColor: colors.backgroundColor,
        appBar: AppBar(
          backgroundColor: colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "Bandeja de Solicitudes",
            style: AppTextStyles.mainStyle16Bold(context),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: TextButton(
                onPressed: () => context.router.push(const HistoryRequestsRoute()),
                child: Text(
                  "Historial",
                  style: AppTextStyles.mainStyleBlue12Bold(context),
                ),
              ),
              ),
            ),
          ],
        ),
        body: _buildBody(smallSpacing, topPadding),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet),
              label: 'Aportes',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: colors.blue,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  Widget _buildBody(double smallSpacing, double topPadding) {
    if (_selectedIndex == 0) {
      return BlocConsumer<SurveillanceBloc, SurveillanceState>(
        listener: (context, state) {
          // opcional: mostrar snackbar, etc.
        },
        builder: (context, state) {
          if (state is SurveillanceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SurveillanceError) {
            return RefreshIndicator(
              onRefresh: () async {
                _fetchHistory();
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 120),
                  Center(
                    child: Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.mainStyle12(
                        context,
                      ).copyWith(color: Theme.of(context).colorScheme.red),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is SurveillanceSuccess) {
            final items = state.list;
            return RefreshIndicator(
              onRefresh: () async {
                _fetchHistory(isRefresh: true);
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: topPadding * 0.08),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: smallSpacing * 0.5),
                    Row(
                      children: [
                        Text(
                          "PENDIENTES (${state.totalRecords})",
                          style: AppTextStyles.mainStyleGrey12Bold(context),
                        ),
                        SizedBox(width: smallSpacing * 0.8),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: smallSpacing * 0.5),
                    Expanded(
                      child: items.isEmpty
                          ? const Center(
                              child: Text('No hay solicitudes pendientes'),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              itemCount: items.length + 1,
                              itemBuilder: (context, index) {
                                if (index == items.length &&
                                    !state.hasReachedMax) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 24.0,
                                    ),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          CircularProgressIndicator(),
                                          SizedBox(height: 10),
                                          Text(
                                            'Cargando mas registros...',
                                            style: AppTextStyles.mainStyle12(
                                              context,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                if (index == state.list.length) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16.0,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Mostrando todas las solicitudes.',
                                        style: AppTextStyles.mainStyle10(
                                          context,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                final item = items[index];
                                return RequestCard(
                                  date: formatDate(item.createdAt),
                                  name: item.name,
                                  area: item.rol,
                                  small: smallSpacing,
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          }

          // estado inicial u otro
          return const SizedBox.shrink();
        },
      );
    } else {
      return RegisterContributionsView();
    }
  }
}
