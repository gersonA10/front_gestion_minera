import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

import '../widgets/widgets.dart';

enum FinalizadoStatus { finalizado, revision }

class FinalizadoWorker {
  final String name;
  final String shift;
  final String department;
  final String entryTime;
  final String exitTime;
  final String totalTime;
  final Color totalTimeColor;
  final FinalizadoStatus status;
  final Color avatarColor;
  final String initials;

  const FinalizadoWorker({
    required this.name,
    required this.shift,
    required this.department,
    required this.entryTime,
    required this.exitTime,
    required this.totalTime,
    required this.totalTimeColor,
    required this.status,
    required this.avatarColor,
    required this.initials,
  });
}

class AttendanceFinalizadosTab extends StatefulWidget {
  final List<FinalizadoWorker> workers;
  final String totalHours;
  final String totalMinutes;

  const AttendanceFinalizadosTab({
    super.key,
    required this.workers,
    this.totalHours = '0',
    this.totalMinutes = '00',
  });

  @override
  State<AttendanceFinalizadosTab> createState() =>
      _AttendanceFinalizadosTabState();
}

class _AttendanceFinalizadosTabState extends State<AttendanceFinalizadosTab> {
  DateTime _selectedDate = DateTime(2023, 10, 24);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        children: [
          _buildSummaryCard(),
          const SizedBox(height: 20),
          _buildDateRow(),
          const SizedBox(height: 14),
          if (widget.workers.isEmpty)
            _buildEmptyState()
          else
            ...widget.workers.map(
              (w) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: FinalizadoWorkerCard(worker: w),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A56FF), Color(0xFF0D3BB3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen del Día',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Total Horas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                widget.totalHours,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 1),
                child: Text(
                  widget.totalMinutes,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white70,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow() {
    return Row(
      children: [
        const Text(
          'Registros Completados',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: TColors.textSecondary,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2023),
              lastDate: DateTime.now(),
            );
            if (picked != null) setState(() => _selectedDate = picked);
          },
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 13,
                color: TColors.textSecondary,
              ),
              const SizedBox(width: 5),
              Text(
                _formatDate(_selectedDate),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: TColors.textSecondary,
                ),
              ),
            ],
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
            Icon(
              Icons.hourglass_empty_rounded,
              color: TColors.profileMutedLabel,
              size: 40,
            ),
            SizedBox(height: 10),
            Text(
              'Aún no hay turnos finalizados',
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

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

