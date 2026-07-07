import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/staff_ui.dart';
import 'package:intl/intl.dart';

import '../../domain/entity/entity.dart';
import '../bloc/camp_bloc.dart';

/// Paleta compartida con los módulos de socios y hacienda.
class _C {
  static const primary = Color(0xFF1A56FF);
  static const primaryDeep = Color(0xFF0B33B8);
  static const gold = Color(0xFFEFC805);
  static const background = Color(0xFFF5F7FB);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF0D1B3E);
  static const textSecondary = Color(0xFF6B7A99);
  static const border = Color(0xFFE8EDF5);

  static const green = Color(0xFF17A05D);
  static const amber = Color(0xFFC47A00);
  static const danger = Color(0xFFD32F2F);
  static const lineInactive = Color(0xFFE2E8F0);
}

@RoutePage()
class RequestProgressDetailsScreen extends StatefulWidget {
  final String requestId;

  const RequestProgressDetailsScreen({super.key, required this.requestId});

  @override
  State<RequestProgressDetailsScreen> createState() =>
      _RequestProgressDetailsScreenState();
}

class _RequestProgressDetailsScreenState
    extends State<RequestProgressDetailsScreen> {
  late final CampBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = InjectorContainer.getIt<CampBloc>();
    _bloc.add(GetRequestDetailEvent(widget.requestId));
  }

  void _reload() => _bloc.add(GetRequestDetailEvent(widget.requestId));

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: _C.background,
        body: BlocBuilder<CampBloc, CampState>(
          builder: (context, state) {
            if (state is RequestDetailError) {
              return Column(
                children: [
                  const _Hero.placeholder(),
                  Expanded(
                    child: _ErrorView(message: state.message, onRetry: _reload),
                  ),
                ],
              );
            }

            if (state is RequestDetailLoaded) {
              return _DetailView(detail: state.detail);
            }

            // RequestDetailLoading / inicial
            return Column(
              children: const [
                _Hero.placeholder(),
                Expanded(
                  child: StaffLoader(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DetailView extends StatelessWidget {
  final RequestDetailEntity detail;

  const _DetailView({required this.detail});

  @override
  Widget build(BuildContext context) {
    final amountFmt = NumberFormat('#,##0.00', 'es_BO');

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Hero(detail: detail, amountFmt: amountFmt),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (detail.requiredAction != null) ...[
                  _ActionRequiredCard(requestId: detail.requestId),
                  const SizedBox(height: 14),
                ],
                if (detail.rejectReason != null) ...[
                  _RejectionCard(reason: detail.rejectReason!),
                  const SizedBox(height: 14),
                ],
                _ProgressCard(detail: detail),
                const SizedBox(height: 14),
                _MetadataCard(detail: detail, amountFmt: amountFmt),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero con degradado: estado + monto ──────────────────────────────────────

class _Hero extends StatelessWidget {
  final RequestDetailEntity? detail;
  final NumberFormat? amountFmt;

  const _Hero({required RequestDetailEntity this.detail, required this.amountFmt});

  /// Versión sin datos (estados de carga/error): solo barra superior.
  const _Hero.placeholder() : detail = null, amountFmt = null;

  Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );

  @override
  Widget build(BuildContext context) {
    final d = detail;
    final status = d != null ? _statusStyleFor(d.globalStatus) : null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_C.primary, _C.primaryDeep],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: _C.primary.withValues(alpha: 0.32),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: -34,
            right: -26,
            child: _circle(130, Colors.white.withValues(alpha: 0.08)),
          ),
          Positioned(
            top: 40,
            right: 44,
            child: _circle(64, _C.gold.withValues(alpha: 0.16)),
          ),
          Positioned(
            bottom: -46,
            left: -28,
            child: _circle(110, Colors.white.withValues(alpha: 0.05)),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 20, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Barra superior
                  Row(
                    children: [
                      const _GlassBackButton(),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SOLICITUD',
                              style: TextStyle(
                                fontSize: 11,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                            if (d != null) ...[
                              const SizedBox(height: 1),
                              Text(
                                d.displayCode,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (d != null && status != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      d.description,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.25,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _StatusPill(
                      label: d.reconciliationStatus == 'PENDING'
                          ? 'Reposición pendiente'
                          : d.statusLabel,
                      color: d.reconciliationStatus == 'PENDING'
                          ? _C.amber
                          : status.color,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'MONTO SOLICITADO',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: amountFmt!.format(d.requestedAmount),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.8,
                            ),
                          ),
                          TextSpan(
                            text: '  Bs',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassBackButton extends StatelessWidget {
  const _GlassBackButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.router.back(),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: Colors.white.withValues(alpha: 0.26)),
        ),
        child: const Icon(
          Icons.arrow_back_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

// ─── Tarjeta de acción requerida ─────────────────────────────────────────────

class _ActionRequiredCard extends StatelessWidget {
  final String requestId;

  const _ActionRequiredCard({required this.requestId});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.primary.withValues(alpha: 0.18)),
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
                  color: _C.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.upload_file_rounded,
                  color: _C.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Acción requerida',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: _C.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Pendiente de recibo para el cierre.',
                      style: TextStyle(fontSize: 12, color: _C.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await context.router.push(
                  UploadReceiptEvidenceRoute(requestId: requestId),
                );
                if (context.mounted) {
                  context.read<CampBloc>().add(
                    GetRequestDetailEvent(requestId),
                  );
                }
              },
              icon: const Icon(Icons.cloud_upload_rounded, size: 18),
              label: const Text(
                'Subir recibo',
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tarjeta de rechazo ──────────────────────────────────────────────────────

class _RejectionCard extends StatelessWidget {
  final String reason;

  const _RejectionCard({required this.reason});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.danger.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.danger.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _C.danger.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.cancel_rounded, color: _C.danger, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Solicitud rechazada',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _C.danger,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reason,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.35,
                    color: _C.textPrimary,
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

// ─── Tarjeta de progreso (stepper) ───────────────────────────────────────────

class _ProgressCard extends StatelessWidget {
  final RequestDetailEntity detail;

  const _ProgressCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D1B3E).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progreso de la solicitud',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: _C.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 18),
          ...detail.timeline.asMap().entries.map((entry) {
            final step = entry.value;
            final isLast = entry.key == detail.timeline.length - 1;
            final isCompleted = step.status == 'COMPLETED';
            final isActive = !isCompleted && step.key == detail.globalStatus;
            final isRejected = step.status == 'REJECTED' ||
                (isActive && detail.globalStatus == 'REJECTED');
            return _TimelineStep(
              step: step,
              isLast: isLast,
              isCompleted: isCompleted,
              isActive: isActive,
              isRejected: isRejected,
            );
          }),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final RequestTimelineStepEntity step;
  final bool isLast;
  final bool isCompleted;
  final bool isActive;
  final bool isRejected;

  const _TimelineStep({
    required this.step,
    required this.isLast,
    required this.isCompleted,
    required this.isActive,
    required this.isRejected,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isRejected ? _C.danger : _C.primary;
    final reached = isCompleted || isActive;
    final titleColor = reached ? _C.textPrimary : _C.textSecondary;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                _node(accent),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2.5,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        color: isCompleted ? _C.primary : _C.lineInactive,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          step.title,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: titleColor,
                          ),
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            isRejected ? 'Rechazada' : 'Estado actual',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: accent,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    step.description,
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.35,
                      color: _C.textSecondary,
                    ),
                  ),
                  if (step.date != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 12,
                          color: _C.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd/MM/yyyy · HH:mm').format(step.date!),
                          style: const TextStyle(
                            fontSize: 11,
                            color: _C.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Un único nodo según el estado del paso (sin apilar círculos).
  Widget _node(Color accent) {
    if (isCompleted) {
      return Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: accent,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          isRejected ? Icons.close_rounded : Icons.check_rounded,
          color: Colors.white,
          size: 18,
        ),
      );
    }

    if (isActive) {
      return Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(color: accent, width: 2.5),
        ),
        child: Center(
          child: Container(
            width: 11,
            height: 11,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
        ),
      );
    }

    // Pendiente / bloqueado
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: _C.background,
        shape: BoxShape.circle,
        border: Border.all(color: _C.lineInactive, width: 2),
      ),
      child: const Icon(
        Icons.lock_outline_rounded,
        color: Color(0xFFB6C0D4),
        size: 14,
      ),
    );
  }
}

// ─── Metadatos ───────────────────────────────────────────────────────────────

class _MetadataCard extends StatelessWidget {
  final RequestDetailEntity detail;
  final NumberFormat amountFmt;

  const _MetadataCard({required this.detail, required this.amountFmt});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[
      _MetadataRow('Solicitante', detail.requesterName),
      _MetadataRow(
        'Creado el',
        DateFormat('dd/MM/yyyy HH:mm').format(detail.createdAt),
      ),
      if (detail.finalAmount > 0)
        _MetadataRow('Monto final', '${amountFmt.format(detail.finalAmount)} Bs'),
      if (detail.closedAt != null)
        _MetadataRow(
          'Cerrado el',
          DateFormat('dd/MM/yyyy HH:mm').format(detail.closedAt!),
        ),
      if (detail.reconciliationStatus == 'PENDING')
        _MetadataRow(
          'Reposición',
          'Pendiente de Hacienda',
          valueColor: _C.amber,
        ),
      if (detail.reconciliationStatus == 'RECONCILED')
        _MetadataRow('Reposición', 'Conciliada', valueColor: _C.green),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: _C.border),
            rows[i],
          ],
        ],
      ),
    );
  }
}

class _MetadataRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _MetadataRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: _C.textSecondary),
          ),
          const Spacer(),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: valueColor ?? _C.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Error ───────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 52,
              color: Color(0xFFCBD5E1),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: _C.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helpers de estado ───────────────────────────────────────────────────────

class _StatusStyle {
  final Color color;
  const _StatusStyle(this.color);
}

_StatusStyle _statusStyleFor(String status) {
  switch (status) {
    case 'IN_REVIEW':
      return const _StatusStyle(_C.primary);
    case 'APPROVED':
    case 'PENDING_RECEIPT':
      return const _StatusStyle(_C.amber);
    case 'PAID':
    case 'COMPLETED':
      return const _StatusStyle(_C.green);
    case 'REJECTED':
      return const _StatusStyle(_C.danger);
    default:
      return const _StatusStyle(_C.primary);
  }
}
