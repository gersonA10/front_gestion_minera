import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import '../widgets/widgets.dart';

class IngresoWorker {
  final String employeeId;
  final String name;
  final String role;
  final String scheduledTime;
  final bool isLate;

  const IngresoWorker({
    required this.name,
    required this.role,
    required this.scheduledTime,
    this.isLate = false,
    required this.employeeId,
  });
}

class AttendanceIngresoTab extends StatefulWidget {
  final List<IngresoWorker> workers;
  final Set<String> registered;
  final void Function(String) onRegister;
  final bool isLoading;
  final String? errorMessage;

  const AttendanceIngresoTab({
    super.key,
    required this.workers,
    required this.registered,
    required this.onRegister,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  State<AttendanceIngresoTab> createState() => _AttendanceIngresoTabState();
}

class _AttendanceIngresoTabState extends State<AttendanceIngresoTab> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Re-evalúa la ventana de habilitación periódicamente para que el botón
    // se habilite solo cuando llega la hora, sin refrescar manualmente.
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pending = widget.workers
        .where((w) => !widget.registered.contains(w.name))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        children: [
          _buildStatsRow(pending.length),
          const SizedBox(height: 20),
          _buildHeader(pending.length),
          const SizedBox(height: 14),
          if (widget.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: CircularProgressIndicator(),
            )
          else if (widget.errorMessage != null)
            _buildErrorState(widget.errorMessage!)
          else if (pending.isEmpty)
            _buildEmptyState()
          else
            ...pending.map(
              (w) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: IngresoWorkerCard(
                  worker: w,
                  onRegister: () async {
                    final result = await context.router.push<bool>(
                      EmployeeEntryRegisterRoute(usuario: w),
                    );
                    if (result == true) {
                      widget.onRegister(w.name);
                    }
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(int pendingCount) {
    return Row(
      children: [
        Expanded(
          child: AttendanceStatCardWidget(
            label: 'Pendientes',
            value: '$pendingCount',
            valueLabel: 'Por ingresar',
            valueLabelColor: TColors.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AttendanceStatCardWidget(
            label: 'Turno Mañana',
            value: '07:00',
            valueLabel: 'Inicio',
            valueLabelColor: TColors.primary,
            valueFontSize: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(int count) {
    return Row(
      children: [
        const Text(
          'Pendientes de Ingreso',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: TColors.textSecondary,
          ),
        ),
        const Spacer(),
        if (count > 0)
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: TColors.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: TColors.white,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(Icons.check_circle_rounded, color: TColors.success, size: 40),
            SizedBox(height: 10),
            Text(
              'Todos registrados',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: TColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: TColors.warning,
              size: 40,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: TColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
