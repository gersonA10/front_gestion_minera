import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  void _reload() => _machineryBloc
      .add(FetchMaintenanceHistoryEvent(machineId: widget.machineId));

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _machineryBloc,
      child: Scaffold(
        backgroundColor: TColors.background,
        appBar: AppBar(
          backgroundColor: TColors.white,
          surfaceTintColor: TColors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          foregroundColor: TColors.textPrimary,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          leading: const BackButton(color: TColors.textPrimary),
          title: const Text(
            'Solicitudes de mantenimiento',
            style: TextStyle(
              color: TColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: TColors.appMainColor,
            unselectedLabelColor: TColors.textSecondary,
            indicatorColor: TColors.appMainColor,
            indicatorWeight: 2.5,
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: TColors.border,
            labelPadding: const EdgeInsets.symmetric(horizontal: 16),
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(height: 46, text: 'Historial'),
              Tab(height: 46, text: 'Pendientes'),
              Tab(height: 46, text: 'Completadas'),
              Tab(height: 46, text: 'Rechazadas'),
              Tab(height: 46, text: 'Pagadas'),
            ],
          ),
        ),
        body: BlocBuilder<MachineryBloc, MachineryState>(
          builder: (context, state) {
            if (state is MaintenanceHistoryLoading) {
              return const _HistorySkeleton();
            }
            if (state is MaintenanceHistoryError) {
              return _HistoryError(message: state.message, onRetry: _reload);
            }

            final items = state is MaintenanceHistoryLoaded
                ? state.items
                : <MaintenanceHistoryItemEntity>[];
            final hasReachedMax =
                state is MaintenanceHistoryLoaded ? state.hasReachedMax : true;

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
                .where((e) => e.globalStatus == MaintenanceGlobalStatus.paid)
                .toList();

            return TabBarView(
              controller: _tabController,
              children: [
                _buildList(items, hasReachedMax,
                    'Esta unidad aún no tiene solicitudes registradas.'),
                _buildList(pending, true,
                    'No hay solicitudes en revisión.'),
                _buildList(completed, true,
                    'No hay solicitudes completadas.'),
                _buildList(rejected, true,
                    'No hay solicitudes rechazadas.'),
                _buildList(paid, true, 'No hay solicitudes pagadas.'),
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
    String emptyMessage,
  ) {
    if (items.isEmpty) {
      return _HistoryEmpty(message: emptyMessage);
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
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        itemCount: items.length + (hasReachedMax ? 0 : 1),
        itemBuilder: (context, index) {
          if (index == items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: TColors.appMainColor,
                  ),
                ),
              ),
            );
          }
          final item = items[index];
          return MaintenanceCard(
            item: item,
            onTap: () => context.router.push(
              DetailMaintenanceRoute(maintenanceId: item.maintenanceId),
            ),
          );
        },
      ),
    );
  }
}

/// Estado vacío por pestaña.
class _HistoryEmpty extends StatelessWidget {
  final String message;

  const _HistoryEmpty({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: TColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fact_check_outlined,
                size: 32,
                color: TColors.appMainColor,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sin solicitudes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: TColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: TColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Estado de error con reintento.
class _HistoryError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _HistoryError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: TColors.dangerLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_off_rounded,
                  size: 32, color: TColors.danger),
            ),
            const SizedBox(height: 16),
            const Text(
              'No se pudo cargar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: TColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: TColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: TColors.appMainColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text(
                'Reintentar',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton de carga del historial.
class _HistorySkeleton extends StatefulWidget {
  const _HistorySkeleton();

  @override
  State<_HistorySkeleton> createState() => _HistorySkeletonState();
}

class _HistorySkeletonState extends State<_HistorySkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();
  late final Animation<double> _a =
      CurvedAnimation(parent: _ac, curve: Curves.easeInOut);

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _a,
      builder: (_, _) {
        final c = Color.lerp(
          const Color(0xFFEAEDF2),
          const Color(0xFFF6F8FB),
          _a.value,
        )!;
        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          itemCount: 5,
          itemBuilder: (_, _) => _cardBone(c),
        );
      },
    );
  }

  Widget _bone(Color c,
      {double? width, required double height, double radius = 6}) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _cardBone(Color c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _bone(c, width: 42, height: 42, radius: 12),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _bone(c, width: 150, height: 13, radius: 6),
                    const SizedBox(height: 8),
                    _bone(c, width: 110, height: 11, radius: 6),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _bone(c, width: 70, height: 22, radius: 20),
            ],
          ),
          const SizedBox(height: 14),
          _bone(c, height: 11, radius: 6),
          const SizedBox(height: 8),
          _bone(c, width: 220, height: 11, radius: 6),
          const SizedBox(height: 14),
          Row(
            children: [
              _bone(c, width: 90, height: 11, radius: 6),
              const Spacer(),
              _bone(c, width: 70, height: 14, radius: 6),
            ],
          ),
        ],
      ),
    );
  }
}
