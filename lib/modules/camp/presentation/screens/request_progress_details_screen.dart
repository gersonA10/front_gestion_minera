import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/core/widgets/excavator_loader.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/utils/text_util.dart';
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
          foregroundColor: TColors.white,
          backgroundColor: TColors.headerDark,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: TColors.white),
            onPressed: () => context.router.back(),
          ),
          title: Text(
            'SOLICITUD',
            style: AppTextStyles.mainStyle22Bold(
              context,
            ).copyWith(color: TColors.white, height: 1.1),
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

            return const SizedBox.shrink();
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Progreso de Solicitud',
                style: AppTextStyles.mainStyle17Bold(
                  context,
                ).copyWith(color: TColors.headerDark),
              ),
              const SizedBox(height: 16),
              ...detail.timeline.asMap().entries.map((entry) {
                final step = entry.value;
                final isLast = entry.key == detail.timeline.length - 1;
                final isCompleted = step.status == 'COMPLETED';
                final isActive =
                    !isCompleted && step.key == detail.globalStatus;
                return _TimelineStep(
                  step: step,
                  isLast: isLast,
                  isCompleted: isCompleted,
                  isActive: isActive,
                );
              }),
            ],
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
        color: TColors.white,
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
                  style: AppTextStyles.mainStyle17Bold(
                    context,
                  ).copyWith(color: TColors.headerDark),
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
                  style: AppTextStyles.mainStyle11Bold(
                    context,
                  ).copyWith(color: color, letterSpacing: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'MONTO SOLICITADO',
            style: AppTextStyles.mainStyle11(
              context,
            ).copyWith(color: TColors.textGrey, letterSpacing: 1.0),
          ),
          const SizedBox(height: 2),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: amountFmt.format(detail.requestedAmount),
                  style: AppTextStyles.mainStyle30Bold(
                    context,
                  ).copyWith(color: TColors.headerDark),
                ),
                TextSpan(
                  text: ' Bs',
                  style: AppTextStyles.mainStyle14(
                    context,
                  ).copyWith(color: TColors.textGrey),
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
        color: TColors.white,
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
                  color: TColors.accionIconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.upload_file_outlined,
                  color: TColors.timelineBlue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Acción Requerida',
                    style: AppTextStyles.mainStyle15Bold(
                      context,
                    ).copyWith(color: TColors.headerDark),
                  ),
                  Text(
                    'Pendiente de recibo para cierre',
                    style: AppTextStyles.mainStyle13(
                      context,
                    ).copyWith(color: TColors.textGrey),
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
              label: Text(
                'Subir Recibo',
                style: AppTextStyles.mainStyle15Bold(context),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.timelineBlue,
                foregroundColor: TColors.white,
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
          const Icon(Icons.cancel_outlined, color: TColors.danger, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Solicitud Rechazada',
                  style: AppTextStyles.mainStyle14Bold(
                    context,
                  ).copyWith(color: TColors.danger),
                ),
                const SizedBox(height: 4),
                Text(
                  reason,
                  style: AppTextStyles.mainStyle13(
                    context,
                  ).copyWith(color: Colors.black87),
                ),
              ],
            ),
          ),
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

  const _TimelineStep({
    required this.step,
    required this.isLast,
    required this.isCompleted,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = (isCompleted || isActive)
        ? TColors.timelineBlue
        : TColors.textGrey;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 36,
            child: Column(
              children: [
                if (isCompleted)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: TColors.timelineBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: TColors.white,
                      size: 18,
                    ),
                  ),

                if (isActive)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: TColors.timelineBlue.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: TColors.timelineBlue,
                        width: 2.5,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: TColors.timelineBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),

                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: TColors.greyShade200,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    color: TColors.greyShade400,
                    size: 16,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isCompleted
                          ? TColors.timelineBlue
                          : TColors.timelineInactiveLine,
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
                        style: AppTextStyles.mainStyle15Bold(
                          context,
                        ).copyWith(color: titleColor),
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: TColors.timelineBlue.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Estado Actual',
                            style: AppTextStyles.mainStyle10Bold(
                              context,
                            ).copyWith(color: TColors.timelineBlue),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.description,
                    style: AppTextStyles.mainStyle12(
                      context,
                    ).copyWith(color: TColors.textGrey),
                  ),
                  if (step.date != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(step.date!),
                      style: AppTextStyles.mainStyle11(
                        context,
                      ).copyWith(color: TColors.textGrey),
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
          Text(
            label,
            style: AppTextStyles.mainStyle14(
              context,
            ).copyWith(color: TColors.textGrey),
          ),
          Text(
            value,
            style: AppTextStyles.mainStyle14Bold(
              context,
            ).copyWith(color: TColors.headerDark),
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
