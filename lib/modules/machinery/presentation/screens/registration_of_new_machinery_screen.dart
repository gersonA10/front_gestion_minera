import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/core/widgets/excavator_loader.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/machinery/domain/entity/entity.dart';
import 'package:front_gestion_minera/modules/machinery/presentation/bloc/machinery_bloc.dart';
import 'package:front_gestion_minera/modules/treasury/presentation/widgets/widgtes.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/widgets.dart';

@RoutePage()
class RegistrationOfNewMachineryScreen extends StatefulWidget {
  const RegistrationOfNewMachineryScreen({super.key});

  @override
  State<RegistrationOfNewMachineryScreen> createState() =>
      _RegistrationOfNewMachineryScreenState();
}

class _RegistrationOfNewMachineryScreenState
    extends State<RegistrationOfNewMachineryScreen> {
  late final MachineryBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = InjectorContainer.getIt<MachineryBloc>()..add(ListTypeMachinery());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: TColors.surface,
        appBar: AppBar(
          backgroundColor: TColors.surface,
          elevation: 0,
          leading: const BackButton(color: TColors.textPrimary),
          title: const Text(
            'REGISTRAR NUEVA\nMACHINARIA',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: TColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              height: 1.3,
            ),
          ),
          centerTitle: true,
        ),
        body: const _RegistrationFormBody(),
      ),
    );
  }
}

class _RegistrationFormBody extends StatefulWidget {
  const _RegistrationFormBody();

  @override
  State<_RegistrationFormBody> createState() => _RegistrationFormBodyState();
}

class _RegistrationFormBodyState extends State<_RegistrationFormBody> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  TypeMachineryEntity? _selectedType;
  List<TypeMachineryEntity> _types = [];
  XFile? _pickedImage;

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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: TColors.inputBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: TColors.textPrimary,
              ),
              title: const Text(
                'Seleccionar de galería',
                style: TextStyle(color: TColors.textPrimary),
              ),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt_outlined,
                color: TColors.textPrimary,
              ),
              title: const Text(
                'Tomar una foto',
                style: TextStyle(color: TColors.textPrimary),
              ),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source == null) return;
    final image = await ImagePicker().pickImage(source: source);
    if (image != null) setState(() => _pickedImage = image);
  }

  void _submit(BuildContext context) {
    final name = _nameController.text.trim();
    final code = _codeController.text.trim();
    final description = _descriptionController.text.trim();

    if (name.isEmpty || code.isEmpty || description.isEmpty) {
      CustomAlert.show(
        context,
        title: 'Error',
        message: 'Complete todos los campos',
        type: AlertType.error,
      );
      return;
    }
    if (_selectedType == null) {
      CustomAlert.show(
        context,
        title: 'Error',
        message: 'Seleccione un tipo de maquinaria',
        type: AlertType.error,
      );
      return;
    }
    if (_pickedImage == null) {
      CustomAlert.show(
        context,
        title: 'Error',
        message: 'Seleccione una fotografía',
        type: AlertType.error,
      );

      return;
    }

    context.read<MachineryBloc>().add(
      RegisterMachineryEvent(
        request: RegisterMachineryRequestEntity(
          name: name,
          uniqueCode: code,
          typeId: _selectedType!.id,
          description: description,
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
        if (state is TypeMachineryLoaded ) {
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
          Navigator.of(context).pop();
        }
        if (state is RegisterMachineryError) {
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
        final isLoading = state is RegisterMachineryLoading || state is TypeMachineryLoading;
        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoBanner(),
                  const SizedBox(height: 24),

                  _FieldLabel(label: 'NOMBRE DE LA MAQUINARIA'),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _nameController,
                    hintText: 'Ej. Excavadora Hidráulica 320',
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 20),

                  _FieldLabel(label: 'CÓDIGO DE MÁQUINA'),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _codeController,
                    hintText: 'MH-2024-001',
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 20),

                  _FieldLabel(label: 'TIPO DE MAQUINARIA'),
                  const SizedBox(height: 8),
                  if (state is TypeMachineryLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    TypeDropdown(
                      value: _selectedType,
                      types: _types,
                      enabled: !isLoading,
                      onChanged: (t) => setState(() => _selectedType = t),
                    ),
                  const SizedBox(height: 20),

                  _FieldLabel(label: 'DESCRIPCIÓN TÉCNICA'),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _descriptionController,
                    hintText:
                        'Ingrese especificaciones del motor, capacidad de carga, '
                        'horas de uso iniciales y estado actual...',
                    maxLines: 5,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 20),

                  _FieldLabel(label: 'FOTOGRAFÍA DE LA UNIDAD'),
                  const SizedBox(height: 8),
                  PhotoUploadBox(
                    pickedImage: _pickedImage,
                    enabled: !isLoading,
                    onTap: _pickImage,
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : () => _submit(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.textPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(
                        Icons.save_outlined,
                        color: TColors.white,
                        size: 20,
                      ),
                      label: Text(
                        'GUARDAR REGISTRO',
                        style: const TextStyle(
                          color: TColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: TColors.danger,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(
                        Icons.cancel_outlined,
                        color: TColors.danger,
                        size: 20,
                      ),
                      label: const Text(
                        'CANCELAR',
                        style: TextStyle(
                          color: TColors.danger,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            if (isLoading) ...[
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: const Center(child: ExcavatorLoader()),
                ),
              ),

          ],
          ]);
      },
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: TColors.textPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 12,
        letterSpacing: 0.8,
      ),
    );
  }
}
