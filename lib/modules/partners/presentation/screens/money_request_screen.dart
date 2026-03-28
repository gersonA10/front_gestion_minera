import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/theme/extension_theme.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/utils/session/user_session.dart';
import 'package:front_gestion_minera/utils/text_util.dart';
import 'package:image_picker/image_picker.dart';
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

  String _area = 'Cargando...';
  String _solicitante = 'Cargando...';

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final role = await UserSession.getRole();
    final fullName = await UserSession.getFullName();
    setState(() {
      _area = role.isNotEmpty ? role : 'Administración';
      _solicitante = fullName;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

void _showImageSourceSelector() {
  final parentContext = context; 

  showModalBottomSheet(
    context: parentContext,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto'),
              onTap: () async {
                Navigator.of(sheetContext).pop(); 
                await Future.delayed(const Duration(milliseconds: 200));
                await _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Elegir de galería'),
              onTap: () async {
                Navigator.of(sheetContext).pop(); 
                await Future.delayed(const Duration(milliseconds: 200));
                await _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      );
    },
  );
}
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
            style: AppTextStyles.mainStyle16Bold(
              context,
            ).copyWith(color: colors.black),
          ),
        ),
        body: BlocConsumer<PartnersBloc, PartnersState>(
          listener: (context, state) {
            if (state is PartnersMoneyRequestSuccess) {
              CustomAlert.show(
                context,
                title: 'Éxito',
                message: 'La solicitud se ha registrado correctamente.',
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
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'COMPROBANTE DE EGRESO',
                    style: AppTextStyles.mainStyleGrey12Bold(context),
                  ),
                  SizedBox(height: smallSpacing * 0.5),

                  GestureDetector(
                    onTap: _showImageSourceSelector,
                    child: Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: colors.lead.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colors.lead, width: 1.5),
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.camera_alt_outlined,
                                color: colors.blue,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: smallSpacing),

                  // Tarjetas (Cargadas dinámicamente)
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          context: context,
                          icon: Icons.business_outlined,
                          label: 'Área / Rol',
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
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: AppTextStyles.mainStyle16Bold(context),
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                          'Bs',
                          style: AppTextStyles.mainStyleBlue18Bold(context),
                        ),
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
                    textCapitalization: TextCapitalization.sentences,
                    controller: _descripcionController,
                    maxLines: 4,
                    textInputAction: TextInputAction.done, 
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).unfocus(); 
                    },
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
                              final monto =
                                  double.tryParse(_montoController.text) ?? 0.0;
                              if (monto <= 0) {
                                CustomAlert.show(
                                  context,
                                  title: 'Error',
                                  message: 'Ingrese un monto válido',
                                  type: AlertType.warning,
                                );
                                return;
                              }

                              if (_selectedImage == null) {
                                CustomAlert.show(
                                  context,
                                  title: 'Error',
                                  message: 'Debe agregar un comprobante',
                                  type: AlertType.warning,
                                );
                                return;
                              }

                              context.read<PartnersBloc>().add(
                                PartnersSubmitMoneyRequestEvent(
                                  area: _area,
                                  requestedAmount: monto,
                                  description: _descripcionController.text,
                                  evidenceUrlPath: _selectedImage!.path,
                                  // area: _area,
                                  // solicitante: _solicitante,
                                  // monto: monto,
                                  // descripcion: _descripcionController.text,
                                  // comprobantePath: _selectedImage?.path,
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
                                  style: AppTextStyles.mainStyleWhite16Bold(
                                    context,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.send_outlined,
                                  color: Colors.white,
                                  size: 20,
                                ),
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
          Text(
            value,
            style: AppTextStyles.mainStyle14Bold(context),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
