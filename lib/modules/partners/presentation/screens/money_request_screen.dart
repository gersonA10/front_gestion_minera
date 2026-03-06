import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/utils/text_util.dart';
import '../bloc/partners_bloc.dart'; 

@RoutePage()
class MoneyRequestScreen extends StatefulWidget {
  const MoneyRequestScreen({super.key});

  @override
  State<MoneyRequestScreen> createState() => _MoneyRequestScreenState();
}

class _MoneyRequestScreenState extends State<MoneyRequestScreen> {
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  final String _area = 'Administración';
  final String _solicitante = 'Julio Rivas';

  @override
  void dispose() {
    _montoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final smallSpacing = MediaQuery.of(context).size.height * 0.02;

    return BlocProvider(
      create: (context) => InjectorContainer.getIt<PartnersBloc>(),
      child: Scaffold(
        backgroundColor: colors.backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: colors.backgroundColor,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: colors.blue),
            onPressed: () => context.router.back(),
          ),
          title: Text(
            'Solicitud de Dinero',
            style: AppTextStyles.mainStyle16Bold(context)
                .copyWith(color: colors.black),
          ),
        ),
        body: BlocConsumer<PartnersBloc, PartnersState>(
          listener: (context, state) {
            if (state is PartnersMoneyRequestSuccess) {
              CustomAlert.show(
                context,
                title: 'Éxito',
                message: 'La solicitud se ha enviado correctamente.',
                type: AlertType.success,
              );
              context.router.back();
            } else if (state is PartnersMoneyRequestError) {
              CustomAlert.show(
                context,
                title: 'Error',
                message: state.message,
                type: AlertType.error,
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is PartnersMoneyRequestLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'COMPROBANTE DE EGRESO',
                    style: AppTextStyles.mainStyleGrey12Bold(context),
                  ),
                  SizedBox(height: smallSpacing * 0.5),
                  
                  // Área del Comprobante
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: colors.lead.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colors.lead, width: 1.5),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Icon(Icons.camera_alt_outlined, color: colors.blue),
                      ),
                    ),
                  ),
                  SizedBox(height: smallSpacing),

                  // Tarjetas
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          context: context,
                          icon: Icons.business_outlined,
                          label: 'Área',
                          value: _area,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          context: context,
                          icon: Icons.person_outline,
                          label: 'Solicitante',
                          value: _solicitante,
                          iconColor: colors.amber,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: smallSpacing * 1.5),

                  Text(
                    'Monto a Solicitar',
                    style: AppTextStyles.mainStyleBlack14(context),
                  ),
                  SizedBox(height: smallSpacing * 0.5),
                  TextFormField(
                    controller: _montoController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: AppTextStyles.mainStyle16Bold(context),
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text('\$', style: AppTextStyles.mainStyleBlue18Bold(context)),
                      ),
                      hintText: '0.00',
                      hintStyle: AppTextStyles.mainStyleGrey14Bold(context),
                      filled: true,
                      fillColor: colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: smallSpacing * 1.5),

                  Text(
                    'Descripción / Motivo',
                    style: AppTextStyles.mainStyleBlack14(context),
                  ),
                  SizedBox(height: smallSpacing * 0.5),
                  TextFormField(
                    controller: _descripcionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Ej. Pago de servicios de logística minera...',
                      hintStyle: AppTextStyles.mainStyleGrey12(context),
                      filled: true,
                      fillColor: colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: smallSpacing * 1.5),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.bluebajo.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.bluebajo.withOpacity(0.5)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: colors.blue, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Esta solicitud será enviada al departamento de actas para su aprobación final. Asegúrese de que el comprobante sea legible.',
                            style: AppTextStyles.mainStyleGrey12(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: smallSpacing * 2.5),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: isLoading
                          ? null
                          : () {
                              final monto = double.tryParse(_montoController.text) ?? 0.0;
                              context.read<PartnersBloc>().add(
                                    PartnersSubmitMoneyRequestEvent(
                                      area: _area,
                                      solicitante: _solicitante,
                                      monto: monto,
                                      descripcion: _descripcionController.text,
                                    ),
                                  );
                            },
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Solicitar Egreso',
                                  style: AppTextStyles.mainStyleWhite16Bold(context),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.send_outlined, color: Colors.white, size: 20),
                              ],
                            ),
                    ),
                  ),
                  SizedBox(height: smallSpacing * 2),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    Color? iconColor,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor ?? colors.blue),
              const SizedBox(width: 8),
              Text(label, style: AppTextStyles.mainStyleGrey12(context)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.mainStyle14Bold(context)),
        ],
      ),
    );
  }
}