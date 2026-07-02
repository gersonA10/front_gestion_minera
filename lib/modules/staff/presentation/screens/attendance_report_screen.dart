
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/staff/domain/entity/attendance_report_entity.dart';
import 'package:front_gestion_minera/modules/staff/presentation/bloc/staff_bloc.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/staff_ui.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:front_gestion_minera/utils/date_util.dart';

/// Reporte de asistencia (semanal/mensual) de un trabajador. Pantalla simple
/// (sin @RoutePage); se navega con MaterialPageRoute desde el perfil.
class AttendanceReportScreen extends StatefulWidget {
  final String employeeId;
  final String employeeName;

  const AttendanceReportScreen({
    super.key,
    required this.employeeId,
    this.employeeName = '',
  });

  @override
  State<AttendanceReportScreen> createState() => _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen> {
  late final StaffBloc _bloc;
  String _period = 'weekly';

  @override
  void initState() {
    super.initState();
    _bloc = InjectorContainer.getIt<StaffBloc>();
    _load();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _load() {
    _bloc.add(GetAttendanceReportEvent(
      employeeId: widget.employeeId,
      period: _period,
    ));
  }

  void _setPeriod(String period) {
    if (_period == period) return;
    setState(() => _period = period);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StaffUi.background,
      appBar: staffAppBar(context, title: 'Reporte de asistencia'),
      body: BlocProvider.value(
        value: _bloc,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
              child: _PeriodToggle(period: _period, onChanged: _setPeriod),
            ),
            Expanded(
              child: BlocBuilder<StaffBloc, StaffState>(
                buildWhen: (_, s) =>
                    s is AttendanceReportLoading ||
                    s is AttendanceReportLoaded ||
                    s is AttendanceReportError,
                builder: (context, state) {
                  if (state is AttendanceReportLoading) {
                    return const StaffLoader();
                  }
                  if (state is AttendanceReportError) {
                    return StaffErrorState(
                        message: state.message, onRetry: _load);
                  }
                  if (state is AttendanceReportLoaded) {
                    return _ReportBody(
                      report: state.report,
                      fallbackName: widget.employeeName,
                      onRefresh: () async => _load(),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodToggle extends StatelessWidget {
  final String period;
  final ValueChanged<String> onChanged;
  const _PeriodToggle({required this.period, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: StaffUi.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: StaffUi.border),
      ),
      child: Row(
        children: [
          Expanded(child: _seg('Semana', 'weekly')),
          Expanded(child: _seg('Mes', 'monthly')),
        ],
      ),
    );
  }

  Widget _seg(String label, String value) {
    final active = period == value;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? StaffUi.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : StaffUi.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ReportBody extends StatelessWidget {
  final AttendanceReportEntity report;
  final String fallbackName;
  final Future<void> Function() onRefresh;
  const _ReportBody({
    required this.report,
    required this.fallbackName,
    required this.onRefresh,
  });

  String _rangeLabel() {
    try {
      final from = formatDate(DateTime.parse(report.range.from));
      final to = formatDate(DateTime.parse(report.range.to));
      return '$from  –  $to';
    } catch (_) {
      return '${report.range.from} – ${report.range.to}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = report.employee.fullName.trim().isNotEmpty
        ? report.employee.fullName
        : fallbackName;

    return RefreshIndicator(
      color: StaffUi.primary,
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          _SummaryHeader(
            name: name,
            position: report.employee.position,
            totalMinutes: report.totals.totalMinutes,
            rangeLabel: _rangeLabel(),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: StaffMetricTile(
                  value: '${report.totals.daysWorked}',
                  title: 'Días trabajados',
                  icon: Icons.event_available_rounded,
                  color: StaffUi.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StaffMetricTile(
                  value: '${report.totals.incidentCount}',
                  title: 'Jornadas cortas',
                  helper: 'Menos de 8h netas',
                  icon: Icons.hourglass_bottom_rounded,
                  color: StaffUi.textSecondary,
                ),
              ),
            ],
          ),
          if (report.totals.openShifts > 0) ...[
            const SizedBox(height: 12),
            _OpenShiftsNote(count: report.totals.openShifts),
          ],
          const SizedBox(height: 22),
          StaffSectionTitle(
            'Detalle por día',
            icon: Icons.calendar_month_rounded,
            trailing: '${report.days.length}',
          ),
          const SizedBox(height: 12),
          if (report.days.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: StaffEmptyState(
                icon: Icons.event_busy_rounded,
                title: 'Sin asistencias',
                message:
                    'No hay registros de asistencia para este período.',
              ),
            )
          else
            for (final day in report.days) ...[
              _DayCard(day: day),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

/// Encabezado con gradiente: trabajador + total de horas + rango.
class _SummaryHeader extends StatelessWidget {
  final String name;
  final String position;
  final int totalMinutes;
  final String rangeLabel;
  const _SummaryHeader({
    required this.name,
    required this.position,
    required this.totalMinutes,
    required this.rangeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [StaffUi.primary, StaffUi.primaryDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: StaffUi.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name.isEmpty ? 'Trabajador' : name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          if (position.trim().isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              position,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12.5,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _fmtHm(totalMinutes),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'horas efectivas',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.date_range_rounded,
                  color: Colors.white, size: 15),
              const SizedBox(width: 6),
              Text(
                rangeLabel,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OpenShiftsNote extends StatelessWidget {
  final int count;
  const _OpenShiftsNote({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TColors.statusOrangeBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TColors.statusOrange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.timelapse_rounded,
              color: TColors.statusOrange, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$count turno(s) sin salida registrada en el período.',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: TColors.statusOrange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final AttendanceReportDay day;
  const _DayCard({required this.day});

  @override
  Widget build(BuildContext context) {
    final inOut = day.isOpen
        ? '${day.checkInTime ?? '--:--'}  →  En curso'
        : '${day.checkInTime ?? '--:--'}  →  ${day.checkOutTime ?? '--:--'}';

    return StaffCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          _DateBadge(date: day.date),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        inOut,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: StaffUi.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _statusPill(day),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded,
                        size: 13, color: StaffUi.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      _fmtHm(day.totalWorkedMinutes),
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: StaffUi.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.restaurant_rounded,
                        size: 13, color: StaffUi.muted),
                    const SizedBox(width: 4),
                    Text(
                      day.breakMinutes == 0
                          ? 'Sin refrigerio'
                          : '${day.breakMinutes} min',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: StaffUi.muted,
                      ),
                    ),
                  ],
                ),
                if (day.hasIncident && !day.isOpen) ...[
                  const SizedBox(height: 8),
                  const StaffPill(
                    label: 'Jornada corta · menos de 8h netas',
                    color: StaffUi.textSecondary,
                    bg: TColors.statusGreyBg,
                    icon: Icons.info_outline_rounded,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Estado principal = si el turno está cerrado (Finalizado) o en curso. La marca
  // "Por revisar" (jornada < 8h) se muestra aparte, no reemplaza a "Finalizado".
  Widget _statusPill(AttendanceReportDay day) {
    if (day.isOpen) {
      return const StaffPill(
        label: 'En curso',
        color: StaffUi.primary,
        bg: StaffUi.primarySoft,
        icon: Icons.timelapse_rounded,
      );
    }
    return const StaffPill(
      label: 'Finalizado',
      color: TColors.statusGreen,
      bg: TColors.statusGreenBg,
      icon: Icons.check_circle_rounded,
    );
  }
}

/// Insignia de fecha: día grande + mes corto.
class _DateBadge extends StatelessWidget {
  final String date; // YYYY-MM-DD
  const _DateBadge({required this.date});

  @override
  Widget build(BuildContext context) {
    String day = '--';
    String month = '';
    try {
      final d = DateTime.parse(date);
      const months = [
        'ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN',
        'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC',
      ];
      day = d.day.toString().padLeft(2, '0');
      month = months[d.month - 1];
    } catch (_) {}

    return Container(
      width: 50,
      height: 54,
      decoration: BoxDecoration(
        color: StaffUi.primarySoft,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: StaffUi.primary,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            month,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: StaffUi.primary,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

String _fmtHm(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return '${m}m';
  if (m == 0) return '${h}h';
  return '${h}h ${m.toString().padLeft(2, '0')}m';
}
