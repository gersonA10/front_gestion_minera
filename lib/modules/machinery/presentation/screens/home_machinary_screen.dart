import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
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
          child: BlocConsumer<MachineryBloc, MachineryState>(
            // Los efectos secundarios (cachear datos y encadenar el siguiente
            // fetch) van en el listener, no en el builder.
            listenWhen: (previous, current) =>
                current is MetricsMachineryLoaded ||
                current is InventoryMachineryLoaded,
            listener: (context, state) {
              if (state is MetricsMachineryLoaded) {
                _cacheMetrics = state.metrics;
                _machineryBloc.add(ListInventoryMachineryEvent());
              } else if (state is InventoryMachineryLoaded) {
                _cacheinventory = state.machinery;
              }
            },
            buildWhen: (previous, current) =>
                current is MetricsMachineryLoading ||
                current is MetricsMachineryLoaded ||
                current is MetricsMachineryError ||
                current is InventoryMachineryLoaded ||
                current is InventoryMachineryLoading ||
                current is InventoryMachineryError,
            builder: (context, state) {
              // Error al cargar las métricas sin datos previos en caché.
              if (state is MetricsMachineryError && _cacheMetrics == null) {
                return _buildErrorState(state.message);
              }
              // Error al cargar el inventario sin datos previos en caché.
              if (state is InventoryMachineryError &&
                  _cacheinventory == null) {
                return _buildErrorState(state.message);
              }
              // Todavía esperando los datos iniciales.
              if (_cacheMetrics == null || _cacheinventory == null) {
                return const Center(child: CircularProgressIndicator());
              }

              final metrics = _cacheMetrics!;
              final inventory = _cacheinventory!;

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
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
                                onTap: () {
                                  context.router.push(ListMachineryRoute());
                                },
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
                              onPressed: () async {
                              final response =  await context.router.push(
                                  RegistrationOfNewMachineryRoute(),
                                );
                                if (response == true) {
                                  _machineryBloc.add(FetchMetricsMachineEvent());
                                }
                              },
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
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: TColors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: TColors.red),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () =>
                    _machineryBloc.add(FetchMetricsMachineEvent()),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
