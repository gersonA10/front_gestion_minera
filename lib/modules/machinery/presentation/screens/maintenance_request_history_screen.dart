import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/machinery/presentation/bloc/machinery_bloc.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import '../../domain/entity/entity.dart';
import '../widgets/widgets.dart';

@RoutePage()
class MaintenanceRequestHistoryScreen extends StatefulWidget {
  final String machineId;

  const MaintenanceRequestHistoryScreen({super.key, required this.machineId});

  @override
  State<MaintenanceRequestHistoryScreen> createState() =>
      _MaintenanceRequestHistoryScreenState();
}

class _MaintenanceRequestHistoryScreenState
    extends State<MaintenanceRequestHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late MachineryBloc _machineryBloc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _machineryBloc = InjectorContainer.getIt<MachineryBloc>()
      ..add(FetchMaintenanceHistoryEvent(machineId: widget.machineId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _machineryBloc,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Solicitudes de Mantenimiento',
            style: TextStyle(
              color: Color(0xFF1A1A2E),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: TColors.textPrimary,
            unselectedLabelColor: const Color(0xFF9CA3AF),
            indicatorColor: TColors.textPrimary,
            indicatorWeight: 2.5,
            labelPadding: const EdgeInsets.symmetric(horizontal: 20),
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            dividerColor: TColors.appSecondaryTextColor,
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            tabs: const [
              Tab(height: 48, text: 'Historial'),
              Tab(height: 48, text: 'Pendientes'),
              Tab(height: 48, text: 'Completadas'),
              Tab(height: 48, text: 'Rechazadas'),
              Tab(height: 48, text: 'Pagadas'),
            ],
          ),
        ),
        body: BlocBuilder<MachineryBloc, MachineryState>(
          builder: (context, state) {
            if (state is MaintenanceHistoryLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is MaintenanceHistoryError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.message,
                      style: const TextStyle(color: Color(0xFF9CA3AF)),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.read<MachineryBloc>().add(
                        FetchMaintenanceHistoryEvent(
                          machineId: widget.machineId,
                        ),
                      ),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            final items = state is MaintenanceHistoryLoaded
                ? state.items
                : <MaintenanceHistoryItemEntity>[];
            final hasReachedMax = state is MaintenanceHistoryLoaded
                ? state.hasReachedMax
                : true;

            final pending = items
                .where((e) => e.globalStatus == MaintenanceGlobalStatus.inReview)
                .toList();
            final completed = items
                .where((e) =>
                    e.globalStatus == MaintenanceGlobalStatus.completed ||
                    e.globalStatus == MaintenanceGlobalStatus.approved)
                .toList();
            final rejected = items
                .where((e) => e.globalStatus == MaintenanceGlobalStatus.rejected)
                .toList();
            final paid = items
                .where((e) => e.globalStatus == 'PAID')
                .toList();

            return TabBarView(
              controller: _tabController,
              children: [
                _buildList(items, hasReachedMax),
                _buildList(pending, true),
                _buildList(completed, true),
                _buildList(rejected, true),
                _buildList(paid, true),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(
    List<MaintenanceHistoryItemEntity> items,
    bool hasReachedMax,
  ) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'Sin solicitudes',
          style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (!hasReachedMax &&
            notification is ScrollEndNotification &&
            notification.metrics.extentAfter < 200) {
          context.read<MachineryBloc>().add(
            LoadMoreMaintenanceHistoryEvent(machineId: widget.machineId),
          );
        }
        return false;
      },
      child: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          itemCount: items.length + (hasReachedMax ? 0 : 1),
          itemBuilder: (context, index) {
            if (index == items.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return GestureDetector(
              onTap: () {
                context.router.push(
                  DetailMaintenanceRoute(maintenanceId: items[index].maintenanceId),
                );
              },
              child: MaintenanceCard(item: items[index]));
          },
        ),
      ),
    );
  }
}

