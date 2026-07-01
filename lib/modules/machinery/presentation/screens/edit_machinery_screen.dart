import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/widgets/app_network_image.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/core/widgets/excavator_loader.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/machinery/domain/entity/entity.dart';
import 'package:front_gestion_minera/modules/machinery/presentation/bloc/machinery_bloc.dart';
import 'package:front_gestion_minera/modules/machinery/presentation/widgets/info_banner_widget.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:image_picker/image_picker.dart';

@RoutePage()
class EditMachineryScreen extends StatefulWidget {
  final String machineId;
  final String name;
  final String description;
  final String typeCode;
  final String photoUrl;

  const EditMachineryScreen({
    super.key,
    required this.machineId,
    required this.name,
    required this.description,
    required this.typeCode,
    required this.photoUrl,
  });

  @override
  State<EditMachineryScreen> createState() => _EditMachineryScreenState();
}

class _EditMachineryScreenState extends State<EditMachineryScreen> {
  late final MachineryBloc _bloc;
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  final _picker = ImagePicker();

  List<TypeMachineryEntity> _types = [];
  TypeMachineryEntity? _selectedType;
  XFile? _newImage;

  AutovalidateMode _autoValidate = AutovalidateMode.disabled;
  bool _typeError = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _descriptionController = TextEditingController(text: widget.description);
    _bloc = InjectorContainer.getIt<MachineryBloc>()..add(ListTypeMachinery());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _applyTypes(List<TypeMachineryEntity> types) {
    final filtered = types.where((t) => t.id != 'todos').toList();
    TypeMachineryEntity? preselected;
    for (final t in filtered) {
      if (t.code == widget.typeCode) {
        preselected = t;
        break;
      }
    }
    setState(() {
      _types = filtered;
      _selectedType ??= preselected;
    });
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
    final image = await _picker.pickImage(source: source, imageQuality: 80);
    if (image != null) setState(() => _newImage = image);
  }

  void _submit() {
    final formValid = _formKey.currentState?.validate() ?? false;
    final typeValid = _selectedType != null;
    setState(() {
      _autoValidate = AutovalidateMode.onUserInteraction;
      _typeError = !typeValid;
    });
    if (!formValid || !typeValid) return;

    _bloc.add(
      UpdateMachineryEvent(
        request: UpdateMachineryRequestEntity(
          machineId: widget.machineId,
          name: _nameController.text.trim(),
          typeId: _selectedType!.id,
          description: _descriptionController.text.trim(),
          photoPath: _newImage?.path,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: TColors.background,
        appBar: AppBar(
          backgroundColor: TColors.white,
          surfaceTintColor: TColors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          foregroundColor: TColors.textPrimary,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          leading: const BackButton(color: TColors.textPrimary),
          title: const Text(
            'Editar maquinaria',
            style: TextStyle(
              color: TColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: TColors.border),
          ),
        ),
        body: BlocConsumer<MachineryBloc, MachineryState>(
          listenWhen: (_, c) =>
              c is TypeMachineryLoaded ||
              c is UpdateMachinerySuccess ||
              c is UpdateMachineryError,
          listener: (context, state) {
            if (state is TypeMachineryLoaded) {
              _applyTypes(state.types);
            } else if (state is UpdateMachinerySuccess) {
              CustomAlert.show(
                context,
                title: '¡Listo!',
                message: 'Maquinaria actualizada exitosamente.',
                type: AlertType.success,
              );
              context.router.maybePop(true);
            } else if (state is UpdateMachineryError) {
              CustomAlert.show(
                context,
                title: 'Error',
                message: state.message,
                type: AlertType.error,
              );
            }
          },
          buildWhen: (_, c) =>
              c is UpdateMachineryLoading ||
              c is UpdateMachinerySuccess ||
              c is UpdateMachineryError ||
              c is TypeMachineryLoading ||
              c is TypeMachineryLoaded,
          builder: (context, state) {
            final submitting = state is UpdateMachineryLoading;
            final loadingTypes = state is TypeMachineryLoading && _types.isEmpty;

            return Stack(
              children: [
                Form(
                  key: _formKey,
                  autovalidateMode: _autoValidate,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle(Icons.badge_outlined, 'Identificación'),
                        const SizedBox(height: 16),
                        _label('Nombre de la maquinaria'),
                        const SizedBox(height: 8),
                        _textField(
                          controller: _nameController,
                          hint: 'Ej. Excavadora Hidráulica 320',
                          icon: Icons.precision_manufacturing_outlined,
                          enabled: !submitting,
                          textCapitalization: TextCapitalization.words,
                          requiredField: true,
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
                        _sectionTitle(
                            Icons.description_outlined, 'Descripción técnica'),
                        const SizedBox(height: 16),
                        _label('Especificaciones'),
                        const SizedBox(height: 8),
                        _textField(
                          controller: _descriptionController,
                          hint: 'Motor, capacidad de carga, estado actual...',
                          enabled: !submitting,
                          maxLines: 5,
                          textCapitalization: TextCapitalization.sentences,
                          requiredField: false,
                        ),
                        const SizedBox(height: 24),
                        _sectionTitle(
                            Icons.photo_camera_outlined, 'Fotografía'),
                        const SizedBox(height: 8),
                        const Text(
                          'Déjala como está para conservar la actual.',
                          style: TextStyle(
                            color: TColors.textSecondary,
                            fontSize: 12.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildPhoto(submitting),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: FilledButton.icon(
                            onPressed: submitting ? null : _submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: TColors.appMainColor,
                              foregroundColor: TColors.white,
                              disabledBackgroundColor:
                                  TColors.appMainColor.withValues(alpha: 0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(Icons.save_rounded, size: 21),
                            label: const Text(
                              'Guardar cambios',
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
                if (submitting) const Positioned.fill(child: SubmittingOverlay()),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPhoto(bool submitting) {
    // Nueva imagen elegida.
    if (_newImage != null) {
      return _photoFrame(
        enabled: !submitting,
        child: Image.file(
          File(_newImage!.path),
          width: double.infinity,
          height: 190,
          fit: BoxFit.cover,
        ),
        onRemove: () => setState(() => _newImage = null),
      );
    }
    // Foto actual (remota).
    if (widget.photoUrl.trim().isNotEmpty) {
      return _photoFrame(
        enabled: !submitting,
        child: AppNetworkImage(
          url: widget.photoUrl,
          width: double.infinity,
          height: 190,
        ),
      );
    }
    // Sin foto.
    return GestureDetector(
      onTap: submitting ? null : _pickImage,
      child: PhotoUploadBox(
        pickedImage: null,
        enabled: !submitting,
        onTap: _pickImage,
      ),
    );
  }

  Widget _photoFrame({
    required Widget child,
    required bool enabled,
    VoidCallback? onRemove,
  }) {
    return Stack(
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(16), child: child),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: enabled ? _pickImage : null,
            ),
          ),
        ),
        Positioned(
          left: 10,
          bottom: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                SizedBox(width: 5),
                Text(
                  'Cambiar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (onRemove != null)
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: enabled ? onRemove : null,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.close_rounded, color: Colors.white, size: 18),
              ),
            ),
          ),
      ],
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────

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
          Text(message,
              style: const TextStyle(color: TColors.danger, fontSize: 12)),
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
    bool requiredField = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
      style: const TextStyle(fontSize: 14.5, color: TColors.textPrimary),
      validator: requiredField
          ? (v) => (v == null || v.trim().isEmpty)
              ? 'Este campo es obligatorio'
              : null
          : null,
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
        enabledBorder: _border(TColors.border),
        focusedBorder: _border(TColors.appMainColor, width: 1.4),
        disabledBorder: _border(TColors.border),
        errorBorder: _border(TColors.danger),
        focusedErrorBorder: _border(TColors.danger, width: 1.4),
        errorStyle: const TextStyle(color: TColors.danger, fontSize: 12),
      ),
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

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
              'Cambiar fotografía',
              style: TextStyle(
                color: TColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _option(context,
                icon: Icons.camera_alt_rounded,
                label: 'Tomar una foto',
                source: ImageSource.camera),
            const SizedBox(height: 10),
            _option(context,
                icon: Icons.photo_library_rounded,
                label: 'Elegir de la galería',
                source: ImageSource.gallery),
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
