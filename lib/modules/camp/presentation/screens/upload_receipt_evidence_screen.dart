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
  const UploadReceiptEvidenceScreen({super.key});

  @override
  State<UploadReceiptEvidenceScreen> createState() =>
      _UploadReceiptEvidenceScreenState();
}

class _UploadReceiptEvidenceScreenState
    extends State<UploadReceiptEvidenceScreen> {
  late final CampBloc _campBloc;
  final _formKey = GlobalKey<FormState>();
  final _conceptController = TextEditingController();
  final _detailController = TextEditingController();
  final _amountController = TextEditingController();
  final _picker = ImagePicker();
  XFile? _pickedImage;

  @override
  void initState() {
    super.initState();
    _campBloc = InjectorContainer.getIt<CampBloc>();
  }

  @override
  void dispose() {
    _conceptController.dispose();
    _detailController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _showImageSourceSheet() async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Agregar comprobante',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: TColors.appMainColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: TColors.appMainColor,
                  ),
                ),
                title: const Text(
                  'Tomar foto',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Usar la cámara del dispositivo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: TColors.appMainColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.photo_library_outlined,
                    color: TColors.appMainColor,
                  ),
                ),
                title: const Text(
                  'Elegir de galería',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Seleccionar una imagen existente'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? photo = await _picker.pickImage(source: source);
    if (photo != null) {
      setState(() => _pickedImage = photo);
    }
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    if (_pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, agrega un comprobante de evidencia'),
          backgroundColor: TColors.red,
        ),
      );
      return;
    }

    _campBloc.add(CreateCampRequestEvent(
      request: CreateCampRequestEntity(
        concept: _conceptController.text.trim(),
        detail: _detailController.text.trim(),
        requestedAmount: double.parse(_amountController.text.trim()),
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
            state is CampRequestCreated || state is CampRequestCreateError,
        listener: (context, state) {
          if (state is CampRequestCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Solicitud creada exitosamente'),
                backgroundColor: TColors.green,
              ),
            );
            context.router.back();
          }
          if (state is CampRequestCreateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: TColors.red,
              ),
            );
          }
        },
        buildWhen: (_, state) =>
            state is CampRequestCreating ||
            state is CampRequestCreated ||
            state is CampRequestCreateError ||
            state is CampInitial,
        builder: (context, state) {
          final isLoading = state is CampRequestCreating;
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
                'Nueva Solicitud',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              centerTitle: true,
            ),
            body: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Solicitud de Egreso',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1F26),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Complete los datos para registrar una nueva solicitud de fondo fijo.',
                      style: TextStyle(
                        fontSize: 14,
                        color: TColors.appDisabledColor,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _FieldLabel('Concepto'),
                    const SizedBox(height: 8),
                    _InputField(
                      controller: _conceptController,
                      hintText: 'Ej. Compra de Víveres Quincena 1',
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'El concepto es requerido';
                        }
                        if (v.trim().length < 5) {
                          return 'El concepto debe tener al menos 5 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _FieldLabel('Detalle'),
                    const SizedBox(height: 8),
                    _InputField(
                      controller: _detailController,
                      hintText: 'Ej. Insumos para el comedor del campamento norte',
                      maxLines: 3,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'El detalle es requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _FieldLabel('Monto Solicitado (Bs)'),
                    const SizedBox(height: 8),
                    _InputField(
                      controller: _amountController,
                      hintText: '0.00',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      prefixText: 'Bs  ',
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'El monto es requerido';
                        }
                        final amount = double.tryParse(v.trim());
                        if (amount == null || amount <= 0) {
                          return 'Ingrese un monto válido mayor a 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: TColors.appDisabledColor,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'El monto solicitado debe coincidir con el gasto estimado a ejecutar.',
                            style: TextStyle(
                              fontSize: 12,
                              color: TColors.appDisabledColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    _FieldLabel('Comprobante de Evidencia'),
                    const SizedBox(height: 12),
                    _pickedImage == null
                        ? _UploadArea(onTap: _showImageSourceSheet)
                        : _ImagePreview(
                            file: File(_pickedImage!.path),
                            onRemove: () =>
                                setState(() => _pickedImage = null),
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
                          isLoading ? 'CREANDO...' : 'CREAR SOLICITUD',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColors.appMainColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              TColors.appMainColor.withValues(alpha: 0.6),
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

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A1F26),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? prefixText;
  final String? Function(String?)? validator;

  const _InputField({
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
    this.keyboardType,
    this.prefixText,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TColors.white,
        border: Border.all(color: const Color(0xFFE9EBF0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 15),
          prefixText: prefixText,
          prefixStyle: const TextStyle(
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          errorStyle: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}

class _UploadArea extends StatelessWidget {
  final VoidCallback onTap;
  const _UploadArea({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: TColors.white,
          border: Border.all(
            color: TColors.appMainColor.withValues(alpha: 0.4),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: TColors.appMainColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_a_photo_outlined,
                color: TColors.appMainColor,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Agregar foto del comprobante',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: TColors.appMainColor,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.camera_alt_outlined,
                    size: 14, color: TColors.appDisabledColor),
                SizedBox(width: 4),
                Text('Cámara',
                    style: TextStyle(
                        fontSize: 12, color: TColors.appDisabledColor)),
                SizedBox(width: 12),
                Icon(Icons.photo_library_outlined,
                    size: 14, color: TColors.appDisabledColor),
                SizedBox(width: 4),
                Text('Galería',
                    style: TextStyle(
                        fontSize: 12, color: TColors.appDisabledColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final File file;
  final VoidCallback onRemove;
  const _ImagePreview({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            file,
            width: double.infinity,
            height: 180,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: -10,
          right: -10,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }
}
