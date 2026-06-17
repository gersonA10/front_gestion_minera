import 'package:flutter/material.dart';
import 'package:front_gestion_minera/modules/staff/domain/entity/history_expenditure_response_entity.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

class EgresoDetailScreen extends StatelessWidget {
  final HistoryExpenditureEntity history;

  const EgresoDetailScreen({super.key, required this.history});

  static const _shortMonths = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
  ];

  /// Formatea una fecha del backend como "12 Oct 2023".
  /// Si no se puede parsear, devuelve la cadena original.
  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    final date = DateTime.tryParse(raw);
    if (date == null) return raw;
    return '${date.day} ${_shortMonths[date.month - 1]} ${date.year}';
  }

  /// Formatea fecha con hora como "12 Oct 2023 • 09:15 AM".
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

  String _formatAmount(double value) {
    final fixed = value.toStringAsFixed(2);
    final parts = fixed.split('.');
    final intPart = parts[0];
    final buffer = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buffer.write(',');
      buffer.write(intPart[i]);
    }
    return '\$$buffer.${parts[1]}';
  }

  _StatusStyle get _statusStyle {
    switch (history.status.toUpperCase()) {
      case 'APROBADO':
        return const _StatusStyle(
          'Aprobado', Icons.check_circle_outline, TColors.success);
      case 'PAGADO':
        return const _StatusStyle(
          'Pagado', Icons.check_circle_outline, TColors.success);
      case 'RECHAZADO':
        return const _StatusStyle('Rechazado', Icons.cancel_outlined, TColors.red);
      case 'PENDIENTE':
      default:
        return const _StatusStyle('Pendiente', Icons.access_time, TColors.amber);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = history.status.toUpperCase();
    final isApproved = status == 'APROBADO' || status == 'PAGADO';
    final isRejected = status == 'RECHAZADO';

    return Scaffold(
      backgroundColor: TColors.appBackgroundColor,
      appBar: AppBar(
        backgroundColor: TColors.white,
        title: const Text(
          'Detalle de Egreso',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: TColors.uploadBlue,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: TColors.uploadBlue),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
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
    final style = _statusStyle;
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
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: TColors.profileMutedLabel,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                history.payrollCycle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: TColors.appMainDarkColor,
                ),
              ),
            ],
          ),
        ),
        _StatusBadge(style: style),
      ],
    );
  }

  Widget _summaryCard({required bool isApproved, required bool isRejected}) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _amountColumn(
                  'Total Solicitado',
                  _formatAmount(history.totalRequested),
                  TColors.appMainDarkColor,
                ),
              ),
              Expanded(
                child: isApproved
                    ? _amountColumn(
                        'Monto Aprobado',
                        _formatAmount(history.approvedAmount),
                        TColors.success,
                      )
                    : isRejected
                        ? _amountColumn(
                            'Motivo',
                            history.rejectReason ?? 'No especificado',
                            TColors.red,
                            fontSize: 14,
                          )
                        : const SizedBox(),
              ),
            ],
          ),
          const Divider(height: 28, color: TColors.border),
          Row(
            children: [
              Expanded(
                child: _dateColumn(
                  Icons.calendar_today_outlined,
                  'Creado',
                  _formatDate(history.requestedDate),
                ),
              ),
              if (history.closedDate != null)
                Expanded(
                  child: _dateColumn(
                    Icons.verified_outlined,
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
            color: TColors.profileMutedLabel,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _dateColumn(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: TColors.profileMutedLabel),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: TColors.profileMutedLabel,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: TColors.profileBodyText,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _timelineCard({required bool isApproved, required bool isRejected}) {
    final style = _statusStyle;
    final steps = <_TimelineStep>[
      _TimelineStep(
        icon: Icons.outbox_outlined,
        title: 'Solicitado',
        subtitle: _formatDateTime(history.requestedDate),
        color: TColors.uploadBlue,
      ),
    ];

    if (history.closedDate != null) {
      steps.add(
        _TimelineStep(
          icon: style.icon,
          title: isApproved
              ? 'Aprobación Final'
              : isRejected
                  ? 'Rechazado'
                  : 'Finalizado',
          subtitle: _formatDateTime(history.closedDate),
          color: style.color,
        ),
      );
    }

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LÍNEA DE TIEMPO',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.4,
              color: TColors.uploadBlue,
            ),
          ),
          const SizedBox(height: 16),
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
                  color: step.color,
                  shape: BoxShape.circle,
                ),
                child: Icon(step.icon, size: 18, color: TColors.white),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: step.color),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 22, top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: TColors.appMainDarkColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  step.subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: TColors.profileMutedLabel,
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

class _StatusStyle {
  final String label;
  final IconData icon;
  final Color color;
  const _StatusStyle(this.label, this.icon, this.color);
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

class _StatusBadge extends StatelessWidget {
  final _StatusStyle style;
  const _StatusBadge({required this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: style.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, color: style.color, size: 16),
          const SizedBox(width: 5),
          Text(
            style.label,
            style: TextStyle(
              color: style.color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TColors.border),
      ),
      child: child,
    );
  }
}
