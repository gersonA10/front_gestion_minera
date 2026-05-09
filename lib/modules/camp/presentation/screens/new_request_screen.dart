import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/core/widgets/excavator_loader.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/camp/presentation/widgets/widgets.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/widgets/widgtes.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import '../../domain/entity/entity.dart';
import '../bloc/camp_bloc.dart';

@RoutePage()
class NewRequestScreen extends StatefulWidget {
  const NewRequestScreen({super.key});

  @override
  State<NewRequestScreen> createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends State<NewRequestScreen> {
  late final CampBloc _campBloc;
  final _formKey = GlobalKey<FormState>();

  final tituloController = TextEditingController();
  final montoController = TextEditingController();
  final fechaController = TextEditingController();
  final detailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _campBloc = InjectorContainer.getIt<CampBloc>();
    final hoy = DateTime.now();
    fechaController.text = "${hoy.month}/${hoy.day}/${hoy.year}";
  }

  @override
  void dispose() {
    tituloController.dispose();
    montoController.dispose();
    fechaController.dispose();
    detailController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final monto = double.parse(
      montoController.text.trim().replaceAll(',', '.'),
    );

    _campBloc.add(
      CreateCampRequestEvent(
        request: CreateCampRequestEntity(
          concept: tituloController.text.trim(),
          detail: detailController.text.trim(),
          requestedAmount: monto,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _campBloc,
      child: Scaffold(
        backgroundColor: TColors.appBackgroundColor,
        appBar: AppBar(
          title: const Text(
            "Nueva Solicitud",
            style: TextStyle(color: TColors.white),
          ),
          backgroundColor: const Color(0xFF0A1D37),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => context.router.back(),
          ),
        ),
        body: BlocConsumer<CampBloc, CampState>(
          listener: (context, state) {
            if (state is CampRequestCreated) {
              CustomAlert.show(
                context,
                title: "Solicitud Creada",
                message: "Tu solicitud ha sido creada exitosamente.",
                type: AlertType.success,
              );
              Navigator.of(context).pop(true);
            }
            if (state is CampRequestCreateError) {
              CustomAlert.show(
                context,
                title: "Error",
                message: state.message,
                type: AlertType.error,
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is CampRequestCreating;
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Detalles",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "Complete la información.",
                        style: TextStyle(color: TColors.greyText),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              CustomTextFormFieldWidget(
                                label: "Título",
                                icon: Icons.campaign_rounded,
                                hint: "Compra de Viveres",
                                controller: tituloController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Ingrese un título";
                                  }
                                  return null;
                                },
                              ),
                              CustomTextFormFieldWidget(
                                label: "Monto solicitado (Bs)",
                                icon: Icons.money,
                                hint: "0.00",
                                suffixText: "Bs",
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                controller: montoController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Ingrese un monto";
                                  }
                                  final monto = double.tryParse(
                                    value.replaceAll(',', '.'),
                                  );
                                  if (monto == null || monto <= 0) {
                                    return "El monto debe ser mayor a 0";
                                  }
                                  return null;
                                },
                              ),
                              CustomTextFormFieldWidget(
                                label: "Fecha estimada de compra",
                                icon: Icons.calendar_today_rounded,
                                hint: "mm/dd/yyyy",
                                controller: fechaController,
                                readOnly: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Seleccione una fecha";
                                  }
                                  return null;
                                },
                              ),
                              CustomTextFormFieldWidget(
                                label: "Descripción o detalle de compra",
                                icon: Icons.description_rounded,
                                hint:
                                    "Describa los insumos, herramientas o servicios requeridos...",
                                maxLines: 4,
                                controller: detailController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Ingrese un detalle";
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info, color: Colors.blue),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Esta solicitud será revisada por vigilancia.",
                                style: TextStyle(
                                  color: TColors.appMainColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: _onSubmit,
                        icon: const Icon(Icons.send, color: TColors.white),
                        label: Text(
                          "Enviar Solicitud",
                          style: const TextStyle(color: TColors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E88E5),
                          disabledBackgroundColor: const Color(
                            0xFF1E88E5,
                          ).withValues(alpha: 0.6),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isLoading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: const Center(child: ExcavatorLoader()),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
