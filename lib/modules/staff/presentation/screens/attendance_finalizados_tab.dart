import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

enum FinalizadoStatus { finalizado, revision }

class FinalizadoWorker {
  final String idEmployee;
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
    required this.idEmployee,
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

class AttendanceFinalizadosTab extends StatelessWidget {
  final List<FinalizadoWorker> workers;
  final String totalHours;
  final String totalMinutes;
  final DateTime selectedDate;
  final void Function(DateTime) onDateChanged;
  final bool isLoading;
  final String? errorMessage;

  const AttendanceFinalizadosTab({
    super.key,
    required this.workers,
    required this.selectedDate,
    required this.onDateChanged,
    this.totalHours = '0',
    this.totalMinutes = '00',
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        children: [
          _buildSummaryCard(),
          const SizedBox(height: 20),
          _buildDateRow(context),
          const SizedBox(height: 14),
          Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _FinalizadoWorkerCard(worker: FinalizadoWorker(
                  idEmployee: 'c114811a-ec1c-45ca-84c6-6a9d2aa128ad',
                  name: 'Pedro Tintaya',
                  shift: 'Mañana',
                  department: 'Extracción',
                  entryTime: '08:00',
                  exitTime: '16:45',
                  totalTime: '8h 45m',
                  totalTimeColor: TColors.success,
                  status: FinalizadoStatus.finalizado,
                  avatarColor: TColors.primary,
                  initials: 'JP',
                )),
              ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: CircularProgressIndicator(),
            )
          else if (errorMessage != null)
            _buildErrorState(errorMessage!)
          else if (workers.isEmpty)
            _buildEmptyState()
          else
            ...workers.map(
              (w) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _FinalizadoWorkerCard(worker: w),
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
                totalHours,
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
                  totalMinutes,
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

  Widget _buildDateRow(BuildContext context) {
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
              initialDate: selectedDate,
              firstDate: DateTime(2023),
              lastDate: DateTime.now(),
            );
            if (picked != null) onDateChanged(picked);
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
                _formatDate(selectedDate),
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
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
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

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

// ─── Finalizado Worker Card ───────────────────────────────────────────────────

class _FinalizadoWorkerCard extends StatelessWidget {
  final FinalizadoWorker worker;

  const _FinalizadoWorkerCard({required this.worker});

  @override
  Widget build(BuildContext context) {
    final isRevision = worker.status == FinalizadoStatus.revision;

    return InkWell(
      onTap: () {
        context.router.push(AssistanceDetailRoute(attendanceId: worker.idEmployee)); // cambiar por attendanceId cuando el modelo y entity reciban attendanceId
      },
      child: Container(
        decoration: BoxDecoration(
          color: TColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: TColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                children: [
                  _buildAvatar(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          worker.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: TColors.profileDarkText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${worker.shift} • ${worker.department}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: TColors.profileMutedLabel,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(isRevision),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: TColors.border),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Entrada',
                          style: TextStyle(
                            fontSize: 11,
                            color: TColors.profileMutedLabel,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          worker.entryTime,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: TColors.profileDarkText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: TColors.profileMutedLabel,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Salida',
                          style: TextStyle(
                            fontSize: 11,
                            color: TColors.profileMutedLabel,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          worker.exitTime,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: TColors.profileDarkText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tiempo total trabajado',
                    style: TextStyle(
                      fontSize: 12,
                      color: TColors.profileMutedLabel,
                    ),
                  ),
                  Text(
                    worker.totalTime,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: worker.totalTimeColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: worker.avatarColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        worker.initials,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isRevision) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isRevision ? TColors.warningLight : TColors.successLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isRevision ? 'Revisión' : 'Finalizado',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isRevision ? TColors.warning : TColors.success,
            ),
          ),
          if (isRevision) ...[
            const SizedBox(width: 3),
            Icon(Icons.warning_amber_rounded, size: 12, color: TColors.warning),
          ],
        ],
      ),
    );
  }
}
