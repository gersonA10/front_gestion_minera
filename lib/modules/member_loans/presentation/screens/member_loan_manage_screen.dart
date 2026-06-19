import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/widgets/excavator_loader.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entity/cash_register_entity.dart';
import '../../domain/entity/member_loan_detail_entity.dart';
import '../bloc/member_loan_detail_bloc.dart';
import '../ui_kit.dart';

@RoutePage()
class MemberLoanManageScreen extends StatefulWidget {
  final String loanId;
  const MemberLoanManageScreen({super.key, required this.loanId});

  @override
  State<MemberLoanManageScreen> createState() => _MemberLoanManageScreenState();
}

class _MemberLoanManageScreenState extends State<MemberLoanManageScreen> {
  late final MemberLoanDetailBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = InjectorContainer.getIt<MemberLoanDetailBloc>()
      ..add(MemberLoanDetailFetch(widget.loanId));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _snack(String message, {required bool ok}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ok ? MlColors.green : MlColors.red,
        content: Text(message),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MlColors.background,
      body: Column(
        children: [
          MlGradientHeader(
            title: 'Préstamo del socio',
            onBack: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: BlocConsumer<MemberLoanDetailBloc, MemberLoanDetailState>(
              bloc: _bloc,
              listener: (context, state) {
                if (state is MemberLoanActionSuccess) {
                  _snack(state.message, ok: true);
                } else if (state is MemberLoanActionError) {
                  _snack(state.message, ok: false);
                }
              },
              builder: (context, state) {
                if (state is MemberLoanDetailLoading) {
                  return const Center(child: ExcavatorLoader());
                }
                if (state is MemberLoanDetailError) {
                  return MlStateView(
                    icon: Icons.cloud_off_rounded,
                    color: MlColors.red,
                    title: 'No pudimos cargar el préstamo',
                    subtitle: state.message,
                  );
                }

                MemberLoanDetailEntity? detail;
                List<CashRegisterEntity> cajas = const [];
                bool busy = false;
                if (state is MemberLoanDetailLoaded) {
                  detail = state.detail;
                  cajas = state.cashRegisters;
                } else if (state is MemberLoanActionInProgress) {
                  detail = state.detail;
                  cajas = state.cashRegisters;
                  busy = true;
                } else if (state is MemberLoanActionError) {
                  detail = state.detail;
                  cajas = state.cashRegisters;
                }
                if (detail == null) return const SizedBox.shrink();

                return Stack(
                  children: [
                    _Body(detail: detail),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _ActionBar(
                        detail: detail,
                        cajas: cajas,
                        bloc: _bloc,
                      ),
                    ),
                    if (busy)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.25),
                          child: const Center(child: ExcavatorLoader()),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Cuerpo del detalle ──────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  final MemberLoanDetailEntity detail;
  const _Body({required this.detail});

  @override
  Widget build(BuildContext context) {
    final c = detail.cabecera;
    final hasActions = c.isPending || c.isApproved;
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, hasActions ? 100 : 24),
      children: [
        _SummaryCard(cabecera: c),
        const SizedBox(height: 14),
        _SocioCard(cabecera: c),
        if (c.tieneInteres) ...[
          const SizedBox(height: 14),
          _InterestCard(cabecera: c),
          const SizedBox(height: 18),
          _Section('Cronograma de interés', Icons.event_repeat_rounded),
          const SizedBox(height: 10),
          if (detail.cronogramaInteres.isEmpty)
            const _Hint('Aún no hay periodos de interés generados.')
          else
            ...detail.cronogramaInteres
                .map((p) => _PeriodTile(period: p, isGrams: c.isGrams)),
        ],
        const SizedBox(height: 18),
        _Section('Pagos registrados', Icons.receipt_long_rounded),
        const SizedBox(height: 10),
        if (detail.pagos.isEmpty)
          const _Hint('Todavía no se registran pagos.')
        else
          ...detail.pagos.map((p) => _PaymentTile(payment: p, isGrams: c.isGrams)),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final MemberLoanDetailHeaderEntity cabecera;
  const _SummaryCard({required this.cabecera});

  @override
  Widget build(BuildContext context) {
    final st = mlStatusStyle(cabecera.estado);
    String m(double v) => mlMoney(v, isGrams: cabecera.isGrams);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [MlColors.primary, MlColors.primaryDeep],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: MlColors.primary.withValues(alpha: 0.25),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
          Text('Monto total',
              style: TextStyle(
                  fontSize: 11.5, color: Colors.white.withValues(alpha: 0.75))),
          const SizedBox(height: 2),
          Text(
            m(cabecera.montoTotal),
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
                  child: _MiniBox(
                      label: 'PENDIENTE', value: m(cabecera.capitalPendiente))),
              const SizedBox(width: 10),
              Expanded(
                  child: _MiniBox(
                      label: 'PAGADO', value: m(cabecera.capitalPagado))),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniBox extends StatelessWidget {
  final String label;
  final String value;
  const _MiniBox({required this.label, required this.value});

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
          Text(label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 9,
                letterSpacing: 0.3,
              )),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
        ],
      ),
    );
  }
}

class _SocioCard extends StatelessWidget {
  final MemberLoanDetailHeaderEntity cabecera;
  const _SocioCard({required this.cabecera});

  @override
  Widget build(BuildContext context) {
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
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: MlColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person_rounded,
                    color: MlColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cabecera.socio,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: MlColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ha prestado ${cabecera.vecesPrestoSocio} ${cabecera.vecesPrestoSocio == 1 ? "vez" : "veces"}',
                      style: const TextStyle(
                          fontSize: 11.5, color: MlColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if ((cabecera.identificacion ?? '').isNotEmpty ||
              (cabecera.telefono ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: MlColors.border),
            const SizedBox(height: 12),
            Row(
              children: [
                if ((cabecera.identificacion ?? '').isNotEmpty)
                  Expanded(
                    child: _kv('CI / Identificación', cabecera.identificacion!),
                  ),
                if ((cabecera.telefono ?? '').isNotEmpty)
                  Expanded(child: _kv('Teléfono', cabecera.telefono!)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _kv(String k, String v) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(k,
              style: const TextStyle(
                  fontSize: 10.5, color: MlColors.textSecondary)),
          const SizedBox(height: 2),
          Text(v,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: MlColors.textPrimary)),
        ],
      );
}

class _InterestCard extends StatelessWidget {
  final MemberLoanDetailHeaderEntity cabecera;
  const _InterestCard({required this.cabecera});

  @override
  Widget build(BuildContext context) {
    String u(double v) => mlMoney(v, isGrams: cabecera.isGrams);
    final rate = cabecera.tasaInteresMensual ?? 0;
    final rateLabel =
        cabecera.isGrams ? '${mlNum(rate)} g/mes' : '${mlNum(rate)} %/mes';
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
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: MlColors.gold.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.percent_rounded,
                    color: MlColors.goldDeep, size: 18),
              ),
              const SizedBox(width: 10),
              const Text('Interés',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: MlColors.textPrimary)),
              const Spacer(),
              Text(rateLabel,
                  style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: MlColors.goldDeep)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                  child: _stat('Devengado', u(cabecera.interesDevengado),
                      MlColors.textPrimary)),
              Expanded(
                  child: _stat(
                      'Pagado', u(cabecera.interesPagado), MlColors.green)),
              Expanded(
                  child: _stat('Pendiente', u(cabecera.interesPendiente),
                      MlColors.amber)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String l, String v, Color c) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l,
              style:
                  const TextStyle(fontSize: 10.5, color: MlColors.textSecondary)),
          const SizedBox(height: 3),
          Text(v,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w800, color: c)),
        ],
      );
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  const _Section(this.title, this.icon);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: MlColors.primary),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: MlColors.textPrimary,
                letterSpacing: -0.2)),
      ],
    );
  }
}

class _PeriodTile extends StatelessWidget {
  final MemberLoanInterestPeriodEntity period;
  final bool isGrams;
  const _PeriodTile({required this.period, required this.isGrams});

  @override
  Widget build(BuildContext context) {
    final paid = period.isPaid;
    final color = paid ? MlColors.green : MlColors.amber;
    final bg = paid ? const Color(0xFFE7F7EE) : const Color(0xFFFFF4E5);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MlColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MlColors.border),
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
              child: Text('${period.periodNumber}',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: color)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Vence ${mlDate(period.dueDate)}',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: MlColors.textPrimary)),
                const SizedBox(height: 2),
                Text(paid ? 'Pagado ${mlDate(period.paidAt)}' : 'Pendiente',
                    style: const TextStyle(
                        fontSize: 11.5, color: MlColors.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(mlMoney(period.interestAmount, isGrams: isGrams),
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: MlColors.textPrimary)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: bg, borderRadius: BorderRadius.circular(8)),
                child: Text(paid ? 'PAGADO' : 'PENDIENTE',
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: color)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final MemberLoanPaymentEntity payment;
  final bool isGrams;
  const _PaymentTile({required this.payment, required this.isGrams});

  @override
  Widget build(BuildContext context) {
    final interest = payment.isInterest;
    final color = interest ? MlColors.goldDeep : MlColors.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MlColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MlColors.border),
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
                interest ? Icons.percent_rounded : Icons.savings_rounded,
                color: color,
                size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(interest ? 'Pago de interés' : 'Abono de capital',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: MlColors.textPrimary)),
                const SizedBox(height: 2),
                Text(
                  '${mlDate(payment.paidAt)}'
                  '${payment.cashRegisterId != null ? " · caja" : ""}',
                  style: const TextStyle(
                      fontSize: 11.5, color: MlColors.textSecondary),
                ),
                if ((payment.notes ?? '').isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(payment.notes!,
                      style: const TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: MlColors.textSecondary)),
                ],
              ],
            ),
          ),
          Text(mlMoney(payment.amount, isGrams: isGrams),
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
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
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: MlColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MlColors.border),
      ),
      child: Text(text,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 12.5, color: MlColors.textSecondary)),
    );
  }
}

// ─── Barra de acciones inferior ──────────────────────────────────────────────

class _ActionBar extends StatelessWidget {
  final MemberLoanDetailEntity detail;
  final List<CashRegisterEntity> cajas;
  final MemberLoanDetailBloc bloc;
  const _ActionBar(
      {required this.detail, required this.cajas, required this.bloc});

  @override
  Widget build(BuildContext context) {
    final c = detail.cabecera;
    final children = <Widget>[];

    if (c.isPending) {
      children.add(Expanded(
        child: _btn('Rechazar', MlColors.red, outline: true,
            onTap: () => _reasonDialog(context, isCancel: false)),
      ));
      children.add(const SizedBox(width: 12));
      children.add(Expanded(
        child: _btn('Aprobar', MlColors.green,
            onTap: () => _approveDialog(context)),
      ));
    } else if (c.isApproved) {
      // "Pagar interés" solo aplica si el préstamo pactó interés.
      if (c.tieneInteres) {
        children.add(Expanded(
          child: _btn('Pagar interés', MlColors.goldDeep,
              onTap: () => _paymentSheet(context, 'INTEREST')),
        ));
        children.add(const SizedBox(width: 10));
      }
      children.add(Expanded(
        child: _btn('Abonar capital', MlColors.primary,
            onTap: () => _paymentSheet(context, 'PRINCIPAL')),
      ));
    }

    if (children.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: MlColors.surface,
        border: const Border(top: BorderSide(color: MlColors.border)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D1B3E).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: children),
            if (c.isApproved) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: _btn('Cancelar préstamo', MlColors.red,
                    outline: true,
                    onTap: () => _reasonDialog(context, isCancel: true)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _btn(String label, Color color,
      {required VoidCallback onTap, bool outline = false, bool enabled = true}) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: outline ? Colors.transparent : color,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color, width: 1.4),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: outline ? color : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // ── Diálogos ──────────────────────────────────────────────────────────────

  void _approveDialog(BuildContext context) {
    final c = detail.cabecera;
    final loanId = c.loanId;
    if (!c.isGrams && cajas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No hay cajas disponibles para aprobar en dinero.'),
      ));
      return;
    }
    String? selectedCaja = c.isGrams ? null : cajas.first.id;

    showDialog(
      context: context,
      builder: (dctx) {
        return StatefulBuilder(
          builder: (dctx, setLocal) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Text('Aprobar préstamo',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.isGrams
                        ? 'Confirmas la aprobación de este préstamo en oro. No afecta cajas.'
                        : 'Selecciona la caja donde ingresa el monto.',
                    style: const TextStyle(
                        fontSize: 13, color: MlColors.textSecondary),
                  ),
                  if (!c.isGrams) ...[
                    const SizedBox(height: 14),
                    _CajaDropdown(
                      cajas: cajas,
                      value: selectedCaja,
                      onChanged: (v) => setLocal(() => selectedCaja = v),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dctx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MlColors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(dctx);
                    bloc.add(MemberLoanApprove(loanId,
                        cashRegisterId: c.isGrams ? null : selectedCaja));
                  },
                  child: const Text('Aprobar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _reasonDialog(BuildContext context, {required bool isCancel}) {
    final loanId = detail.cabecera.loanId;
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(isCancel ? 'Cancelar préstamo' : 'Rechazar préstamo',
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Motivo',
              filled: true,
              fillColor: MlColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dctx),
              child: const Text('Volver'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MlColors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final reason = controller.text.trim();
                if (reason.isEmpty) return;
                Navigator.pop(dctx);
                if (isCancel) {
                  bloc.add(MemberLoanCancel(loanId, reason));
                } else {
                  bloc.add(MemberLoanReject(loanId, reason));
                }
              },
              child: Text(isCancel ? 'Cancelar préstamo' : 'Rechazar'),
            ),
          ],
        );
      },
    );
  }

  void _paymentSheet(BuildContext context, String type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => _PaymentSheet(
        detail: detail,
        cajas: cajas,
        paymentType: type,
        onSubmit: (event) => bloc.add(event),
      ),
    );
  }
}

class _CajaDropdown extends StatelessWidget {
  final List<CashRegisterEntity> cajas;
  final String? value;
  final ValueChanged<String?> onChanged;
  const _CajaDropdown(
      {required this.cajas, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: MlColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MlColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: const Text('Selecciona una caja'),
          items: cajas
              .map((c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(
                      '${c.nombre} · Bs ${mlNum(c.saldoDisponible)}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ─── Hoja de pago (interés / capital) ────────────────────────────────────────

class _PaymentSheet extends StatefulWidget {
  final MemberLoanDetailEntity detail;
  final List<CashRegisterEntity> cajas;
  final String paymentType; // INTEREST | PRINCIPAL
  final void Function(MemberLoanRegisterPayment) onSubmit;

  const _PaymentSheet({
    required this.detail,
    required this.cajas,
    required this.paymentType,
    required this.onSubmit,
  });

  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<_PaymentSheet> {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _picker = ImagePicker();
  String? _cajaId;
  File? _image;
  String? _error;

  bool get _isInterest => widget.paymentType == 'INTEREST';
  bool get _isGrams => widget.detail.cabecera.isGrams;
  bool get _needsCaja => !_isGrams;

  @override
  void initState() {
    super.initState();
    if (_needsCaja && widget.cajas.isNotEmpty) _cajaId = widget.cajas.first.id;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final x = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (x != null) setState(() => _image = File(x.path));
  }

  void _submit() {
    final amountText = _amountController.text.trim();
    double? amount = amountText.isEmpty ? null : double.tryParse(amountText);

    if (!_isInterest) {
      if (amount == null || amount <= 0) {
        setState(() => _error = 'Ingresa un monto válido para el abono.');
        return;
      }
    } else if (amountText.isNotEmpty && (amount == null || amount <= 0)) {
      setState(() => _error = 'El monto de interés no es válido.');
      return;
    }
    if (_needsCaja && _cajaId == null) {
      setState(() => _error = 'Selecciona la caja de origen.');
      return;
    }

    widget.onSubmit(MemberLoanRegisterPayment(
      loanId: widget.detail.cabecera.loanId,
      paymentType: widget.paymentType,
      amount: amount,
      cashRegisterId: _needsCaja ? _cajaId : null,
      notes: _notesController.text,
      comprobantePath: _image?.path,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final unit = _isGrams ? 'g' : 'Bs';
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: MlColors.border,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _isInterest ? 'Registrar pago de interés' : 'Abonar a capital',
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: MlColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            _isInterest
                ? 'Se paga el periodo pendiente más antiguo. El monto es opcional.'
                : 'Descuenta del capital. Si llega a 0, el préstamo queda Pagado.',
            style:
                const TextStyle(fontSize: 12, color: MlColors.textSecondary),
          ),
          const SizedBox(height: 16),
          _label(_isInterest ? 'Monto ($unit) — opcional' : 'Monto ($unit)'),
          const SizedBox(height: 6),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _dec(_isInterest ? 'Interés del periodo' : '0.00'),
          ),
          if (_needsCaja) ...[
            const SizedBox(height: 14),
            _label('Caja de origen'),
            const SizedBox(height: 6),
            _CajaDropdown(
              cajas: widget.cajas,
              value: _cajaId,
              onChanged: (v) => setState(() => _cajaId = v),
            ),
          ],
          const SizedBox(height: 14),
          _label('Nota (opcional)'),
          const SizedBox(height: 6),
          TextField(
            controller: _notesController,
            decoration: _dec('Observación'),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: _pick,
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: MlColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: MlColors.border),
              ),
              child: Row(
                children: [
                  Icon(
                    _image == null
                        ? Icons.attach_file_rounded
                        : Icons.check_circle_rounded,
                    size: 18,
                    color: _image == null ? MlColors.textSecondary : MlColors.green,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _image == null
                          ? 'Adjuntar comprobante (opcional)'
                          : 'Comprobante adjuntado',
                      style: const TextStyle(
                          fontSize: 13, color: MlColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!,
                style: const TextStyle(fontSize: 12, color: MlColors.red)),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MlColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _submit,
              child: const Text('Registrar pago',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String t) => Text(t,
      style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: MlColors.textSecondary));

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        isDense: true,
        filled: true,
        fillColor: MlColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      );
}
