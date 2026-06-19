import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/widgets/excavator_loader.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/partners/domain/entity/loan_detail_entity.dart';
import 'package:front_gestion_minera/modules/partners/presentation/bloc/partners_bloc.dart';

class _LoanColors {
  static const primary = Color(0xFF1A56FF);
  static const primaryDeep = Color(0xFF0B33B8);
  static const gold = Color(0xFFEFC805);
  static const green = Color(0xFF17A05D);
  static const amber = Color(0xFFC47A00);
  static const red = Color(0xFFD32F2F);
  static const background = Color(0xFFF5F7FB);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF0D1B3E);
  static const textSecondary = Color(0xFF6B7A99);
  static const border = Color(0xFFE8EDF5);
}

String _fmt(double v) {
  if (v == v.roundToDouble()) return v.toStringAsFixed(0);
  return v.toStringAsFixed(2);
}

const _months = [
  'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
  'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
];

String _date(DateTime? d) =>
    d == null ? '—' : '${d.day.toString().padLeft(2, '0')} ${_months[d.month - 1]} ${d.year}';

@RoutePage()
class MemberLoanDetailScreen extends StatefulWidget {
  final String loanId;
  const MemberLoanDetailScreen({super.key, required this.loanId});

  @override
  State<MemberLoanDetailScreen> createState() => _MemberLoanDetailScreenState();
}

class _MemberLoanDetailScreenState extends State<MemberLoanDetailScreen> {
  late final PartnersBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = InjectorContainer.getIt<PartnersBloc>()
      ..add(LoanDetailFetchEvent(widget.loanId));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _LoanColors.background,
      body: Column(
        children: [
          _Header(onBack: () => Navigator.of(context).maybePop()),
          Expanded(
            child: BlocBuilder<PartnersBloc, PartnersState>(
              bloc: _bloc,
              builder: (context, state) {
                if (state is LoanDetailLoading) {
                  return const Center(child: ExcavatorLoader());
                }
                if (state is LoanDetailError) {
                  return _ErrorState(message: state.message);
                }
                if (state is LoanDetailLoaded) {
                  return _DetailBody(detail: state.detail);
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

// ─── Header ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final VoidCallback onBack;
  const _Header({required this.onBack});

  Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_LoanColors.primary, _LoanColors.primaryDeep],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -24,
            child: _circle(120, Colors.white.withValues(alpha: 0.08)),
          ),
          Positioned(
            top: 26,
            right: 36,
            child: _circle(64, _LoanColors.gold.withValues(alpha: 0.18)),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 20, 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onBack,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Detalle del préstamo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.3,
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

// ─── Cuerpo ──────────────────────────────────────────────────────────────────

class _DetailBody extends StatelessWidget {
  final LoanDetailEntity detail;
  const _DetailBody({required this.detail});

  @override
  Widget build(BuildContext context) {
    final c = detail.cabecera;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        _SummaryCard(cabecera: c),
        const SizedBox(height: 18),
        if (c.tieneInteres) ...[
          _InterestSummary(cabecera: c),
          const SizedBox(height: 18),
          _SectionTitle('Cronograma de interés', icon: Icons.event_repeat_rounded),
          const SizedBox(height: 10),
          if (detail.cronogramaInteres.isEmpty)
            const _EmptyHint('Aún no hay periodos de interés generados.')
          else
            ...detail.cronogramaInteres.map(
              (p) => _PeriodCard(period: p, isGrams: c.isGrams),
            ),
          const SizedBox(height: 18),
        ],
        _SectionTitle('Pagos registrados', icon: Icons.receipt_long_rounded),
        const SizedBox(height: 10),
        if (detail.pagos.isEmpty)
          const _EmptyHint('Todavía no se registran pagos.')
        else
          ...detail.pagos.map((p) => _PaymentCard(payment: p, isGrams: c.isGrams)),
      ],
    );
  }
}

class _EstadoStyle {
  final Color fg;
  final Color bg;
  final String label;
  const _EstadoStyle(this.fg, this.bg, this.label);
}

_EstadoStyle _estadoStyle(String estado) {
  switch (estado.toUpperCase()) {
    case 'APPROVED':
      return const _EstadoStyle(_LoanColors.primary, Color(0xFFE8F0FE), 'Vigente');
    case 'PAID':
      return const _EstadoStyle(_LoanColors.green, Color(0xFFE7F7EE), 'Pagado');
    case 'REJECTED':
      return const _EstadoStyle(_LoanColors.red, Color(0xFFFFEBEE), 'Rechazado');
    case 'CANCELLED':
      return const _EstadoStyle(Color(0xFF6B7A99), Color(0xFFEDEFF4), 'Cancelado');
    case 'PENDING':
    default:
      return const _EstadoStyle(_LoanColors.amber, Color(0xFFFFF4E5), 'En Revisión');
  }
}

class _SummaryCard extends StatelessWidget {
  final LoanDetailHeaderEntity cabecera;
  const _SummaryCard({required this.cabecera});

  String get _unit => cabecera.isGrams ? 'g' : 'Bs';
  String _money(double v) => cabecera.isGrams ? '${_fmt(v)} g' : 'Bs ${_fmt(v)}';

  @override
  Widget build(BuildContext context) {
    final st = _estadoStyle(cabecera.estado);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_LoanColors.primary, _LoanColors.primaryDeep],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _LoanColors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  cabecera.isGrams
                      ? Icons.diamond_outlined
                      : Icons.payments_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                cabecera.isGrams ? 'Préstamo en oro' : 'Préstamo en dinero',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  st.label,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Monto total',
            style: TextStyle(
              fontSize: 11.5,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _money(cabecera.montoTotal),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _InlineStat(
                  label: 'CAPITAL PENDIENTE',
                  value: _money(cabecera.saldoCapitalPendiente),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InlineStat(
                  label: 'UNIDAD',
                  value: _unit,
                ),
              ),
            ],
          ),
          if (cabecera.motivoRechazo != null &&
              cabecera.motivoRechazo!.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            _NoteBox(label: 'Motivo de rechazo', text: cabecera.motivoRechazo!),
          ],
          if (cabecera.motivoCancelacion != null &&
              cabecera.motivoCancelacion!.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            _NoteBox(
                label: 'Motivo de cancelación',
                text: cabecera.motivoCancelacion!),
          ],
        ],
      ),
    );
  }
}

class _InlineStat extends StatelessWidget {
  final String label;
  final String value;
  const _InlineStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 9,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteBox extends StatelessWidget {
  final String label;
  final String text;
  const _NoteBox({required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.35,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _InterestSummary extends StatelessWidget {
  final LoanDetailHeaderEntity cabecera;
  const _InterestSummary({required this.cabecera});

  String _u(double v) => cabecera.isGrams ? '${_fmt(v)} g' : 'Bs ${_fmt(v)}';

  @override
  Widget build(BuildContext context) {
    final rate = cabecera.tasaInteresMensual ?? 0;
    final rateLabel =
        cabecera.isGrams ? '${_fmt(rate)} g/mes' : '${_fmt(rate)} %/mes';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _LoanColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _LoanColors.border),
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
                  color: _LoanColors.gold.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.percent_rounded,
                    color: Color(0xFFB8930A), size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'Interés',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _LoanColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                rateLabel,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFB8930A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'Devengado',
                  value: _u(cabecera.interesDevengado),
                  color: _LoanColors.textPrimary,
                ),
              ),
              Expanded(
                child: _MiniStat(
                  label: 'Pagado',
                  value: _u(cabecera.interesPagado),
                  color: _LoanColors.green,
                ),
              ),
              Expanded(
                child: _MiniStat(
                  label: 'Pendiente',
                  value: _u(cabecera.interesPendiente),
                  color: _LoanColors.amber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            color: _LoanColors.textSecondary,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionTitle(this.title, {required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: _LoanColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: _LoanColors.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

class _PeriodCard extends StatelessWidget {
  final LoanInterestPeriodEntity period;
  final bool isGrams;
  const _PeriodCard({required this.period, required this.isGrams});

  @override
  Widget build(BuildContext context) {
    final bool paid = period.status.toUpperCase() == 'PAID';
    final Color color = paid ? _LoanColors.green : _LoanColors.amber;
    final Color bg = paid ? const Color(0xFFE7F7EE) : const Color(0xFFFFF4E5);
    final amount =
        isGrams ? '${_fmt(period.interestAmount)} g' : 'Bs ${_fmt(period.interestAmount)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _LoanColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _LoanColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Center(
              child: Text(
                '${period.periodNumber}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vence ${_date(period.dueDate)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _LoanColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  paid ? 'Pagado ${_date(period.paidAt)}' : 'Pendiente',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: _LoanColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _LoanColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  paid ? 'PAGADO' : 'PENDIENTE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final LoanPaymentEntity payment;
  final bool isGrams;
  const _PaymentCard({required this.payment, required this.isGrams});

  @override
  Widget build(BuildContext context) {
    final bool isInterest = payment.paymentType.toUpperCase() == 'INTEREST';
    final Color color = isInterest ? const Color(0xFFB8930A) : _LoanColors.primary;
    final amount =
        isGrams ? '${_fmt(payment.amount)} g' : 'Bs ${_fmt(payment.amount)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _LoanColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _LoanColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              isInterest ? Icons.percent_rounded : Icons.savings_rounded,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isInterest ? 'Pago de interés' : 'Abono de capital',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _LoanColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _date(payment.paidAt),
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: _LoanColors.textSecondary,
                  ),
                ),
                if (payment.notes != null && payment.notes!.trim().isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    payment.notes!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: _LoanColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: _LoanColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _LoanColors.border),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 12.5,
          color: _LoanColors.textSecondary,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: _LoanColors.red.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_off_rounded,
                  size: 44, color: _LoanColors.red),
            ),
            const SizedBox(height: 16),
            const Text(
              'No pudimos cargar el detalle',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _LoanColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                color: _LoanColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
