import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/core/widgets/app_network_image.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/machinery/domain/entity/entity.dart';
import 'package:front_gestion_minera/modules/machinery/presentation/bloc/machinery_bloc.dart';
import 'package:front_gestion_minera/modules/machinery/presentation/machinery_signals.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/staff_ui.dart';
import 'package:intl/intl.dart';
import 'package:front_gestion_minera/utils/session/user_session.dart';

import '../../../../utils/constants/color.constant.dart';

@RoutePage()
class DetailMachineryScreen extends StatefulWidget {
  final String machineId;

  const DetailMachineryScreen({super.key, required this.machineId});

  @override
  State<DetailMachineryScreen> createState() => _DetailMachineryScreenState();
}

class _DetailMachineryScreenState extends State<DetailMachineryScreen> {
  late MachineryBloc _machineryBloc;

  HeaderMetricsEntity? _cacheHeader;
  List<MaintenancesListEntity> _cacheItems = [];
  int _cacheTotal = 0;

  String _role = '';
  bool get _isJefe => _role == 'jefe_maquinas';

  @override
  void initState() {
    super.initState();
    _loadRole();
    _machineryBloc = InjectorContainer.getIt<MachineryBloc>()
      ..add(GetCloseUpOfAMachineEvent(machineId: widget.machineId));
  }

  @override
  void dispose() {
    _machineryBloc.close();
    super.dispose();
  }

  Future<void> _loadRole() async {
    final role = await UserSession.getRole();
    if (mounted) setState(() => _role = role);
  }

  void _reload() => _machineryBloc
      .add(GetCloseUpOfAMachineEvent(machineId: widget.machineId));

  Future<void> _openEdit(HeaderMetricsEntity header) async {
    final updated = await context.router.push(
      EditMachineryRoute(
        machineId: header.machineId,
        name: header.name,
        description: header.description,
        typeCode: header.typeCode,
        photoUrl: header.photoUrl,
      ),
    );
    if (updated == true) _reload();
  }

  Future<void> _openChangeStatus(
    BuildContext context,
    HeaderMetricsEntity header,
  ) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: TColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => _StatusSheet(current: header.status),
    );
    if (selected != null && selected != header.status.toUpperCase()) {
      _machineryBloc.add(
        ChangeMachineryStatusEvent(
          machineId: header.machineId,
          status: selected,
        ),
      );
    }
  }

  void _snack(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _secondaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: TColors.textPrimary,
        backgroundColor: TColors.white,
        side: const BorderSide(color: TColors.border),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      icon: Icon(icon, size: 18, color: TColors.appMainColor),
      label: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
    );
  }

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
          title: const Text(
            'Detalle de maquinaria',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: TColors.textPrimary,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: TColors.border),
          ),
        ),
        body: BlocConsumer<MachineryBloc, MachineryState>(
          listenWhen: (_, c) =>
              c is ChangeMachineryStatusSuccess ||
              c is ChangeMachineryStatusError ||
              c is GetCloseUpOfAMachineError,
          listener: (context, state) {
            if (state is ChangeMachineryStatusSuccess) {
              // Actualización optimista global: el home/listado se reflejan al
              // instante sin esperar la recarga de red.
              machineryStatusChangedSignal.value = MachineryStatusChange(
                machineId: widget.machineId,
                status: state.status,
              );
              _reload();
              _snack(context, 'Estado actualizado correctamente',
                  TColors.success);
            } else if (state is ChangeMachineryStatusError) {
              _snack(context, state.message, TColors.danger);
            } else if (state is GetCloseUpOfAMachineError &&
                _cacheHeader != null) {
              // Falló una recarga, pero ya hay datos visibles: avisamos sin
              // tumbar la pantalla a estado de error.
              _snack(context, state.message, TColors.danger);
            }
          },
          buildWhen: (_, c) =>
              c is GetCloseUpOfAMachineLoading ||
              c is GetCloseUpOfAMachineLoaded ||
              c is GetCloseUpOfAMachineError ||
              c is ChangeMachineryStatusLoading ||
              c is ChangeMachineryStatusSuccess ||
              c is ChangeMachineryStatusError,
          builder: (context, state) {
            if (state is GetCloseUpOfAMachineLoaded) {
              _cacheHeader = state.headerMetrics;
              _cacheItems = state.items;
              _cacheTotal = state.totalRecords;
            }

            // Aún sin datos: skeleton mientras carga, error solo si falló la
            // primera carga (no hay nada en caché que mostrar).
            if (_cacheHeader == null) {
              if (state is GetCloseUpOfAMachineError) {
                return _DetailError(message: state.message, onRetry: _reload);
              }
              return const _DetailSkeleton();
            }

            final changing = state is ChangeMachineryStatusLoading;

            return Stack(
              children: [
                _buildContent(
                    context, _cacheHeader!, _cacheItems, _cacheTotal),
                if (changing)
                  const StaffSubmitOverlay(label: 'Actualizando estado'),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    HeaderMetricsEntity header,
    List<MaintenancesListEntity> items,
    int total,
  ) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroImage(photoUrl: header.photoUrl, status: header.status),
            const SizedBox(height: 16),
            _TitleBlock(
              name: header.name,
              code: header.uniqueCode,
              type: header.type,
            ),
            const SizedBox(height: 16),
            _StatsBlock(
              cost: header.totalMaintenanceCost,
              registeredAt: header.registeredAt,
              requestsCount: total,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton.icon(
                onPressed: () async {
                  final created = await context.router.push(
                      RequestMaintenanceRoute(machineId: widget.machineId));
                  if (created == true) _reload();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: TColors.appMainColor,
                  foregroundColor: TColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.build_rounded, size: 20),
                label: const Text(
                  'Solicitar mantenimiento',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            if (_isJefe) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _secondaryButton(
                      icon: Icons.edit_outlined,
                      label: 'Editar',
                      onTap: () => _openEdit(header),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _secondaryButton(
                      icon: Icons.swap_horiz_rounded,
                      label: 'Cambiar estado',
                      onTap: () => _openChangeStatus(context, header),
                    ),
                  ),
                ],
              ),
            ],
            if (header.description.trim().isNotEmpty) ...[
              const SizedBox(height: 22),
              _DescriptionCard(description: header.description),
            ],
            const SizedBox(height: 24),
            _HistoryHeader(
              count: total,
              onSeeAll: () => context.router.push(
                MaintenanceRequestHistoryRoute(machineId: widget.machineId),
              ),
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              const _EmptyHistory()
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) =>
                    _MaintenanceItemCard(item: items[index]),
              ),
          ],
        ),
      ),
    );
  }
}

/// Hoja inferior para elegir el nuevo estado de la máquina.
class _StatusSheet extends StatelessWidget {
  final String current;

  const _StatusSheet({required this.current});

  @override
  Widget build(BuildContext context) {
    final cur = current.toUpperCase();
    final options = <({String value, String label, Color color, IconData icon})>[
      (
        value: 'ACTIVO',
        label: 'Activo',
        color: TColors.success,
        icon: Icons.check_circle_rounded,
      ),
      (
        value: 'INACTIVO',
        label: 'Inactivo',
        color: TColors.danger,
        icon: Icons.cancel_rounded,
      ),
      (
        value: 'EN MANTENIMIENTO',
        label: 'En mantenimiento',
        color: TColors.warning,
        icon: Icons.build_rounded,
      ),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: TColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Cambiar estado',
              style: TextStyle(
                color: TColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Selecciona el nuevo estado de la máquina.',
              style: TextStyle(color: TColors.textSecondary, fontSize: 12.5),
            ),
            const SizedBox(height: 16),
            ...options.map((o) {
              final selected = o.value == cur;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(o.value),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: selected
                          ? o.color.withValues(alpha: 0.10)
                          : TColors.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? o.color.withValues(alpha: 0.6)
                            : TColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: o.color.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Icon(o.icon, color: o.color, size: 21),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            o.label,
                            style: const TextStyle(
                              color: TColors.textPrimary,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (selected)
                          Icon(Icons.check_circle_rounded,
                              color: o.color, size: 20),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}


/// Formatea un entero como monto en bolivianos con separadores de miles.
String _money(int value) {
  final s = value.abs().toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return '${value < 0 ? '-' : ''}${buf.toString()} Bs';
}

String _titleCase(String raw) {
  final clean = raw.replaceAll('_', ' ').trim().toLowerCase();
  if (clean.isEmpty) return 'Mantenimiento';
  return clean[0].toUpperCase() + clean.substring(1);
}

({Color color, Color bg, IconData icon}) _machineStatusStyle(String status) {
  switch (status.toUpperCase()) {
    case 'ACTIVO':
      return (
        color: TColors.success,
        bg: TColors.successLight,
        icon: Icons.check_circle_rounded,
      );
    case 'EN MANTENIMIENTO':
      return (
        color: TColors.warning,
        bg: TColors.warningLight,
        icon: Icons.build_rounded,
      );
    default:
      return (
        color: TColors.danger,
        bg: TColors.dangerLight,
        icon: Icons.cancel_rounded,
      );
  }
}

/// Imagen principal con degradado inferior y badge de estado superpuesto.
class _HeroImage extends StatelessWidget {
  final String photoUrl;
  final String status;

  const _HeroImage({required this.photoUrl, required this.status});

  @override
  Widget build(BuildContext context) {
    final st = _machineStatusStyle(status);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          AppNetworkImage(
            url: photoUrl,
            width: double.infinity,
            height: 220,
            errorIcon: Icons.image_not_supported_rounded,
            errorIconSize: 48,
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                  colors: [
                    Colors.black.withValues(alpha: 0.28),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: st.color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(st.icon, color: TColors.white, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    status.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: TColors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Nombre + código • tipo + icono.
class _TitleBlock extends StatelessWidget {
  final String name;
  final String code;
  final String type;

  const _TitleBlock({
    required this.name,
    required this.code,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: TColors.textPrimary,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.tag_rounded,
                      size: 14, color: TColors.textSecondary),
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text(
                      '$code  ·  $type',
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: TColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: TColors.primaryLight,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.precision_manufacturing_rounded,
            color: TColors.appMainColor,
            size: 26,
          ),
        ),
      ],
    );
  }
}

/// Costo total (destacado) + fecha de registro + número de solicitudes.
class _StatsBlock extends StatelessWidget {
  final int cost;
  final DateTime registeredAt;
  final int requestsCount;

  const _StatsBlock({
    required this.cost,
    required this.registeredAt,
    required this.requestsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: TColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.payments_rounded,
                    color: TColors.appMainColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Costo total en mantenimiento',
                      style: TextStyle(
                        color: TColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _money(cost),
                      style: const TextStyle(
                        color: TColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _MiniStat(
                  icon: Icons.event_rounded,
                  label: 'Registrada',
                  value: DateFormat('dd MMM yyyy', 'es').format(registeredAt),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStat(
                  icon: Icons.assignment_rounded,
                  label: 'Solicitudes',
                  value: requestsCount.toString(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: TColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: TColors.appMainColor, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: TColors.textPrimary,
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: TColors.textSecondary,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Descripción técnica de la unidad.
class _DescriptionCard extends StatelessWidget {
  final String description;

  const _DescriptionCard({required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.description_outlined,
                  size: 16, color: TColors.textSecondary),
              SizedBox(width: 6),
              Text(
                'Descripción técnica',
                style: TextStyle(
                  color: TColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              color: TColors.textPrimary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Cabecera de la sección de historial.
class _HistoryHeader extends StatelessWidget {
  final int count;
  final VoidCallback onSeeAll;

  const _HistoryHeader({required this.count, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Historial de solicitudes',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: TColors.textPrimary,
          ),
        ),
        const Spacer(),
        if (count > 0)
          GestureDetector(
            onTap: onSeeAll,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: const [
                Text(
                  'Ver todo',
                  style: TextStyle(
                    fontSize: 13,
                    color: TColors.appMainColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 2),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 12, color: TColors.appMainColor),
              ],
            ),
          ),
      ],
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: TColors.successLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified_rounded,
                color: TColors.success, size: 28),
          ),
          const SizedBox(height: 12),
          const Text(
            'Sin solicitudes de mantenimiento',
            style: TextStyle(
              color: TColors.textPrimary,
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Esta unidad no tiene mantenimientos registrados.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: TColors.textSecondary,
              fontSize: 12.5,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _MaintenanceItemCard extends StatelessWidget {
  final MaintenancesListEntity item;

  const _MaintenanceItemCard({required this.item});

  ({Color color, Color bg, IconData icon, String label}) _styleFor(
      String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETADO':
        return (
          color: TColors.success,
          bg: TColors.successLight,
          icon: Icons.check_circle_rounded,
          label: 'Completado',
        );
      case 'EN PROCESO':
        return (
          color: TColors.appMainColor,
          bg: TColors.primaryLight,
          icon: Icons.autorenew_rounded,
          label: 'En proceso',
        );
      case 'PENDIENTE':
        return (
          color: TColors.warning,
          bg: TColors.warningLight,
          icon: Icons.schedule_rounded,
          label: 'Pendiente',
        );
      case 'RECHAZADO':
        return (
          color: TColors.danger,
          bg: TColors.dangerLight,
          icon: Icons.cancel_rounded,
          label: 'Rechazado',
        );
      default:
        return (
          color: TColors.textSecondary,
          bg: TColors.background,
          icon: Icons.help_outline_rounded,
          label: status,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(item.status);
    final date = DateFormat('dd MMM yyyy', 'es').format(item.date);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: style.bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(style.icon, color: style.color, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _titleCase(item.failureType),
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: TColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.event_rounded,
                        size: 12.5, color: TColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: TColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.payments_outlined,
                        size: 12.5, color: TColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      _money(item.estimatedAmount),
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: TColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: style.bg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              style.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: style.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Estado de error con reintento.
class _DetailError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DetailError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: TColors.dangerLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_off_rounded,
                  color: TColors.danger, size: 30),
            ),
            const SizedBox(height: 16),
            const Text(
              'No se pudo cargar el detalle',
              style: TextStyle(
                color: TColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: TColors.textSecondary,
                fontSize: 13,
                height: 1.4,
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

/// Skeleton de carga que refleja la estructura del detalle.
class _DetailSkeleton extends StatefulWidget {
  const _DetailSkeleton();

  @override
  State<_DetailSkeleton> createState() => _DetailSkeletonState();
}

class _DetailSkeletonState extends State<_DetailSkeleton>
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
        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _bone(c, height: 220, radius: 20),
              const SizedBox(height: 16),
              _bone(c, width: 200, height: 22, radius: 6),
              const SizedBox(height: 8),
              _bone(c, width: 140, height: 13, radius: 6),
              const SizedBox(height: 16),
              _bone(c, height: 76, radius: 16),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _bone(c, height: 86, radius: 16)),
                  const SizedBox(width: 12),
                  Expanded(child: _bone(c, height: 86, radius: 16)),
                ],
              ),
              const SizedBox(height: 16),
              _bone(c, height: 54, radius: 16),
              const SizedBox(height: 24),
              _bone(c, width: 180, height: 17, radius: 6),
              const SizedBox(height: 14),
              _cardBone(c),
              _cardBone(c),
              _cardBone(c),
            ],
          ),
        );
      },
    );
  }

  Widget _bone(
    Color c, {
    double? width,
    required double height,
    double radius = 6,
  }) {
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
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TColors.border),
      ),
      child: Row(
        children: [
          _bone(c, width: 42, height: 42, radius: 12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _bone(c, width: 140, height: 13, radius: 6),
                const SizedBox(height: 8),
                _bone(c, width: 100, height: 11, radius: 6),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _bone(c, width: 60, height: 22, radius: 20),
        ],
      ),
    );
  }
}
