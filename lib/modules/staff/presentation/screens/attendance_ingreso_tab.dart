import 'package:flutter/material.dart';

import 'package:front_gestion_minera/utils/constants/color.constant.dart';

import '../widgets/widgets.dart';

class IngresoWorker {
  final String name;
  final String role;
  final String scheduledTime;
  final bool isLate;

  const IngresoWorker({
    required this.name,
    required this.role,
    required this.scheduledTime,
    this.isLate = false,
  });
}

class AttendanceIngresoTab extends StatelessWidget {
  final List<IngresoWorker> workers;
  final Set<String> registered;
  final void Function(String) onRegister;

  const AttendanceIngresoTab({
    super.key,
    required this.workers,
    required this.registered,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    final pending = workers.where((w) => !registered.contains(w.name)).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        children: [
          _buildStatsRow(pending.length),
          const SizedBox(height: 20),
          _buildHeader(pending.length),
          const SizedBox(height: 14),
          if (pending.isEmpty)
            _buildEmptyState()
          else
            ...pending.map(
              (w) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: IngresoWorkerCard(
                  worker: w,
                  onRegister: () => onRegister(w.name),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: const [
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
}

