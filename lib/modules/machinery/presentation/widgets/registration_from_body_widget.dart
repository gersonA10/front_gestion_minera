import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/core/widgets/excavator_loader.dart';
import 'package:front_gestion_minera/modules/machinery/presentation/bloc/machinery_bloc.dart';
import 'package:front_gestion_minera/modules/machinery/presentation/widgets/info_banner_widget.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entity/entity.dart';

class RegistrationFormBody extends StatefulWidget {
  const RegistrationFormBody({super.key});

  @override
  State<RegistrationFormBody> createState() => _RegistrationFormBodyState();
}

class _RegistrationFormBodyState extends State<RegistrationFormBody> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  TypeMachineryEntity? _selectedType;
  List<TypeMachineryEntity> _types = [];
  XFile? _pickedImage;

  AutovalidateMode _autoValidate = AutovalidateMode.disabled;
  bool _typeError = false;
  bool _photoError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: TColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => const _ImageSourceSheet(),
    );
    if (source == null) return;
    final image = await ImagePicker().pickImage(
      source: source,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() {
        _pickedImage = image;
        _photoError = false;
      });
    }
  }

  void _submit(BuildContext context) {
    final formValid = _formKey.currentState?.validate() ?? false;
    final typeValid = _selectedType != null;
    final photoValid = _pickedImage != null;

    setState(() {
      _autoValidate = AutovalidateMode.onUserInteraction;
      _typeError = !typeValid;
      _photoError = !photoValid;
    });

    if (!formValid || !typeValid || !photoValid) return;

    context.read<MachineryBloc>().add(
          RegisterMachineryEvent(
            request: RegisterMachineryRequestEntity(
              name: _nameController.text.trim(),
              uniqueCode: _codeController.text.trim(),
              typeId: _selectedType!.id,
              description: _descriptionController.text.trim(),
              photoPath: _pickedImage!.path,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MachineryBloc, MachineryState>(
      listenWhen: (_, current) =>
          current is RegisterMachinerySuccess ||
          current is RegisterMachineryError ||
          current is TypeMachineryLoaded,
      listener: (context, state) {
        if (state is TypeMachineryLoaded) {
          setState(() {
            _types = state.types.where((t) => t.id != 'todos').toList();
          });
        }
        if (state is RegisterMachinerySuccess) {
          CustomAlert.show(
            context,
            title: '¡Éxito!',
            message: 'Maquinaria registrada exitosamente.',
            type: AlertType.success,
          );
          context.router.maybePop(true);
        }
        if (state is RegisterMachineryError) {
          // Mantenemos el formulario para que el usuario pueda reintentar.
          CustomAlert.show(
            context,
            title: 'Error',
            message: state.message,
            type: AlertType.error,
          );
        }
      },
      buildWhen: (_, current) =>
          current is RegisterMachineryLoading ||
          current is RegisterMachinerySuccess ||
          current is RegisterMachineryError ||
          current is TypeMachineryLoading ||
          current is TypeMachineryLoaded,
      builder: (context, state) {
        final submitting = state is RegisterMachineryLoading;
        final loadingTypes = state is TypeMachineryLoading;

        return Stack(
          children: [
            Form(
              key: _formKey,
              autovalidateMode: _autoValidate,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const InfoBanner(),
                    const SizedBox(height: 24),

                    // ── Identificación ──────────────────────────────────
                    _sectionTitle(
                      Icons.badge_outlined,
                      'Identificación',
                    ),
                    const SizedBox(height: 16),
                    _label('Nombre de la maquinaria'),
                    const SizedBox(height: 8),
                    _textField(
                      controller: _nameController,
                      hint: 'Ej. Excavadora Hidráulica 320',
                      icon: Icons.precision_manufacturing_outlined,
                      enabled: !submitting,
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 18),
                    _label('Código de máquina'),
                    const SizedBox(height: 8),
                    _textField(
                      controller: _codeController,
                      hint: 'MH-2024-001',
                      icon: Icons.tag_rounded,
                      enabled: !submitting,
                      textCapitalization: TextCapitalization.characters,
                    ),
                    const SizedBox(height: 18),
                    _label('Tipo de maquinaria'),
                    const SizedBox(height: 8),
                    TypeDropdown(
                      value: _selectedType,
                      types: _types,
                      enabled: !submitting,
                      loading: loadingTypes,
                      hasError: _typeError,
                      onChanged: (t) => setState(() {
                        _selectedType = t;
                        _typeError = false;
                      }),
                    ),
                    if (_typeError)
                      _errorText('Selecciona un tipo de maquinaria'),
                    const SizedBox(height: 24),

                    // ── Descripción ─────────────────────────────────────
                    _sectionTitle(
                      Icons.description_outlined,
                      'Descripción técnica',
                    ),
                    const SizedBox(height: 16),
                    _label('Especificaciones'),
                    const SizedBox(height: 8),
                    _textField(
                      controller: _descriptionController,
                      hint:
                          'Motor, capacidad de carga, horas de uso iniciales y '
                          'estado actual...',
                      enabled: !submitting,
                      maxLines: 5,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 24),

                    // ── Fotografía ──────────────────────────────────────
                    _sectionTitle(
                      Icons.photo_camera_outlined,
                      'Fotografía de la unidad',
                    ),
                    const SizedBox(height: 16),
                    PhotoUploadBox(
                      pickedImage: _pickedImage,
                      enabled: !submitting,
                      hasError: _photoError,
                      onTap: _pickImage,
                      onRemove: () => setState(() => _pickedImage = null),
                    ),
                    if (_photoError)
                      _errorText('Agrega una fotografía de la unidad'),
                    const SizedBox(height: 32),

                    // ── Acciones ────────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton.icon(
                        onPressed: submitting ? null : () => _submit(context),
                        style: FilledButton.styleFrom(
                          backgroundColor: TColors.appMainColor,
                          foregroundColor: TColors.white,
                          disabledBackgroundColor:
                              TColors.appMainColor.withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.check_circle_outline_rounded,
                            size: 21),
                        label: const Text(
                          'Guardar registro',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: TextButton(
                        onPressed: submitting
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: TColors.textSecondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (submitting)
              const Positioned.fill(child: _SubmittingOverlay()),
          ],
        );
      },
    );
  }

  // ── Helpers de UI ─────────────────────────────────────────────────────

  Widget _sectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: TColors.primaryLight,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: TColors.appMainColor, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: TColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _label(String text) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            color: TColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Text(
          ' *',
          style: TextStyle(
            color: TColors.danger,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _errorText(String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: TColors.danger, size: 14),
          const SizedBox(width: 5),
          Text(
            message,
            style: const TextStyle(color: TColors.danger, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    bool enabled = true,
    int maxLines = 1,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
      style: const TextStyle(fontSize: 14.5, color: TColors.textPrimary),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Este campo es obligatorio' : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: TColors.hintColor, fontSize: 14),
        filled: true,
        fillColor: TColors.white,
        isDense: true,
        prefixIcon: icon == null
            ? null
            : Padding(
                padding: EdgeInsets.only(bottom: maxLines > 1 ? 60 : 0),
                child: Icon(icon, color: TColors.iconMuted, size: 20),
              ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: _fieldBorder(TColors.border),
        focusedBorder: _fieldBorder(TColors.appMainColor, width: 1.4),
        disabledBorder: _fieldBorder(TColors.border),
        errorBorder: _fieldBorder(TColors.danger),
        focusedErrorBorder: _fieldBorder(TColors.danger, width: 1.4),
        errorStyle: const TextStyle(color: TColors.danger, fontSize: 12),
      ),
    );
  }

  OutlineInputBorder _fieldBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

/// Hoja inferior para elegir el origen de la imagen.
class _ImageSourceSheet extends StatelessWidget {
  const _ImageSourceSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: TColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Agregar fotografía',
              style: TextStyle(
                color: TColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _option(
              context,
              icon: Icons.camera_alt_rounded,
              label: 'Tomar una foto',
              source: ImageSource.camera,
            ),
            const SizedBox(height: 10),
            _option(
              context,
              icon: Icons.photo_library_rounded,
              label: 'Elegir de la galería',
              source: ImageSource.gallery,
            ),
          ],
        ),
      ),
    );
  }

  Widget _option(
    BuildContext context, {
    required IconData icon,
    required String label,
    required ImageSource source,
  }) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(source),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: TColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: TColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: TColors.primaryLight,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: TColors.appMainColor, size: 21),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(
                color: TColors.textPrimary,
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded, color: TColors.iconMuted),
          ],
        ),
      ),
    );
  }
}

/// Overlay mostrado mientras se registra la maquinaria.
class _SubmittingOverlay extends StatelessWidget {
  const _SubmittingOverlay();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.35),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
          decoration: BoxDecoration(
            color: TColors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              ExcavatorLoader(width: 120, height: 120),
              SizedBox(height: 8),
              Text(
                'Registrando maquinaria...',
                style: TextStyle(
                  color: TColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Espera un momento',
                style: TextStyle(color: TColors.textSecondary, fontSize: 12.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
