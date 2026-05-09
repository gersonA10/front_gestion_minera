import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/camp/presentation/widgets/widgets.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import '../../../../core/widgets/logout_button_widget.dart';
import '../bloc/camp_bloc.dart';

@RoutePage()
class HomeDashboardCampScreen extends StatefulWidget {
  const HomeDashboardCampScreen({super.key});

  @override
  State<HomeDashboardCampScreen> createState() =>
      _HomeDashboardCampScreenState();
}

class _HomeDashboardCampScreenState extends State<HomeDashboardCampScreen> {
  late final CampBloc _campBloc;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _campBloc = InjectorContainer.getIt<CampBloc>();
    _scrollController.addListener(_onScroll);
    _campBloc.add(GetCampDashboardEvent());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _campBloc.add(LoadMoreCampRequestsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _campBloc,
      child: Scaffold(
        backgroundColor: TColors.appBackgroundColor,
        appBar: AppBar(
          backgroundColor: TColors.white,
          title: const Row(
            children: [
              SizedBox(width: 10),
              Text('Campamento'),
              Spacer(),
              LogoutButton(),
            ],
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<CampBloc, CampState>(
            builder: (context, state) {
              if (state is CampDashboardLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is CampDashboardError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.message, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _campBloc.add(GetCampDashboardEvent()),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              }

              if (state is CampDashboardLoaded) {
                return RefreshIndicator(
                  onRefresh: () async => _campBloc.add(GetCampDashboardEvent()),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CardDashboardCampWidget(
                                type: 'activo',
                                count: state.stats.active,
                              ),
                              CardDashboardCampWidget(
                                type: 'completado',
                                count: state.stats.completed,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              const Text(
                                'Solicitudes Recientes',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  context.router.push(TransactionHistoryRoute());
                                },
                                child: Text(
                                  'Ver Todos',
                                  style: TextStyle(color: TColors.appMainColor),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 5,
                            itemBuilder: (context, index) {
                              if (index == state.requests.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              return CardRequestsWidget(
                                request: state.requests[index],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25.0),
          child: FloatingActionButton.extended(
            onPressed: ()async {
             final res = await context.router.push(const NewRequestRoute());
             if(res == true) {
              _campBloc.add(GetCampDashboardEvent());
             }
            },
            backgroundColor: TColors.appMainColor,
            icon: const Icon(Icons.add),
            label: const Text(
              'Nueva Solicitud',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(50),
            ),
          ),
        ),
      ),
    );
  }
}
