import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/machinery/presentation/bloc/machinery_bloc.dart';
import 'package:front_gestion_minera/modules/machinery/presentation/widgets/detail_body_widget.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

@RoutePage()
class DetailMaintenanceScreen extends StatelessWidget {
  final String maintenanceId;

  const DetailMaintenanceScreen({super.key, required this.maintenanceId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InjectorContainer.getIt<MachineryBloc>()
        ..add(FetchDetailMaintenanceEvent(machineId: maintenanceId)),
      child: _DetailMaintenanceView(maintenanceId: maintenanceId),
    );
  }
}

class _DetailMaintenanceView extends StatelessWidget {
  final String maintenanceId;

  const _DetailMaintenanceView({required this.maintenanceId});

  void _retry(BuildContext context) {
    context
        .read<MachineryBloc>()
        .add(FetchDetailMaintenanceEvent(machineId: maintenanceId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.background,
      appBar: AppBar(
        backgroundColor: TColors.white,
        surfaceTintColor: TColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: TColors.textPrimary,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: const Text(
          'Detalle de mantenimiento',
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
      body: BlocBuilder<MachineryBloc, MachineryState>(
        buildWhen: (_, c) =>
            c is DetailMaintenanceLoading ||
            c is DetailMaintenanceLoaded ||
            c is DetailMaintenanceError,
        builder: (context, state) {
          if (state is DetailMaintenanceLoaded) {
            return DetailBody(detail: state.detail);
          }

          if (state is DetailMaintenanceError) {
            return _MaintenanceError(
              message: state.message,
              onRetry: () => _retry(context),
            );
          }

          // MachineryInitial + DetailMaintenanceLoading.
          return const _MaintenanceSkeleton();
        },
      ),
    );
  }
}

/// Estado de error con reintento.
class _MaintenanceError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _MaintenanceError({required this.message, required this.onRetry});

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
              'No se pudo cargar el mantenimiento',
              textAlign: TextAlign.center,
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
class _MaintenanceSkeleton extends StatefulWidget {
  const _MaintenanceSkeleton();

  @override
  State<_MaintenanceSkeleton> createState() => _MaintenanceSkeletonState();
}

class _MaintenanceSkeletonState extends State<_MaintenanceSkeleton>
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _bone(c, height: 250, radius: 16),
              const SizedBox(height: 20),
              _bone(c, width: 140, height: 16, radius: 6),
              const SizedBox(height: 12),
              _bone(c, height: 80, radius: 16),
              const SizedBox(height: 20),
              _bone(c, height: 72, radius: 16),
              const SizedBox(height: 20),
              _bone(c, width: 120, height: 16, radius: 6),
              const SizedBox(height: 16),
              _bone(c, height: 200, radius: 16),
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
}
