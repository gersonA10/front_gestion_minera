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

  static Widget _infoRow(
    BuildContext context,
    String label,
    String value, {
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.mainStyleGrey12Bold(context).copyWith(fontSize: 10),
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

  bool get isPending {
    final s = widget.status.toLowerCase();
    return s == 'pending' || s == 'pendiente';
  }

  bool get isRejected {
    final s = widget.status.toLowerCase();
    return s == 'rechazado' || s == 'rejected';
  }

  Widget _buildStatus() {
    final s = widget.status.toLowerCase();
    
    if (s == 'pending' || s == 'pendiente') {
      return _statusChip(text: "Pendiente de aprobación", color: Colors.amber);
    } else if (s == 'approved' || s == 'aprobado') {
      return _statusChip(text: "Solicitud aprobada", color: Colors.green);
    } else if (s == 'rechazado' || s == 'rejected') {
      return _statusChip(text: "Solicitud rechazada", color: Colors.red);
    } else {
      return _statusChip(text: widget.status, color: Colors.grey);
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
    rejectedContoller.dispose();
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
            context.router.back(); 
            context.router.maybePop(true); 
            CustomAlert.show(
              context,
              title: 'Éxito',
              message: "Solicitud procesada correctamente",
              type: AlertType.success,
            );
          }
          if (state is ApproveTheRequestError) {
            context.router.back();
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
              onPressed: () => context.router.back()
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
                  style: AppTextStyles.mainStyleGrey12Bold(context).copyWith(fontSize: 10),
                ),
                SizedBox(height: smallSpacing * 0.5),
                _buildStatus(),
                SizedBox(height: smallSpacing * 1.5),
                
                // CAJA DE INFORMACIÓN
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
                          Icon(Icons.info_outline, size: 16, color: colors.lead),
                          const SizedBox(width: 6),
                          Text(
                            "INFORMACIÓN GENERAL",
                            style: AppTextStyles.mainStyleGrey12Bold(context).copyWith(fontSize: 10),
                          ),
                        ],
                      ),
                      SizedBox(height: smallSpacing * 0.8),
                      ApplicationDetailsScreen._infoRow(context, "Fecha", formatDate(widget.createdAt)),
                      const Divider(color: Colors.white12),
                      ApplicationDetailsScreen._infoRow(context, "Área", widget.rol),
                      const Divider(color: Colors.white12),
                      ApplicationDetailsScreen._infoRow(context, "Solicitante", widget.name),
                      const Divider(color: Colors.white12),
                      ApplicationDetailsScreen._infoRow(context, "Monto", "${widget.amount} Bs.", highlight: true),
                      
                      SizedBox(height: smallSpacing * 0.6),
                      Text("Descripción", style: AppTextStyles.mainStyleGrey12Bold(context).copyWith(fontSize: 10)),
                      SizedBox(height: smallSpacing * 0.5),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: const Color(0xff0f213e), borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          widget.description,
                          style: AppTextStyles.mainStyleWhite12(context).copyWith(fontSize: 10),
                        ),
                      ),

                      // MOTIVO DE RECHAZO 
                      if (isRejected && widget.motivoRechazo != null && widget.motivoRechazo!.isNotEmpty) ...[
                        SizedBox(height: smallSpacing * 0.6),
                        Text("Motivo de rechazo", style: AppTextStyles.mainStyleGrey12Bold(context).copyWith(fontSize: 10, color: Colors.red[300])),
                        SizedBox(height: smallSpacing * 0.5),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                          child: Text(
                            widget.motivoRechazo!,
                            style: AppTextStyles.mainStyleWhite12(context).copyWith(fontSize: 10, color: Colors.red[200]),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
                SizedBox(height: smallSpacing * 0.8),
                Text(
                  "DOCUMENTACIÓN ADJUNTA",
                  style: AppTextStyles.mainStyleGrey12Bold(context).copyWith(fontSize: 10),
                ),
                SizedBox(height: smallSpacing * 0.8),
                Container(
                  decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              backgroundColor: Colors.transparent,
                              child: GestureDetector(
                                onTap: () => context.router.back(),
                                child: Image.network(widget.evidencia, fit: BoxFit.contain),
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            widget.evidencia,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 120,
                              color: Colors.grey[800],
                              child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: smallSpacing * 1),
                
                if (isPending) ...[
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
                                  content: const Text("La solicitud será aprobada y pasará al siguiente proceso."),
                                  onPressed: () {
                                    context.router.back();
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
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xfff2df1d),
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline, size: smallSpacing * 0.8),
                              const SizedBox(width: 8),
                              const Text("Aprobar Solicitud", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
                                          style: AppTextStyles.mainStyleWhite12(context),
                                          decoration: InputDecoration(
                                            hintText: "Motivo del rechazo",
                                            hintStyle: AppTextStyles.mainStyleGrey10(context),
                                            filled: true,
                                            fillColor: const Color(0xff0f213e),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          final rejected = rejectedContoller.text;
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
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text("Rechazar", style: TextStyle(fontSize: 12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: TextButton(
                                onPressed: () => context.router.back(),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: colors.lead,
                                  side: BorderSide(color: colors.lead),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text("Cancelar", style: TextStyle(color: Colors.grey, fontSize: 12)),
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