import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
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
    if (_pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe capturar una foto del recibo'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(
      _amountController.text.trim().replaceAll(',', '.'),
    );

    _campBloc.add(CloseRequestEvent(
      requestId: widget.requestId,
      request: CloseRequestEntity(
        finalAmount: amount,
        evidencePath: _pickedImage!.path,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _campBloc,
      child: BlocConsumer<CampBloc, CampState>(
        listenWhen: (_, state) =>
            state is RequestClosed || state is RequestCloseError,
        listener: (context, state) {
          if (state is RequestClosed) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Solicitud cerrada correctamente'),
                backgroundColor: Colors.green,
              ),
            );
            context.router.back();
          }
          if (state is RequestCloseError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        buildWhen: (_, state) =>
            state is RequestClosing ||
            state is RequestClosed ||
            state is RequestCloseError ||
            state is CampInitial,
        builder: (context, state) {
          final isLoading = state is RequestClosing;
          return Scaffold(
            backgroundColor: TColors.appBackgroundColor,
            appBar: AppBar(
              backgroundColor: TColors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
                onPressed: () => context.router.back(),
              ),
              title: const Text(
                'Subir Recibo',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Evidencia de Gasto',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1F26),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Capture una imagen clara del recibo para finalizar la solicitud de fondo fijo.',
                      style: TextStyle(
                          fontSize: 14, color: TColors.appDisabledColor),
                    ),
                    const SizedBox(height: 25),
                    Container(
                      width: double.infinity,
                      height: 350,
                      decoration: BoxDecoration(
                        color: TColors.disabled.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Container(
                          width: 250,
                          height: 300,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F6F8),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 20),
                              if (_pickedImage != null)
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      File(_pickedImage!.path),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  ),
                                )
                              else ...[
                                const Icon(
                                  Icons.receipt_long_outlined,
                                  size: 80,
                                  color: Color(0xFF9DA4B0),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Sin imagen seleccionada',
                                  style: TextStyle(
                                    color: Color(0xFF1E88E5),
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                              const Spacer(),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ElevatedButton.icon(
                                  onPressed: isLoading ? null : _showImageSourceSheet,
                                  icon: const Icon(Icons.camera_alt_outlined,
                                      size: 20),
                                  label: Text(_pickedImage != null
                                      ? 'CAMBIAR IMAGEN'
                                      : 'AGREGAR IMAGEN'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1A1F26),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'MONTO FINAL EJECUTADO (BS)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1F26),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: TColors.white,
                        border: Border.all(color: const Color(0xFFE9EBF0)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          hintText: '0.00',
                          hintStyle: TextStyle(
                            color: Color(0xFFD1D5DB),
                            fontSize: 16,
                          ),
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(15),
                            child: Text(
                              'Bs',
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          prefixIconConstraints: BoxConstraints(
                            minWidth: 0,
                            minHeight: 0,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 15),
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
                      children: const [
                        Icon(Icons.info_outline,
                            size: 18, color: TColors.appDisabledColor),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Asegúrese de que el monto coincida exactamente con el total del recibo adjunto.',
                            style: TextStyle(
                                fontSize: 12, color: TColors.appDisabledColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : _onSubmit,
                        icon: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.check_circle_outline),
                        label: Text(
                          isLoading ? 'Cerrando...' : 'CERRAR SOLICITUD',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColors.primary,
                          foregroundColor: Colors.white,
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
          );
        },
      ),
    );
  }
}
