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

import '../../domain/entity/entity.dart';

@RoutePage()
class ApplicationDetailsScreen extends StatefulWidget {
  final MonitoringTrayDataEntity item;
  const ApplicationDetailsScreen({super.key, required this.item});

  @override
  State<ApplicationDetailsScreen> createState() =>
      _ApplicationDetailsScreenState();

  static Widget _infoRow(
    BuildContext context,
    String label,
    String value, {
    bool highlight = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.mainStyleGrey12Bold(
                context,
              ).copyWith(fontSize: 10),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: highlight ? Colors.yellow : Colors.white,
              fontSize: highlight ? 14 : 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _ApplicationDetailsScreenState extends State<ApplicationDetailsScreen> {
  final TextEditingController rejectedContoller = TextEditingController();
  late final SurveillanceBloc _bloc;
  Widget _buildStatus() {
    switch (widget.item.status) {
      case 'PENDING':
        return _statusChip(
          text: "Pendiente de aprobación",
          color: Colors.amber,
        );

      case 'APPROVED':
        return _statusChip(text: "Solicitud aprobada", color: Colors.green);

      case 'rechazado':
        return _statusChip(text: "Solicitud rechazada", color: Colors.red);

      default:
        return const SizedBox();
    }
  }

  Widget _statusChip({required String text, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: .4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 6, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _bloc = InjectorContainer.getIt<SurveillanceBloc>();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final smallSpacing = screenSize.height * 0.02;
    final double topPadding = screenSize.height * 0.2;
    final colors = Theme.of(context).colorScheme;
    const background = Color(0xff0b1d3a);
    const cardColor = Color(0xff1b2b44);

    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<SurveillanceBloc, SurveillanceState>(
        listener: (context, state) {
          if (state is ApproveTheRequestLoading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );
          }
          if (state is ApproveTheRequestSuccess) {
            Navigator.pop(context);
            context.router.maybePop(true);
            CustomAlert.show(
              context,
              title: 'Éxito',
              message: "Solicitud procesada correctamente",
              type: AlertType.success,
            );
          }
          if (state is ApproveTheRequestError) {
            Navigator.pop(context);

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
          appBar: AppBar(
            backgroundColor: background,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: colors.white,
                size: smallSpacing * 1,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text(
              "Detalle de Solicitud",
              style: AppTextStyles.mainStyleWhite14Bold(context),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "ESTADO ACTUAL",
                  style: AppTextStyles.mainStyleGrey12Bold(
                    context,
                  ).copyWith(fontSize: 10),
                ),
                SizedBox(height: smallSpacing * 0.5),
                _buildStatus(),
                SizedBox(height: smallSpacing * 1.5),
                Container(
                  padding: EdgeInsets.all(topPadding * 0.08),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: colors.lead,
                          ),
                          SizedBox(width: 6),
                          Text(
                            "INFORMACIÓN GENERAL",
                            style: AppTextStyles.mainStyleGrey12Bold(
                              context,
                            ).copyWith(fontSize: 10),
                          ),
                        ],
                      ),
                      SizedBox(height: smallSpacing * 0.8),
                      ApplicationDetailsScreen._infoRow(
                        context,
                        "Fecha",
                        formatDate(widget.item.createdAt),
                      ),
                      Divider(color: Colors.white12),
                      ApplicationDetailsScreen._infoRow(
                        context,
                        "Área",
                        widget.item.rol,
                      ),
                      Divider(color: Colors.white12),

                      ApplicationDetailsScreen._infoRow(
                        context,
                        "Solicitante",
                        widget.item.name,
                      ),
                      Divider(color: Colors.white12),

                      ApplicationDetailsScreen._infoRow(
                        context,
                        "Monto",
                        "${widget.item.amount} Bs.",
                        highlight: true,
                      ),
                      SizedBox(height: smallSpacing * 0.6),
                      Text(
                        "Descripción",
                        style: AppTextStyles.mainStyleGrey12Bold(
                          context,
                        ).copyWith(fontSize: 10),
                      ),
                      SizedBox(height: smallSpacing * 0.5),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xff0f213e),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.item.description,
                          style: AppTextStyles.mainStyleWhite12(
                            context,
                          ).copyWith(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: smallSpacing * 0.8),
                Text(
                  "DOCUMENTACIÓN ADJUNTA",
                  style: AppTextStyles.mainStyleGrey12Bold(
                    context,
                  ).copyWith(fontSize: 10),
                ),
                SizedBox(height: smallSpacing * 0.8),
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              backgroundColor: Colors.transparent,
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Image.network(
                                  widget.item.evidencia,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            widget.item.evidencia,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 120,
                                color: Colors.grey[800],
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 120,
                                color: Colors.grey[800],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Comprobante_320_CAT.pdf",
                                  style: AppTextStyles.mainStyleWhite10Bold(
                                    context,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "2.4 MB • PDF DOCUMENT",
                                  style: AppTextStyles.mainStyleWhite12(
                                    context,
                                  ).copyWith(fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.download, color: colors.white),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: smallSpacing * 1),
                if (widget.item.status == 'PENDING') ...[
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
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
                                    Navigator.pop(context);
                                    _bloc.add(
                                      ApproveTheRequestEvent(
                                        action: 'aprobado',
                                        requestId: widget.item.requestId,
                                        reason: '',
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xfff2df1d),
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: smallSpacing * 0.8,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Aprobar Solicitud",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: smallSpacing * 0.8),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: OutlinedButton(
                                onPressed: () {
                                  showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (context) {
                                      return CustomDialog(
                                        title: "Rechazar solicitud",
                                        isDanger: true,
                                        content: TextFormField(
                                          controller: rejectedContoller,
                                          style: AppTextStyles.mainStyleWhite12(
                                            context,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: "Motivo del rechazo",
                                            hintStyle:
                                                AppTextStyles.mainStyleGrey10(
                                                  context,
                                                ),
                                            filled: true,
                                            fillColor: const Color(0xff0f213e),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                        ),
                                        onPressed: () async {
                                          final rejected =
                                              rejectedContoller.text;
                                          if (rejected.isEmpty) {
                                            CustomAlert.show(
                                              context,
                                              title: 'Error',
                                              message:
                                                  'Ingrese el motivo de rechazo.',
                                              type: AlertType.warning,
                                            );
                                            return;
                                          }
                                          Navigator.pop(context);
                                          _bloc.add(
                                            ApproveTheRequestEvent(
                                              action: 'rechazado',
                                              requestId: widget.item.requestId,
                                              reason: rejectedContoller.text,
                                            ),
                                          );
                                        },
                                        text: rejectedContoller,
                                      );
                                    },
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: colors.red,
                                  side: BorderSide(color: colors.red),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  "Rechazar",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: colors.lead,
                                  side: BorderSide(color: colors.lead),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  "Cancelar",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
