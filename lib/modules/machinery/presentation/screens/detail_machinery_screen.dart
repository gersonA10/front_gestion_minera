import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/machinery/domain/entity/entity.dart';
import 'package:front_gestion_minera/modules/machinery/presentation/bloc/machinery_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../utils/assets.dart';
import '../../../../utils/constants/color.constant.dart';
import '../widgets/widgets.dart';

@RoutePage()
class DetailMachineryScreen extends StatefulWidget {
  final String machineId;

  const DetailMachineryScreen({super.key, required this.machineId});

  @override
  State<DetailMachineryScreen> createState() => _DetailMachineryScreenState();
}

class _DetailMachineryScreenState extends State<DetailMachineryScreen> {
  late MachineryBloc _machineryBloc;

  @override
  void initState() {
    super.initState();
    _machineryBloc = InjectorContainer.getIt<MachineryBloc>()
      ..add(GetCloseUpOfAMachineEvent(machineId: widget.machineId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _machineryBloc,
      child: Scaffold(
        backgroundColor: TColors.appBackgroundColor,
        appBar: AppBar(
          title: const Text(
            'Detalle de Maquinaria',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: TColors.appMainTextColor,
            ),
          ),
          backgroundColor: TColors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: TColors.appMainTextColor),
        ),
        body: BlocBuilder<MachineryBloc, MachineryState>(
          builder: (context, state) {
            if (state is GetCloseUpOfAMachineLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is GetCloseUpOfAMachineError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.message,
                      style: const TextStyle(
                          color: TColors.appSecondaryTextColor),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.read<MachineryBloc>().add(
                            GetCloseUpOfAMachineEvent(
                                machineId: widget.machineId),
                          ),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            final header = state is GetCloseUpOfAMachineLoaded
                ? state.headerMetrics
                : null;
            final items = state is GetCloseUpOfAMachineLoaded
                ? state.items
                : <MaintenancesListEntity>[];

            return _buildContent(context, header, items);
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    HeaderMetricsEntity? header,
    List<MaintenancesListEntity> items,
  ) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMachineHeader(context, header),
              const SizedBox(height: 20),
              _buildSectionHeader(context),
              const SizedBox(height: 12),
              if (items.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      'Sin solicitudes de mantenimiento',
                      style:
                          TextStyle(color: TColors.appSecondaryTextColor),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) =>
                      _MaintenanceItemCard(item: items[index]),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMachineHeader(
      BuildContext context, HeaderMetricsEntity? header) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Imagen + badge de estado
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                height: 220,
                color: TColors.appSurfaceColor,
                child: header?.photoUrl != null && header!.photoUrl.isNotEmpty
                    ? FadeInImage.assetNetwork(
                        placeholder: AssetImageApp.getIconLoading,
                        image: header.photoUrl,
                        fit: BoxFit.cover,
                        imageErrorBuilder: (_, __, err) => const Center(
                          child: Icon(Icons.image_not_supported,
                              size: 48, color: TColors.appDisabledColor),
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.image_not_supported,
                            size: 48, color: TColors.appDisabledColor),
                      ),
              ),
            ),
            if (header != null)
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor(header.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    header.status,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: TColors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        // Nombre + ícono
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    header?.name ?? '—',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: TColors.appMainTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    header != null
                        ? '${header.uniqueCode} • ${header.type}'
                        : '—',
                    style: const TextStyle(
                        fontSize: 15, color: TColors.appDisabledColor),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TColors.primaryLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.precision_manufacturing,
                  color: TColors.primary, size: 28),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Botón solicitud
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () async {
              await context.router.push(
                  RequestMaintenanceRoute(machineId: widget.machineId));
            },
            icon: const Icon(Icons.build, color: TColors.white, size: 24),
            label: const Text(
              'Solicitud de Mantenimiento',
              style: TextStyle(
                  color: TColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: TColors.appMainDarkColor,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Historial de Solicitudes',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: TColors.appMainTextColor,
          ),
        ),
        GestureDetector(
          onTap: () => context.router.push(
              MaintenanceRequestHistoryRoute(machineId: widget.machineId)),
          child: const Text(
            'Ver todo',
            style: TextStyle(
              fontSize: 17,
              color: TColors.appMainColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVO':
        return TColors.green;
      case 'EN MANTENIMIENTO':
        return TColors.warning;
      default:
        return TColors.danger;
    }
  }
}

class _MaintenanceItemCard extends StatelessWidget {
  final MaintenancesListEntity item;

  const _MaintenanceItemCard({required this.item});

  ({Color bg, Color text, IconData icon, Color iconBg, Color iconColor, String label})
      _styleFor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETADO':
        return (
          bg: TColors.successLight,
          text: TColors.success,
          icon: Icons.history,
          iconBg: TColors.successLight,
          iconColor: TColors.success,
          label: 'Completado',
        );
      case 'EN PROCESO':
        return (
          bg: TColors.warningLight,
          text: TColors.warning,
          icon: Icons.access_time,
          iconBg: TColors.warningLight,
          iconColor: TColors.warning,
          label: 'EN PROCESO',
        );
      case 'PENDIENTE':
        return (
          bg: TColors.warningLight,
          text: TColors.warning,
          icon: Icons.warning_amber_rounded,
          iconBg: TColors.warningLight,
          iconColor: TColors.warning,
          label: 'PENDIENTE',
        );
      case 'RECHAZADO':
        return (
          bg: TColors.dangerLight,
          text: TColors.danger,
          icon: Icons.cancel_outlined,
          iconBg: TColors.dangerLight,
          iconColor: TColors.danger,
          label: 'RECHAZADO',
        );
      default:
        return (
          bg: TColors.appSurfaceColor,
          text: TColors.appDisabledColor,
          icon: Icons.pending_outlined,
          iconBg: TColors.appSurfaceColor,
          iconColor: TColors.appDisabledColor,
          label: status,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(item.status);
    final date = DateFormat('dd MMM yyyy', 'es').format(item.date);
    final title = item.failureType.replaceAll('_', ' ');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: TColors.border, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: style.iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(style.icon, color: style.iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: TColors.appMainTextColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$date • S/ ${item.estimatedAmount}',
                  style: const TextStyle(
                      fontSize: 14,
                      color: TColors.appSecondaryTextColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: style.bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              style.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: style.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
