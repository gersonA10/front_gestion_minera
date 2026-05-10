import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/core/widgets/excavator_loader.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:front_gestion_minera/utils/text_util.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entity/entity.dart';
import '../bloc/camp_bloc.dart';

@RoutePage()
class UploadReceiptEvidenceScreen extends StatefulWidget {
  final String requestId;
  const UploadReceiptEvidenceScreen({super.key, required this.requestId});

  @override
  State<UploadReceiptEvidenceScreen> createState() =>
      _UploadReceiptEvidenceScreenState();
}

class _UploadReceiptEvidenceScreenState
    extends State<UploadReceiptEvidenceScreen> {
  late final CampBloc _campBloc;
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  XFile? _pickedImage;

  @override
  void initState() {
    super.initState();
    _campBloc = InjectorContainer.getIt<CampBloc>();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source, imageQuality: 85);
    if (image != null) setState(() => _pickedImage = image);
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Tomar foto'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Seleccionar de galería'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSubmit() {
    FocusScope.of(context).unfocus();
    if (_pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe capturar una foto del recibo'),
          backgroundColor: TColors.danger,
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(
      _amountController.text.trim().replaceAll(',', '.'),
    );

    _campBloc.add(
      CloseRequestEvent(
        requestId: widget.requestId,
        request: CloseRequestEntity(
          finalAmount: amount,
          evidencePath: _pickedImage!.path,
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
          backgroundColor: TColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
            onPressed: () => context.router.back(),
          ),
          title: Text(
            'Subir Recibo',
            style: AppTextStyles.mainStyle18Bold(context)
                .copyWith(color: Colors.black),
          ),
          centerTitle: true,
        ),
        body: BlocConsumer<CampBloc, CampState>(
          listener: (context, state) async {
            if (state is RequestClosed) {
              CustomAlert.show(
                context,
                title: "Solicitud Cerrada",
                message: "Tu solicitud ha sido cerrada exitosamente.",
                type: AlertType.success,
              );context.router.back();
              await Future.delayed(const Duration(milliseconds: 1800));
              if (context.mounted) Navigator.of(context).pop(true);
            }
            if (state is RequestCloseError) {
              CustomAlert.show(
                context,
                title: "Error",
                message: state.message,
                type: AlertType.error,
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is RequestClosing;
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Evidencia de Gasto',
                          style: AppTextStyles.mainStyle22Bold(context)
                              .copyWith(color: TColors.darkNavy),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Capture una imagen clara del recibo para finalizar la solicitud de fondo fijo.',
                          style: AppTextStyles.mainStyle14(context)
                              .copyWith(color: TColors.appDisabledColor),
                        ),
                        const SizedBox(height: 25),
                        GestureDetector(
                          onTap: isLoading ? null : _showImageSourceSheet,
                          child: Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.42,
                            decoration: BoxDecoration(
                              color: TColors.photoUploadBg,
                              borderRadius: BorderRadius.circular(20),
                              border: _pickedImage == null
                                  ? Border.all(
                                      color: TColors.borderLight,
                                      width: 1.5,
                                      strokeAlign: BorderSide.strokeAlignInside,
                                    )
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: _pickedImage != null
                                ? Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.file(
                                        File(_pickedImage!.path),
                                        fit: BoxFit.cover,
                                      ),
                                      Positioned(
                                        bottom: 12,
                                        right: 12,
                                        child: ElevatedButton.icon(
                                          onPressed: _showImageSourceSheet,
                                          icon: const Icon(Icons.edit, size: 16),
                                          label: const Text('CAMBIAR'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: TColors.darkNavy
                                                .withValues(alpha: 0.85),
                                            foregroundColor: TColors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 10,
                                            ),
                                            textStyle:
                                                AppTextStyles.mainStyle12Bold(
                                                    context),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: TColors.uploadBlue
                                              .withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.add_a_photo_outlined,
                                          size: 48,
                                          color: TColors.uploadBlue,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Toca para agregar foto',
                                        style: AppTextStyles.mainStyle16Bold(
                                                context)
                                            .copyWith(
                                          color: TColors.darkNavy,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Cámara o galería',
                                        style: AppTextStyles.mainStyle13(context)
                                            .copyWith(color: TColors.subtleHint),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          'MONTO FINAL EJECUTADO (BS)',
                          style: AppTextStyles.mainStyle13Bold(context)
                              .copyWith(color: TColors.darkNavy),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: TColors.white,
                            border: Border.all(color: TColors.fieldBorder),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextFormField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              hintText: '0.00',
                              hintStyle: AppTextStyles.mainStyle16(context)
                                  .copyWith(color: TColors.borderLight),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Text(
                                  'Bs',
                                  style: AppTextStyles.mainStyle16Bold(context)
                                      .copyWith(color: TColors.grayText),
                                ),
                              ),
                              prefixIconConstraints: const BoxConstraints(
                                minWidth: 0,
                                minHeight: 0,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 15,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ingrese el monto final';
                              }
                              final amount =
                                  double.tryParse(value.replaceAll(',', '.'));
                              if (amount == null || amount <= 0) {
                                return 'El monto debe ser mayor a 0';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 18,
                              color: TColors.appDisabledColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Asegúrese de que el monto coincida exactamente con el total del recibo adjunto.',
                                style: AppTextStyles.mainStyle12(context)
                                    .copyWith(color: TColors.appDisabledColor),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton.icon(
                            onPressed: _onSubmit,
                            icon: const Icon(Icons.check_circle_outline),
                            label: Text(
                              'CERRAR SOLICITUD',
                              style: AppTextStyles.mainStyle16Bold(context),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TColors.primary,
                              foregroundColor: TColors.white,
                              disabledBackgroundColor:
                                  TColors.primary.withValues(alpha: 0.6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
