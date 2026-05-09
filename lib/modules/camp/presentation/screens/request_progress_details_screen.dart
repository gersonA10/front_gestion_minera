import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/core/widgets/excavator_loader.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:intl/intl.dart';

import '../../../../utils/constants/color.constant.dart';
import '../../domain/entity/entity.dart';
import '../bloc/camp_bloc.dart';

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

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
         backgroundColor: TColors.appBackgroundColor,
        appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF1A1F2E),
            leading: IconButton(
            icon: Icon(Icons.arrow_back, color: TColors.white),
            onPressed: () => context.router.back(),
          ),
          title: const Text(
            'SOLICITUD',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
        ),
        body: BlocBuilder<CampBloc, CampState>(
          builder: (context, state) {
            final isLoading = state is RequestDetailLoading;
            if (state is RequestDetailError) {
              return Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(state.message, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _bloc.add(
                              GetRequestDetailEvent(widget.requestId),
                            ),
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            if (state is RequestDetailLoaded) {
              return Stack(
                children: [
                  _DetailView(detail: state.detail),
                  if (isLoading)
                    Container(
                      color: Colors.black.withValues(alpha: 0.3),
                      child: const Center(child: ExcavatorLoader()),
                    ),
                ],
              );
            }

            return SizedBox.shrink();
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SummaryCard(detail: detail, amountFmt: amountFmt),
            if (detail.requiredAction != null) ...[
              const SizedBox(height: 12),
              _AccionRequeridaCard(requestId: detail.requestId),
            ],
            if (detail.rejectReason != null) ...[
              const SizedBox(height: 12),
              _RejectionCard(reason: detail.rejectReason!),
            ],
            const SizedBox(height: 20),
            _TimelineSection(
              timeline: detail.timeline,
              globalStatus: detail.globalStatus,
            ),
            const SizedBox(height: 20),
            _MetadataRow('Solicitante', detail.requesterName),
            const Divider(height: 1),
            _MetadataRow(
              'Creado el',
              DateFormat('dd/MM/yyyy HH:mm').format(detail.createdAt),
            ),
            if (detail.closedAt != null) ...[
              const Divider(height: 1),
              _MetadataRow(
                'Cerrado el',
                DateFormat('dd/MM/yyyy HH:mm').format(detail.closedAt!),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final RequestDetailEntity detail;
  final NumberFormat amountFmt;

  const _SummaryCard({required this.detail, required this.amountFmt});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(detail.globalStatus);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  detail.description,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1F2E),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  detail.statusLabel.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'MONTO SOLICITADO',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey,
              letterSpacing: 1.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: amountFmt.format(detail.requestedAmount),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1F2E),
                  ),
                ),
                const TextSpan(
                  text: ' Bs',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
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

class _AccionRequeridaCard extends StatelessWidget {
  final String requestId;

  const _AccionRequeridaCard({required this.requestId});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
                  color: const Color(0xFFE8F4FD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.upload_file_outlined,
                  color: Color(0xFF2196F3),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Acción Requerida',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1F2E),
                    ),
                  ),
                  Text(
                    'Pendiente de recibo para cierre',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
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
              icon: const Icon(Icons.cloud_upload_outlined, size: 18),
              label: const Text(
                'Subir Recibo',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
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

class _RejectionCard extends StatelessWidget {
  final String reason;

  const _RejectionCard({required this.reason});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TColors.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.cancel_outlined, color: TColors.danger, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Solicitud Rechazada',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: TColors.danger,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reason,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineSection extends StatelessWidget {
  final List<RequestTimelineStepEntity> timeline;
  final String globalStatus;

  const _TimelineSection({required this.timeline, required this.globalStatus});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Progreso de Solicitud',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1F2E),
          ),
        ),
        const SizedBox(height: 16),
        ...timeline.asMap().entries.map((entry) {
          final step = entry.value;
          final isLast = entry.key == timeline.length - 1;
          final isCompleted = step.status == 'COMPLETED';
          final isActive = !isCompleted && step.key == globalStatus;
          return _TimelineStep(
            step: step,
            isLast: isLast,
            isCompleted: isCompleted,
            isActive: isActive,
          );
        }),
      ],
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final RequestTimelineStepEntity step;
  final bool isLast;
  final bool isCompleted;
  final bool isActive;

  const _TimelineStep({
    required this.step,
    required this.isLast,
    required this.isCompleted,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF2196F3);

    final titleColor = (isCompleted || isActive) ? blue : Colors.grey;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 36,
            child: Column(
              children: [
                _indicator(isCompleted, isActive),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isCompleted ? blue : const Color(0xFFDDDDDD),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        step.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: titleColor,
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
                            color: blue.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Estado Actual',
                            style: TextStyle(
                              fontSize: 10,
                              color: blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.description,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  if (step.date != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(step.date!),
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
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

  Widget _indicator(bool isCompleted, bool isActive) {
    const blue = Color(0xFF2196F3);
    if (isCompleted) {
      return Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(color: blue, shape: BoxShape.circle),
        child: const Icon(Icons.check, color: Colors.white, size: 18),
      );
    }
    if (isActive) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: blue.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(color: blue, width: 2.5),
        ),
        child: Center(
          child: Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: blue,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.lock_outline, color: Colors.grey.shade400, size: 16),
    );
  }
}

class _MetadataRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetadataRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1F2E),
            ),
          ),
        ],
      ),
    );
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'IN_REVIEW':
      return TColors.appMainColor;
    case 'APPROVED':
    case 'PENDING_RECEIPT':
      return TColors.amber;
    case 'PAID':
    case 'COMPLETED':
      return TColors.green;
    case 'REJECTED':
      return TColors.danger;
    default:
      return TColors.appMainColor;
  }
}
