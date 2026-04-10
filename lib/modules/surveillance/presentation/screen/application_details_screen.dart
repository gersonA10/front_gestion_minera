import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/surveillance/presentation/bloc/surveillance_bloc.dart';
import 'package:front_gestion_minera/modules/surveillance/presentation/widget/custom_dialog_wigdet.dart';
import 'package:front_gestion_minera/utils/date_util.dart';
import 'package:front_gestion_minera/utils/text_util.dart';

@RoutePage()
class ApplicationDetailsScreen extends StatefulWidget {
  final String requestId;
  final DateTime createdAt;
  final String name;
  final String rol;
  final String description;
  final String amount;
  final String evidencia;
  final String status;
  final String? motivoRechazo;

  const ApplicationDetailsScreen({
    super.key,
    required this.requestId,
    required this.createdAt,
    required this.name,
    required this.rol,
    required this.description,
    required this.amount,
    required this.evidencia,
    required this.status,
    this.motivoRechazo,
  });

  @override
  State<ApplicationDetailsScreen> createState() =>
      _ApplicationDetailsScreenState();
}

class _ApplicationDetailsScreenState extends State<ApplicationDetailsScreen> {
  final TextEditingController rejectedContoller = TextEditingController();
  late final SurveillanceBloc _bloc;

  bool get isPending {
    final s = widget.status.toLowerCase();
    return s == 'pending' || s == 'pendiente';
  }

  bool get isRejected {
    final s = widget.status.toLowerCase();
    return s == 'rechazado' || s == 'rejected';
  }

  @override
  void initState() {
    super.initState();
    _bloc = InjectorContainer.getIt<SurveillanceBloc>();
  }

  @override
  void dispose() {
    _bloc.close();
    rejectedContoller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xff081423);

    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<SurveillanceBloc, SurveillanceState>(
        listener: (context, state) {
          if (state is ApproveTheRequestLoading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const _BlockingLoader(),
            );
          }

          if (state is ApproveTheRequestSuccess) {
            Navigator.of(context, rootNavigator: true).pop();

            CustomAlert.show(
              context,
              title: 'Éxito',
              message: "Solicitud procesada correctamente",
              type: AlertType.success,
            );

            context.router.maybePop(true);
          }

          if (state is ApproveTheRequestError) {
            Navigator.of(context, rootNavigator: true).pop();
            CustomAlert.show(
              context,
              title: 'Error',
              message: state.message,
              type: AlertType.error,
            );
          }
        },
        child: Scaffold(
          backgroundColor: background,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeroSummary(context),
                        const SizedBox(height: 18),
                        _buildGeneralInfoCard(context),
                        const SizedBox(height: 18),
                        _buildEvidenceCard(context),
                        if (isPending) ...[
                          const SizedBox(height: 22),
                          _buildActionsCard(context),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.router.back(),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: colors.white,
              size: 18,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Detalle de solicitud',
                  style: AppTextStyles.mainStyleWhite14Bold(context).copyWith(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Revisión y validación de la solicitud',
                  style: AppTextStyles.mainStyleWhite12(context).copyWith(
                    color: Colors.white.withValues(alpha: .65),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildHeroSummary(BuildContext context) {

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [
            Color(0xff16345f),
            Color(0xff102847),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatus(),
          const SizedBox(height: 16),
          Text(
            widget.name,
            style: AppTextStyles.mainStyleWhite14Bold(context).copyWith(
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Solicitud registrada el ${formatDate(widget.createdAt)}',
            style: AppTextStyles.mainStyleWhite12(context).copyWith(
              color: Colors.white.withValues(alpha: .80),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _SummaryMetric(
                  label: 'Área / Rol',
                  value: widget.rol,
                  icon: Icons.badge_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryMetric(
                  label: 'Monto solicitado',
                  value: '${widget.amount} Bs.',
                  icon: Icons.account_balance_wallet_outlined,
                  highlight: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralInfoCard(BuildContext context) {
    return _SectionCard(
      title: 'Información general',
      icon: Icons.info_outline_rounded,
      child: Column(
        children: [
          _InfoRow(label: 'Solicitante', value: widget.name),
          const SizedBox(height: 14),
          _InfoRow(label: 'Fecha', value: formatDate(widget.createdAt)),
          const SizedBox(height: 14),
          _InfoRow(label: 'Área / Rol', value: widget.rol),
          const SizedBox(height: 18),
          _DescriptionBlock(
            title: 'Descripción',
            value: widget.description,
          ),
          if (isRejected &&
              widget.motivoRechazo != null &&
              widget.motivoRechazo!.trim().isNotEmpty) ...[
            const SizedBox(height: 18),
            _DescriptionBlock(
              title: 'Motivo de rechazo',
              value: widget.motivoRechazo!,
              danger: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEvidenceCard(BuildContext context) {
    return _SectionCard(
      title: 'Documentación adjunta',
      icon: Icons.attach_file_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Evidencia subida por el solicitante',
            style: AppTextStyles.mainStyleWhite12(context).copyWith(
              color: Colors.white.withValues(alpha: .65),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: _showFullImage,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  Image.network(
                    widget.evidencia,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xff0f213e),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.white.withValues(alpha: .5),
                              size: 34,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'No se pudo cargar la imagen',
                              style: AppTextStyles.mainStyleWhite12(context)
                                  .copyWith(
                                color: Colors.white.withValues(alpha: .7),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: .45),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.zoom_out_map_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Ver completa',
                            style: AppTextStyles.mainStyleWhite12(context)
                                .copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildActionsCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return _SectionCard(
      title: 'Acciones disponibles',
      icon: Icons.gavel_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Define si la solicitud continúa al siguiente proceso o si debe ser rechazada.',
            style: AppTextStyles.mainStyleWhite12(context).copyWith(
              color: Colors.white.withValues(alpha: .65),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _approveRequest,
              icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
              label: const Text('Aprobar solicitud'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xfff2df1d),
                foregroundColor: Colors.black,
                elevation: 0,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _rejectRequest,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.red,
                    side: BorderSide(color: colors.red.withValues(alpha: .8)),
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Rechazar',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.router.back(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.lead,
                    side: BorderSide(color: colors.lead.withValues(alpha: .6)),
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Colors.grey.shade300,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatus() {
    final s = widget.status.toLowerCase();

    if (s == 'pending' || s == 'pendiente') {
      return _StatusBadge(
        text: 'Pendiente de aprobación',
        color: Colors.amber,
      );
    } else if (s == 'approved' || s == 'aprobado') {
      return _StatusBadge(
        text: 'Solicitud aprobada',
        color: Colors.green,
      );
    } else if (s == 'rechazado' || s == 'rejected') {
      return _StatusBadge(
        text: 'Solicitud rechazada',
        color: Colors.red,
      );
    } else {
      return _StatusBadge(
        text: widget.status,
        color: Colors.grey,
      );
    }
  }

  void _showFullImage() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: InteractiveViewer(
            child: Image.network(
              widget.evidencia,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  void _approveRequest() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return CustomDialog(
          title: "Aprobar solicitud",
          isDanger: false,
          content: const Text(
            "La solicitud será aprobada y pasará al siguiente proceso.",
          ),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
            _bloc.add(
              ApproveTheRequestEvent(
                action: 'aprobado',
                requestId: widget.requestId,
                reason: '',
              ),
            );
          },
        );
      },
    );
  }

  void _rejectRequest() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return CustomDialog(
          title: "Rechazar solicitud",
          isDanger: true,
          content: TextFormField(
            controller: rejectedContoller,
            style: AppTextStyles.mainStyleWhite12(context),
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Motivo del rechazo",
              hintStyle: AppTextStyles.mainStyleGrey10(context),
              filled: true,
              fillColor: const Color(0xff0f213e),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          onPressed: () {
            final rejected = rejectedContoller.text.trim();
            if (rejected.isEmpty) {
              CustomAlert.show(
                context,
                title: 'Error',
                message: 'Ingrese el motivo de rechazo.',
                type: AlertType.warning,
              );
              return;
            }
            context.router.back();
            _bloc.add(
              ApproveTheRequestEvent(
                action: 'rechazado',
                requestId: widget.requestId,
                reason: rejected,
              ),
            );
          },
          text: rejectedContoller,
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xff122033),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: .05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .14),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.white70),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.mainStyleWhite14Bold(context).copyWith(
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label.toUpperCase(),
            style: AppTextStyles.mainStyleGrey12Bold(context).copyWith(
              fontSize: 10,
              letterSpacing: .6,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTextStyles.mainStyleWhite12(context).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _DescriptionBlock extends StatelessWidget {
  final String title;
  final String value;
  final bool danger;

  const _DescriptionBlock({
    required this.title,
    required this.value,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = danger
        ? Colors.red.withValues(alpha: .10)
        : const Color(0xff0d1a2b);

    final border = danger
        ? Colors.red.withValues(alpha: .22)
        : Colors.white.withValues(alpha: .05);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: AppTextStyles.mainStyleGrey12Bold(context).copyWith(
            fontSize: 10,
            color: danger ? Colors.red[300] : null,
            letterSpacing: .5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
          ),
          child: Text(
            value,
            style: AppTextStyles.mainStyleWhite12(context).copyWith(
              fontSize: 12,
              color: danger ? Colors.red[100] : Colors.white.withValues(alpha: .9),
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool highlight;

  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.icon,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: highlight ? const Color(0xfff2df1d) : Colors.white70,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.mainStyleWhite12(context).copyWith(
                    color: Colors.white.withValues(alpha: .65),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.mainStyleWhite12(context).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: highlight ? 14 : 12,
                    color: highlight ? const Color(0xfff2df1d) : Colors.white,
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

class _StatusBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusBadge({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: .35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BlockingLoader extends StatelessWidget {
  const _BlockingLoader();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xff122033),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 18),
            Text(
              'Procesando solicitud...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}