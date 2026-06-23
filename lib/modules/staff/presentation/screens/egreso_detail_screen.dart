import 'package:flutter/material.dart';
import 'package:front_gestion_minera/modules/staff/domain/entity/history_expenditure_response_entity.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/staff_ui.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:front_gestion_minera/utils/date_util.dart';

/// Pantalla de detalle de un egreso (no es @RoutePage: se abre con
/// [MaterialPageRoute] desde el historial). Solo presenta los datos del
/// [HistoryExpenditureEntity] recibido, alineada al kit premium del módulo.
class EgresoDetailScreen extends StatelessWidget {
  final HistoryExpenditureEntity history;

  const EgresoDetailScreen({super.key, required this.history});

  /// Formatea una fecha del backend como "12 OCT 2023" usando [formatDate].
  /// Si no se puede parsear, devuelve la cadena original (o "—" si vacía).
  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    final date = DateTime.tryParse(raw);
    if (date == null) return raw;
    return formatDate(date);
  }

  /// Formatea fecha con hora como "12 OCT 2023 • 09:15 AM".
  /// Omite la hora si el origen no la incluye (medianoche).
  String _formatDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    final date = DateTime.tryParse(raw);
    if (date == null) return raw;
    final base = _formatDate(raw);
    if (date.hour == 0 && date.minute == 0 && date.second == 0) return base;
    final isPm = date.hour >= 12;
    var hour12 = date.hour % 12;
    if (hour12 == 0) hour12 = 12;
    final minute = date.minute.toString().padLeft(2, '0');
    return '$base • ${hour12.toString().padLeft(2, '0')}:$minute ${isPm ? 'PM' : 'AM'}';
  }

  @override
  Widget build(BuildContext context) {
    final status = history.status.toUpperCase();
    final isApproved = status == 'APROBADO' || status == 'PAGADO';
    final isRejected = status == 'RECHAZADO';

    return Scaffold(
      backgroundColor: StaffUi.background,
      appBar: staffAppBar(context, title: 'Detalle de egreso'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          _header(),
          const SizedBox(height: 16),
          _summaryCard(isApproved: isApproved, isRejected: isRejected),
          const SizedBox(height: 16),
          _timelineCard(isApproved: isApproved, isRejected: isRejected),
        ],
      ),
    );
  }

  Widget _header() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CICLO DE NÓMINA',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: StaffUi.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                history.payrollCycle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: StaffUi.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        StaffPill.status(history.status, icon: _statusIcon),
      ],
    );
  }

  IconData get _statusIcon {
    final s = history.status.toUpperCase();
    if (s == 'APROBADO' || s == 'PAGADO') return Icons.check_circle_rounded;
    if (s == 'RECHAZADO') return Icons.cancel_rounded;
    return Icons.access_time_rounded;
  }

  Widget _summaryCard({required bool isApproved, required bool isRejected}) {
    return StaffCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _amountColumn(
                  'Total solicitado',
                  StaffUi.money2(history.totalRequested),
                  StaffUi.textPrimary,
                ),
              ),
              Expanded(
                child: isApproved
                    ? _amountColumn(
                        'Monto aprobado',
                        StaffUi.money2(history.approvedAmount),
                        TColors.statusGreen,
                      )
                    : isRejected
                        ? _amountColumn(
                            'Motivo',
                            history.rejectReason ?? 'No especificado',
                            const Color(0xFFEF4444),
                            fontSize: 14,
                          )
                        : const SizedBox(),
              ),
            ],
          ),
          const Divider(height: 28, color: StaffUi.border),
          Row(
            children: [
              Expanded(
                child: _dateColumn(
                  Icons.calendar_today_rounded,
                  'Creado',
                  _formatDate(history.requestedDate),
                ),
              ),
              if (history.closedDate != null)
                Expanded(
                  child: _dateColumn(
                    Icons.verified_rounded,
                    'Finalizado',
                    _formatDate(history.closedDate),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _amountColumn(String label, String value, Color color,
      {double fontSize = 18}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: StaffUi.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _dateColumn(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: StaffUi.muted),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: StaffUi.textSecondary,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: StaffUi.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _timelineCard({required bool isApproved, required bool isRejected}) {
    final steps = <_TimelineStep>[
      _TimelineStep(
        icon: Icons.outbox_rounded,
        title: 'Solicitado',
        subtitle: _formatDateTime(history.requestedDate),
        color: StaffUi.primary,
      ),
    ];

    if (history.closedDate != null) {
      final stepColor = isRejected ? const Color(0xFFEF4444) : StaffUi.primary;
      steps.add(
        _TimelineStep(
          icon: isApproved
              ? Icons.check_circle_rounded
              : isRejected
                  ? Icons.cancel_rounded
                  : Icons.flag_rounded,
          title: isApproved
              ? 'Aprobación final'
              : isRejected
                  ? 'Rechazado'
                  : 'Finalizado',
          subtitle: _formatDateTime(history.closedDate),
          color: stepColor,
        ),
      );
    }

    return StaffCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StaffSectionTitle(
            'Línea de tiempo',
            icon: Icons.timeline_rounded,
          ),
          const SizedBox(height: 18),
          for (var i = 0; i < steps.length; i++)
            _timelineRow(steps[i], isLast: i == steps.length - 1),
        ],
      ),
    );
  }

  Widget _timelineRow(_TimelineStep step, {required bool isLast}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: step.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(step.icon, size: 18, color: step.color),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: StaffUi.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 22, top: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: StaffUi.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  step.subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: StaffUi.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineStep {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  const _TimelineStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}
