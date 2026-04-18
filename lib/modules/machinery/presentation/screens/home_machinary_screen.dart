import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/widgets/logout_button_widget.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/machinery/domain/entity/entity.dart';
import 'package:front_gestion_minera/modules/machinery/presentation/bloc/machinery_bloc.dart';
import 'package:front_gestion_minera/modules/machinery/presentation/widgets/widgets.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:front_gestion_minera/utils/session/user_session.dart';

@RoutePage()
class HomeMachinaryScreen extends StatefulWidget {
  const HomeMachinaryScreen({super.key});

  @override
  State<HomeMachinaryScreen> createState() => _HomeMachinaryScreenState();
}

class _HomeMachinaryScreenState extends State<HomeMachinaryScreen> {
  String rol = 'cargando...';

  late final MachineryBloc _machineryBloc;
  MetricsMachineryEntity? _cacheMetrics;
  List<MachineryEntity>? _cacheinventory;

  Future<void> _loadUserData() async {
    final role = await UserSession.getRole();
    setState(() {
      rol = role;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _machineryBloc = InjectorContainer.getIt<MachineryBloc>()
      ..add(FetchMetricsMachineEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _machineryBloc,
      child: Scaffold(
        backgroundColor: TColors.appBackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  BlocBuilder<MachineryBloc, MachineryState>(
                    buildWhen: (previous, current) =>
                        current is MetricsMachineryLoading ||
                        current is MetricsMachineryLoaded ||
                        current is MetricsMachineryError ||
                        current is InventoryMachineryLoaded ||
                        current is InventoryMachineryLoading ||
                        current is InventoryMachineryError,
                    builder: (context, state) {
                      if (state is MetricsMachineryLoading) {
                        return const SizedBox(
                          height: 120,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (state is MetricsMachineryError) {
                        return Container(
                          height: 120,
                          width: double.infinity,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: TColors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            state.message,
                            style: TextStyle(color: TColors.red),
                          ),
                        );
                      }
                      if (state is MetricsMachineryLoaded) {
                        _cacheMetrics = state.metrics;
                        _machineryBloc.add(ListInventoryMachineryEvent());
                      }

                      if (state is InventoryMachineryLoaded) {
                        _cacheinventory = state.machinery;
                      }
                      
                      final bool isLoadingM = state is MetricsMachineryLoading;
                      final bool isLoadingI = state is InventoryMachineryLoading;

                      if (_cacheMetrics == null || _cacheinventory == null) {
                        if (isLoadingM || isLoadingI) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (state is MetricsMachineryError) {
                          return Center(child: Text(state.message));
                        }
                        if (state is InventoryMachineryError) {
                          return Center(child: Text(state.message));
                        }
                        return const SizedBox();
                      }
                      
                      final metrics = _cacheMetrics!;
                      final inventory = _cacheinventory!;

                      return Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: TColors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.all(15),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: TColors.appMainColor.withValues(
                                      alpha: 0.4,
                                    ),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: const Icon(Icons.person),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Hola ${UserSession.userName}'),
                                    const SizedBox(height: 10),
                                    Text(
                                      (rol == 'jefe_maquinas')
                                          ? 'Jefe de Maquinas'
                                          : '',
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                LogoutButton(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: TColors.appMainDarkColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Maquinaria',
                                  style: TextStyle(color: TColors.white),
                                ),
                                Text(
                                  metrics.total.toString(),
                                  style: TextStyle(
                                    color: TColors.white,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              CardStateMachineryWidget(
                                metrics: metrics,
                                state: 'Activo',
                              ),
                              CardStateMachineryWidget(
                                metrics: metrics,
                                state: 'inactivo',
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                'Listado de Maquinas',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Spacer(),
                              GestureDetector(
                                onTap: () {},
                                child: Text(
                                  'Ver Todos',
                                  style: TextStyle(color: TColors.appMainColor),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: (inventory.length <= 5)
                                ? inventory.length
                                : 5,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              return CardMachineryWidget(
                                machine: inventory[index],
                              );
                            },
                          ),
                          if (inventory.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: Text(
                                  'No hay lotes con este estado',
                                  style: TextStyle(
                                    color: Color(0xFF9CA3AF),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 15),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: Icon(
                                Icons.add_circle_outline,
                                color: TColors.white,
                                size: 23,
                              ),
                              label: Text(
                                'Registrar Nueva Maquina',
                                style: TextStyle(
                                  color: TColors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: TColors.appMainDarkColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadiusGeometry.circular(
                                    14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
