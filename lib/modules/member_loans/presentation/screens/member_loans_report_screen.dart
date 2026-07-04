import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/staff_ui.dart';

import '../../domain/entity/member_loan_report_entity.dart';
import '../bloc/member_loans_report_bloc.dart';
import '../ui_kit.dart';

@RoutePage()
class MemberLoansReportScreen extends StatefulWidget {
  const MemberLoansReportScreen({super.key});

  @override
  State<MemberLoansReportScreen> createState() =>
      _MemberLoansReportScreenState();
}

class _MemberLoansReportScreenState extends State<MemberLoansReportScreen> {
  late final MemberLoansReportBloc _bloc;
  String _period = 'year';

  final _periods = const {
    'Semana': 'week',
    'Mes': 'month',
    'Año': 'year',
    'Todo': 'all',
  };

  @override
  void initState() {
    super.initState();
    _bloc = InjectorContainer.getIt<MemberLoansReportBloc>()
      ..add(MemberLoansReportFetch(period: _period));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _setPeriod(String p) {
    setState(() => _period = p);
    _bloc.add(MemberLoansReportFetch(period: p));
  }

  /// Etiqueta legible del periodo activo para el encabezado del reporte.
  String get _periodLabel {
    switch (_period) {
      case 'week':
        return 'Esta semana';
      case 'month':
        return 'Este mes';
      case 'year':
        return 'Este año';
      default:
        return 'Histórico';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MlColors.background,
      body: Column(
        children: [
          MlGradientHeader(
            title: 'Reporte de Préstamos',
            subtitle:
                'Capital que los socios prestaron a la empresa e interés pagado.',
            onBack: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(height: 12),
          _PeriodSelector(
            periods: _periods,
            active: _period,
            onTap: _setPeriod,
          ),
          const SizedBox(height: 4),
          Expanded(
            child: BlocBuilder<MemberLoansReportBloc, MemberLoansReportState>(
              bloc: _bloc,
              builder: (context, state) {
                if (state is MemberLoansReportLoading) {
                  return const Center(child: StaffLoader(),);
                }
                if (state is MemberLoansReportError) {
                  return MlStateView(
                    icon: Icons.cloud_off_rounded,
                    color: MlColors.red,
                    title: 'No pudimos cargar el reporte',
                    subtitle: state.message,
                  );
                }
                if (state is MemberLoansReportLoaded) {
                  return _ReportBody(
                    report: state.report,
                    periodLabel: _periodLabel,
                    onRefresh: () async =>
                        _bloc.add(MemberLoansReportFetch(period: _period)),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Selector de periodo ─────────────────────────────────────────────────────

class _PeriodSelector extends StatelessWidget {
  final Map<String, String> periods;
  final String active;
  final ValueChanged<String> onTap;
  const _PeriodSelector({
    required this.periods,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final entries = periods.entries.toList();
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: entries.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final e = entries[i];
          return MlChip(
            label: e.key,
            active: active == e.value,
            onTap: () => onTap(e.value),
          );
        },
      ),
    );
  }
}

// ─── Cuerpo del reporte ──────────────────────────────────────────────────────

class _ReportBody extends StatelessWidget {
  final MemberLoanReportEntity report;
  final String periodLabel;
  final Future<void> Function() onRefresh;
  const _ReportBody({
    required this.report,
    required this.periodLabel,
    required this.onRefresh,
  });

  bool get _isEmpty =>
      report.dinero.totalPrestado == 0 &&
      report.gramos.totalPrestado == 0 &&
      report.interesPorPeriodo.isEmpty &&
      report.porSocio.isEmpty &&
      report.proximosVencimientos.isEmpty;

  @override
  Widget build(BuildContext context) {
    if (_isEmpty) {
      return RefreshIndicator(
        color: MlColors.primary,
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 60),
            MlStateView(
              icon: Icons.assessment_outlined,
              color: MlColors.primary,
              title: 'Sin movimientos en este periodo',
              subtitle: 'Prueba con otro rango de fechas arriba.',
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: MlColors.primary,
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          _InterestHero(
            periodLabel: periodLabel,
            dinero: report.dinero.interesPagado,
            gramos: report.gramos.interesPagado,
          ),
          const SizedBox(height: 16),
          const _SectionLabel(
              'Capital recibido de socios', Icons.account_balance_wallet_rounded),
          const SizedBox(height: 10),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _CapitalCard(
                    title: 'Dinero',
                    unit: 'Bs',
                    unidad: report.dinero,
                    color: MlColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CapitalCard(
                    title: 'Oro',
                    unit: 'g',
                    unidad: report.gramos,
                    color: MlColors.goldDeep,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          _SectionLabel(
            'Interés pagado por mes',
            Icons.bar_chart_rounded,
            trailing: report.interesPorPeriodo.isNotEmpty
                ? '${report.interesPorPeriodo.length} meses'
                : null,
          ),
          const SizedBox(height: 10),
          if (report.interesPorPeriodo.isEmpty)
            const _Hint('Sin interés cobrado en el periodo.')
          else
            _InterestChart(items: report.interesPorPeriodo),
          const SizedBox(height: 22),
          _SectionLabel(
            'Préstamos por socio',
            Icons.groups_2_rounded,
            trailing: report.porSocio.isNotEmpty
                ? '${report.porSocio.length}'
                : null,
          ),
          const SizedBox(height: 10),
          if (report.porSocio.isEmpty)
            const _Hint('Sin datos por socio.')
          else
            ...report.porSocio.asMap().entries.map(
                  (e) => _SocioRow(rank: e.key + 1, item: e.value),
                ),
          const SizedBox(height: 22),
          _SectionLabel(
              'Próximos pagos de interés a socios', Icons.event_rounded),
          const SizedBox(height: 10),
          if (report.proximosVencimientos.isEmpty)
            const _Hint('No hay pagos de interés próximos.')
          else
            ...report.proximosVencimientos.map((e) => _VencRow(item: e)),
        ],
      ),
    );
  }
}

// ─── Card hero: interés pagado a socios ──────────────────────────────────────

class _InterestHero extends StatelessWidget {
  final String periodLabel;
  final double dinero;
  final double gramos;
  const _InterestHero({
    required this.periodLabel,
    required this.dinero,
    required this.gramos,
  });

  bool get _empty => dinero == 0 && gramos == 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [MlColors.primary, MlColors.primaryDeep],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: MlColors.primary.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.percent_rounded,
                    color: Colors.white, size: 19),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Interés pagado a socios',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  periodLabel,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_empty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                'Sin interés pagado en este periodo.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _heroUnit('DINERO', 'Bs ${mlNum(dinero)}'),
                ),
                Container(
                  width: 1,
                  height: 44,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: Colors.white.withValues(alpha: 0.18),
                ),
                Expanded(
                  child: _heroUnit('ORO', '${mlNum(gramos)} g'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _heroUnit(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.6,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ],
      );
}

// ─── Card de capital (Dinero / Oro) con barra de devolución ──────────────────

class _CapitalCard extends StatelessWidget {
  final String title;
  final String unit;
  final MemberLoanReportUnitEntity unidad;
  final Color color;
  const _CapitalCard({
    required this.title,
    required this.unit,
    required this.unidad,
    required this.color,
  });

  String _v(double v) => unit == 'Bs' ? 'Bs ${mlNum(v)}' : '${mlNum(v)} g';

  // Capital que la empresa ya devolvió al socio, sobre el total recibido.
  double get _returned => unidad.totalPrestado <= 0
      ? 0
      : (unidad.capitalPagado / unidad.totalPrestado).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final pct = (_returned * 100).round();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MlColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: MlColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  unit == 'Bs'
                      ? Icons.payments_rounded
                      : Icons.diamond_outlined,
                  color: color,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: MlColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text('Recibido',
              style: TextStyle(fontSize: 10.5, color: MlColors.textSecondary)),
          const SizedBox(height: 2),
          Text(
            _v(unidad.totalPrestado),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: MlColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 14),
          // Barra de devolución (devuelto / recibido).
          _Bar(
            frac: _returned,
            height: 7,
            trackColor: MlColors.green.withValues(alpha: 0.12),
            color: MlColors.green,
          ),
          const SizedBox(height: 6),
          Text(
            '$pct% devuelto',
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: MlColors.green,
            ),
          ),
          const SizedBox(height: 12),
          _kv('Por devolver', _v(unidad.capitalPendiente), MlColors.amber),
          const SizedBox(height: 5),
          _kv('Devuelto', _v(unidad.capitalPagado), MlColors.textPrimary),
        ],
      ),
    );
  }

  Widget _kv(String k, String v, Color valueColor) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(k,
                style: const TextStyle(
                    fontSize: 11, color: MlColors.textSecondary)),
          ),
          const SizedBox(width: 6),
          Text(v,
              style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: valueColor)),
        ],
      );
}

// ─── Gráfico de interés por mes ──────────────────────────────────────────────

class _InterestChart extends StatelessWidget {
  final List<MemberLoanInterestByPeriodEntity> items;
  const _InterestChart({required this.items});

  /// "2026-05" → "May 2026".
  static String _label(String periodo) {
    final parts = periodo.split('-');
    if (parts.length == 2) {
      final m = int.tryParse(parts[1]);
      if (m != null && m >= 1 && m <= 12) return '${mlMonths[m - 1]} ${parts[0]}';
    }
    return periodo;
  }

  @override
  Widget build(BuildContext context) {
    double maxD = 0, maxG = 0;
    for (final e in items) {
      if (e.dinero > maxD) maxD = e.dinero;
      if (e.gramos > maxG) maxG = e.gramos;
    }
    final hasGold = maxG > 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 6),
      decoration: BoxDecoration(
        color: MlColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MlColors.border),
      ),
      child: Column(
        children: [
          for (final e in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 62,
                    child: Text(
                      _label(e.periodo),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: MlColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (e.dinero > 0)
                          _BarLine(
                            frac: maxD == 0 ? 0 : e.dinero / maxD,
                            color: MlColors.primary,
                            value: 'Bs ${mlNum(e.dinero)}',
                          ),
                        if (e.dinero > 0 && e.gramos > 0)
                          const SizedBox(height: 5),
                        if (e.gramos > 0)
                          _BarLine(
                            frac: maxG == 0 ? 0 : e.gramos / maxG,
                            color: MlColors.goldDeep,
                            value: '${mlNum(e.gramos)} g',
                          ),
                        if (e.dinero == 0 && e.gramos == 0)
                          const _BarLine(
                            frac: 0,
                            color: MlColors.textSecondary,
                            value: '—',
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          // Leyenda
          Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 8),
            child: Row(
              children: [
                _legendDot(MlColors.primary, 'Dinero'),
                if (hasGold) ...[
                  const SizedBox(width: 14),
                  _legendDot(MlColors.goldDeep, 'Oro'),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color c, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: MlColors.textSecondary)),
        ],
      );
}

/// Barra de progreso simple: relleno proporcional + pista.
///
/// Implementada con `Row` + `Expanded` (sin `LayoutBuilder`, `Stack` ni
/// `Positioned`) para no tocar la geometría de semántica, que con esos widgets
/// dispara el assert `!semantics.parentDataDirty`.
class _Bar extends StatelessWidget {
  final double frac;
  final double height;
  final Color trackColor;
  final Color? color;
  final Gradient? gradient;
  const _Bar({
    required this.frac,
    required this.height,
    required this.trackColor,
    this.color,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final f = (frac.isNaN || frac <= 0) ? 0.0 : (frac > 1 ? 1.0 : frac);
    var filled = (f * 1000).round();
    if (f > 0 && filled < 30) filled = 30; // sliver mínimo visible
    final rest = 1000 - filled;

    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            if (filled > 0)
              Expanded(
                flex: filled,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: color, gradient: gradient),
                ),
              ),
            if (rest > 0)
              Expanded(flex: rest, child: ColoredBox(color: trackColor)),
          ],
        ),
      ),
    );
  }
}

class _BarLine extends StatelessWidget {
  final double frac;
  final Color color;
  final String value;
  const _BarLine({
    required this.frac,
    required this.color,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Bar(
            frac: frac,
            height: 8,
            trackColor: color.withValues(alpha: 0.10),
            gradient: LinearGradient(
              colors: [color, Color.lerp(color, Colors.white, 0.25)!],
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 78,
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Fila por socio ──────────────────────────────────────────────────────────

class _SocioRow extends StatelessWidget {
  final int rank;
  final MemberLoanBySocioEntity item;
  const _SocioRow({required this.rank, required this.item});

  static String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MlColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MlColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 20,
                child: Text(
                  '$rank',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: rank <= 3
                        ? MlColors.goldDeep
                        : MlColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [MlColors.primary, MlColors.primaryDeep],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _initials(item.socio),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.socio,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: MlColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Prestó ${item.vecesPresto} · Ofreció ${item.vecesOfrecio}',
                      style: const TextStyle(
                          fontSize: 10.5, color: MlColors.textSecondary),
                    ),
                  ],
                ),
              ),
              if (item.ultimoPrestamo != null)
                Text(
                  mlDate(item.ultimoPrestamo),
                  style: const TextStyle(
                      fontSize: 10, color: MlColors.textSecondary),
                ),
            ],
          ),
          if (item.totalDinero > 0 || item.totalGramos > 0) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                if (item.totalDinero > 0) ...[
                  _tag('Bs ${mlNum(item.totalDinero)}', MlColors.primary),
                  const SizedBox(width: 6),
                ],
                if (item.totalGramos > 0)
                  _tag('${mlNum(item.totalGramos)} g', MlColors.goldDeep),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _tag(String t, Color c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(t,
            style:
                TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c)),
      );
}

// ─── Fila de próximo vencimiento ─────────────────────────────────────────────

class _VencRow extends StatelessWidget {
  final MemberLoanUpcomingInterestEntity item;
  const _VencRow({required this.item});

  /// Texto + color según cuán cerca está el vencimiento.
  ({String text, Color color}) _urgency() {
    final due = item.dueDate;
    if (due == null) return (text: '—', color: MlColors.textSecondary);
    final now = DateTime.now();
    final days = DateTime(due.year, due.month, due.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
    if (days < 0) return (text: 'Vencido', color: MlColors.red);
    if (days == 0) return (text: 'Vence hoy', color: MlColors.red);
    if (days == 1) return (text: 'Mañana', color: MlColors.amber);
    if (days <= 7) return (text: 'En $days días', color: MlColors.amber);
    return (text: 'En $days días', color: MlColors.textSecondary);
  }

  @override
  Widget build(BuildContext context) {
    final u = _urgency();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MlColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MlColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: u.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(Icons.schedule_rounded, size: 18, color: u.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.socio,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: MlColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: u.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        u.text,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: u.color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        mlDate(item.dueDate),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 11, color: MlColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            mlMoney(item.interes, isGrams: item.isGrams),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: MlColors.amber,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Encabezado de sección ───────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? trailing;
  const _SectionLabel(this.title, this.icon, {this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: MlColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: MlColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
        ),
        if (trailing != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: MlColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              trailing!,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: MlColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}

class _Hint extends StatelessWidget {
  final String text;
  const _Hint(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: MlColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MlColors.border),
      ),
      child: Text(text,
          textAlign: TextAlign.center,
          style:
              const TextStyle(fontSize: 12.5, color: MlColors.textSecondary)),
    );
  }
}
