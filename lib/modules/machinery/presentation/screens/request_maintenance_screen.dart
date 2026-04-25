import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/core/widgets/excavator_loader.dart';
import 'package:front_gestion_minera/utils/text_util.dart';
import 'package:image_picker/image_picker.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/machinery/presentation/bloc/machinery_bloc.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

import '../../domain/entity/entity.dart';

@RoutePage()
class RequestMaintenanceScreen extends StatefulWidget {
  final String machineId;

  const RequestMaintenanceScreen({super.key, required this.machineId});

  @override
  State<RequestMaintenanceScreen> createState() =>
      _RequestMaintenanceScreenState();
}

class _RequestMaintenanceScreenState extends State<RequestMaintenanceScreen> {
  static const _faultTypeOptions = {
    'mecanica': 'Falla mecánica',
    'electrica': 'Falla eléctrica',
    'rodado': 'Rodado',
    'hidraulica': 'Falla hidráulica',
    'preventivo': 'Mantenimiento preventivo',
  };

  late MachineryBloc _machineryBloc;
  String _selectedFaultType = 'mecanica';
  final _descriptionController = TextEditingController();
  final _costController = TextEditingController();
  final List<XFile> _pickedImages = [];
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _machineryBloc = InjectorContainer.getIt<MachineryBloc>();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _costController.dispose();
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
                'Agregar evidencia',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: TColors.appSecondaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: TColors.appSecondaryColor,
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
                    color: TColors.appSecondaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.photo_library_outlined,
                    color: TColors.appSecondaryColor,
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
      setState(() {
        _pickedImages.add(photo);
      });
    }
  }

  void _removeImage(int index) => setState(() => _pickedImages.removeAt(index));

  // ── Submit ───────────────────────────────────────────────────────────────────

  void _submit() {
    final description = _descriptionController.text.trim();
    final cost = _costController.text.trim();

    if (description.isEmpty || cost.isEmpty) {
      CustomAlert.show(
        context,
        title: 'Campos incompletos',
        message: 'Por favor, completa la descripción y el costo estimado.',
        type: AlertType.warning,
      );
      return;
    }

    if (_pickedImages.isEmpty) {
      CustomAlert.show(
        context,
        title: 'Falta evidencia',
        message: 'Por favor, agrega al menos una imagen de evidencia.',
        type: AlertType.warning,
      );
      return;
    }

    final evidence = _pickedImages.first;

    final request = CreateMaintenanceRequestEntity(
      machineId: widget.machineId,
      failureType: _selectedFaultType,
      description: description,
      estimatedAmount: cost,
      evidenceUrlPath: evidence.path,
    );
    _machineryBloc.add(CreateMaintenanceRequestEvent(request: request));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _machineryBloc,
      child: BlocConsumer<MachineryBloc, MachineryState>(
        listener: (context, state) {
          if (state is CreateMaintenanceRequestSuccess) {
            CustomAlert.show(
              context,
              title: 'Éxito',
              message: 'Solicitud de mantenimiento creada correctamente.',
              type: AlertType.success,
            );
            context.router.maybePop(true);
          } else if (state is CreateMaintenanceRequestError) {
            CustomAlert.show(
              context,
              title: 'Error',
              message: state.message,
              type: AlertType.error,
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is CreateMaintenanceRequestLoading;
          return Stack(
            children: [
              Scaffold(
                backgroundColor: TColors.appBackgroundColor,
                appBar: AppBar(
                  backgroundColor: TColors.appSecondaryColor,
                  elevation: 0,
                  leadingWidth: 40,
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 22,
                      ),
                      onPressed: () => context.router.back(),
                    ),
                  ),
                  title: const Text(
                    'SOLICITAR MANTENIMIENTO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                body: SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 24,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle(
                                Icons.warning_amber_outlined,
                                'Tipo de Falla',
                              ),
                              const SizedBox(height: 10),
                              _buildDropdown(
                                value: _selectedFaultType,
                                items: _faultTypeOptions,
                                onChanged: (val) =>
                                    setState(() => _selectedFaultType = val!),
                              ),
                              const SizedBox(height: 20),
                              _buildSectionTitle(
                                Icons.description_outlined,
                                'Detalles',
                              ),
                              const SizedBox(height: 16),
                              Text('Descripción', style: AppTextStyles.mainStyle12(context),),
                              const SizedBox(height: 6),
                              _buildTextArea(),
                              const SizedBox(height: 20),
                              Text('Costo Estimado', style: AppTextStyles.mainStyle12(context),),
                              const SizedBox(height: 6),
                              _buildCostField(),
                              const SizedBox(height: 28),
                              _buildSectionTitle(
                                Icons.add_a_photo_outlined,
                                'Evidencia',
                              ),
                              const SizedBox(height: 16),
                              _buildUploadArea(),
                              if (_pickedImages.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                _buildImageGrid(),
                              ],
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        color: TColors.appBackgroundColor,
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                        child: SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _submit();
                            },
                            icon: const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 18,
                            ),
                            label: const Text(
                              'Enviar Solicitud',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TColors.appSecondaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isLoading)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black45,
                    child: Center(child: ExcavatorLoader()),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }




  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: TColors.appSecondaryColor, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: TColors.appSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String value,
    required Map<String, String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: TColors.appSurfaceColor),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: Colors.white,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: TColors.appSecondaryColor,
            size: 22,
          ),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: TColors.appMainTextColor,
          ),
          items: items.entries
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTextArea() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: TColors.appSurfaceColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _descriptionController,
        maxLines: null,
        expands: true,
        style: const TextStyle(fontSize: 14, color: TColors.appMainTextColor),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: InputBorder.none,
          hintText: 'Describe el problema de la maquinaria...',
          hintStyle: TextStyle(
            color: TColors.appSecondaryTextColor,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildCostField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: TColors.appSurfaceColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _costController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(fontSize: 15, color: TColors.appMainTextColor),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: InputBorder.none,
          prefixText: 'Bs ',
          prefixStyle: TextStyle(
            fontSize: 15,
            color: TColors.appSecondaryTextColor,
            fontWeight: FontWeight.w500,
          ),
          hintText: '0.00',
          hintStyle: TextStyle(
            color: TColors.appSecondaryTextColor,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildUploadArea() {
    return GestureDetector(
      onTap: _showImageSourceSheet,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: TColors.appSecondaryColor.withValues(alpha: 0.4),
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
                color: TColors.appSecondaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_a_photo_outlined,
                color: TColors.appSecondaryColor,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Agregar foto de evidencia',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: TColors.appSecondaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.camera_alt_outlined,
                  size: 14,
                  color: TColors.appSecondaryTextColor,
                ),
                const SizedBox(width: 4),
                const Text(
                  'Cámara',
                  style: TextStyle(
                    fontSize: 12,
                    color: TColors.appSecondaryTextColor,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.photo_library_outlined,
                  size: 14,
                  color: TColors.appSecondaryTextColor,
                ),
                const SizedBox(width: 4),
                const Text(
                  'Galería',
                  style: TextStyle(
                    fontSize: 12,
                    color: TColors.appSecondaryTextColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_pickedImages.length} foto seleccionada(s)',
          style: const TextStyle(
            fontSize: 12,
            color: TColors.appSecondaryTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _pickedImages.asMap().entries.map((entry) {
            final index = entry.key;
            final file = entry.value;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(file.path),
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: -6,
                  right: -6,
                  child: GestureDetector(
                    onTap: () => _removeImage(index),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
