import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/machinery/presentation/bloc/machinery_bloc.dart';
import 'package:front_gestion_minera/modules/machinery/presentation/widgets/info_banner_widget.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/staff_ui.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:image_picker/image_picker.dart';

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
  late MachineryBloc _machineryBloc;
  List<FailureTypeEntity> _failureTypes = [];
  String? _selectedFaultType;

  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _costController = TextEditingController();
  final _picker = ImagePicker();
  XFile? _evidence;

  AutovalidateMode _autoValidate = AutovalidateMode.disabled;
  bool _typeError = false;
  bool _photoError = false;
  bool _typesLoadFailed = false;

  @override
  void initState() {
    super.initState();
    _machineryBloc = InjectorContainer.getIt<MachineryBloc>();
    _machineryBloc.add(FetchFailureTypesEvent());
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _costController.dispose();
    super.dispose();
  }

  void _retryTypes() {
    setState(() => _typesLoadFailed = false);
    _machineryBloc.add(FetchFailureTypesEvent());
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: TColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => const _EvidenceSourceSheet(),
    );
    if (source == null) return;
    final photo = await _picker.pickImage(source: source, imageQuality: 80);
    if (photo != null) {
      setState(() {
        _evidence = photo;
        _photoError = false;
      });
    }
  }

  void _submit() {
    final formValid = _formKey.currentState?.validate() ?? false;
    final typeValid = _selectedFaultType != null;
    final photoValid = _evidence != null;

    setState(() {
      _autoValidate = AutovalidateMode.onUserInteraction;
      _typeError = !typeValid;
      _photoError = !photoValid;
    });

    if (!formValid || !typeValid || !photoValid) return;

    final request = CreateMaintenanceRequestEntity(
      machineId: widget.machineId,
      failureType: _selectedFaultType!,
      description: _descriptionController.text.trim(),
      estimatedAmount: _costController.text.trim(),
      evidenceUrlPath: _evidence!.path,
    );
    _machineryBloc.add(CreateMaintenanceRequestEvent(request: request));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _machineryBloc,
      child: BlocConsumer<MachineryBloc, MachineryState>(
        listener: (context, state) {
          if (state is FailureTypesLoaded) {
            setState(() {
              _failureTypes = state.failureTypes;
              _typesLoadFailed = false;
              _selectedFaultType = state.failureTypes.isNotEmpty
                  ? state.failureTypes.first.value
                  : null;
            });
          } else if (state is FailureTypesError) {
            setState(() => _typesLoadFailed = true);
          } else if (state is CreateMaintenanceRequestSuccess) {
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
          final isSubmitting = state is CreateMaintenanceRequestLoading;

          return Stack(
            children: [
              Scaffold(
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
                    'Solicitar mantenimiento',
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
                body: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      Expanded(
                        child: Form(
                          key: _formKey,
                          autovalidateMode: _autoValidate,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _Hint(),
                                const SizedBox(height: 22),

                                // ── Tipo de falla ──────────────────────
                                _sectionTitle(
                                  Icons.report_problem_outlined,
                                  'Tipo de falla',
                                ),
                                const SizedBox(height: 14),
                                _label('¿Qué falla presenta?'),
                                const SizedBox(height: 8),
                                _buildFailureTypeSelector(),
                                if (_typeError)
                                  _errorText('Selecciona un tipo de falla'),
                                const SizedBox(height: 24),

                                // ── Detalles ───────────────────────────
                                _sectionTitle(
                                  Icons.description_outlined,
                                  'Detalles',
                                ),
                                const SizedBox(height: 14),
                                _label('Descripción del problema'),
                                const SizedBox(height: 8),
                                _buildDescriptionField(isSubmitting),
                                const SizedBox(height: 18),
                                _label('Costo estimado'),
                                const SizedBox(height: 8),
                                _buildCostField(isSubmitting),
                                const SizedBox(height: 24),

                                // ── Evidencia ──────────────────────────
                                _sectionTitle(
                                  Icons.photo_camera_outlined,
                                  'Evidencia',
                                ),
                                const SizedBox(height: 14),
                                PhotoUploadBox(
                                  pickedImage: _evidence,
                                  enabled: !isSubmitting,
                                  hasError: _photoError,
                                  onTap: _pickImage,
                                  onRemove: () =>
                                      setState(() => _evidence = null),
                                ),
                                if (_photoError)
                                  _errorText('Agrega una foto de evidencia'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      _buildBottomBar(isSubmitting),
                    ],
                  ),
                ),
              ),
              if (isSubmitting) StaffLoader(),
                
            ],
          );
        },
      ),
    );
  }

  // ── Componentes ───────────────────────────────────────────────────────

  Widget _buildBottomBar(bool isSubmitting) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: TColors.white,
        border: Border(top: BorderSide(color: TColors.border)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: FilledButton.icon(
          onPressed: isSubmitting ? null : _submit,
          style: FilledButton.styleFrom(
            backgroundColor: TColors.appMainColor,
            foregroundColor: TColors.white,
            disabledBackgroundColor:
                TColors.appMainColor.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.send_rounded, size: 20),
          label: const Text(
            'Enviar solicitud',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  Widget _buildFailureTypeSelector() {
    final loading = _failureTypes.isEmpty && !_typesLoadFailed;
    final borderColor = _typeError ? TColors.danger : TColors.border;

    return Container(
      constraints: const BoxConstraints(minHeight: 54),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          const Icon(Icons.report_problem_outlined,
              color: TColors.iconMuted, size: 20),
          const SizedBox(width: 10),
          Expanded(child: _selectorContent(loading)),
        ],
      ),
    );
  }

  Widget _selectorContent(bool loading) {
    if (_typesLoadFailed) {
      return GestureDetector(
        onTap: _retryTypes,
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: const [
            Expanded(
              child: Text(
                'No se pudieron cargar los tipos',
                style: TextStyle(color: TColors.danger, fontSize: 14),
              ),
            ),
            Icon(Icons.refresh_rounded, color: TColors.appMainColor, size: 20),
          ],
        ),
      );
    }
    if (loading) {
      return Row(
        children: const [
          Text(
            'Cargando tipos de falla...',
            style: TextStyle(color: TColors.hintColor, fontSize: 14),
          ),
          Spacer(),
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: TColors.appMainColor),
          ),
        ],
      );
    }
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _selectedFaultType,
        isExpanded: true,
        borderRadius: BorderRadius.circular(14),
        hint: const Text(
          'Selecciona el tipo de falla',
          style: TextStyle(color: TColors.hintColor, fontSize: 14),
        ),
        icon: const Icon(Icons.keyboard_arrow_down_rounded,
            color: TColors.textSecondary),
        style:
            const TextStyle(color: TColors.textPrimary, fontSize: 14.5),
        items: _failureTypes
            .map((e) => DropdownMenuItem(
                  value: e.value,
                  child: Text(
                    e.label,
                    style: const TextStyle(
                        color: TColors.textPrimary, fontSize: 14.5),
                  ),
                ))
            .toList(),
        onChanged: (val) => setState(() {
          _selectedFaultType = val;
          _typeError = false;
        }),
      ),
    );
  }

  Widget _buildDescriptionField(bool isSubmitting) {
    return TextFormField(
      controller: _descriptionController,
      enabled: !isSubmitting,
      maxLines: 4,
      textCapitalization: TextCapitalization.sentences,
      style: const TextStyle(fontSize: 14.5, color: TColors.textPrimary),
      validator: (v) => (v == null || v.trim().isEmpty)
          ? 'Describe el problema de la maquinaria'
          : null,
      decoration: _decoration(
        hint: 'Describe el problema, síntomas y cuándo comenzó...',
      ),
    );
  }

  Widget _buildCostField(bool isSubmitting) {
    return TextFormField(
      controller: _costController,
      enabled: !isSubmitting,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
      style: const TextStyle(fontSize: 14.5, color: TColors.textPrimary),
      validator: _costValidator,
      decoration: _decoration(
        hint: '0.00',
        icon: Icons.payments_outlined,
        prefixText: 'Bs ',
      ),
    );
  }

  String? _costValidator(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Ingresa el costo estimado';
    final parsed = double.tryParse(t);
    if (parsed == null || parsed <= 0) return 'Ingresa un costo válido';
    return null;
  }

  InputDecoration _decoration({
    required String hint,
    IconData? icon,
    String? prefixText,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: TColors.hintColor, fontSize: 14),
      filled: true,
      fillColor: TColors.white,
      isDense: true,
      prefixIcon: icon == null
          ? null
          : Icon(icon, color: TColors.iconMuted, size: 20),
      prefixText: prefixText,
      prefixStyle: const TextStyle(
        color: TColors.textPrimary,
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: _fieldBorder(TColors.border),
      focusedBorder: _fieldBorder(TColors.appMainColor, width: 1.4),
      disabledBorder: _fieldBorder(TColors.border),
      errorBorder: _fieldBorder(TColors.danger),
      focusedErrorBorder: _fieldBorder(TColors.danger, width: 1.4),
      errorStyle: const TextStyle(color: TColors.danger, fontSize: 12),
    );
  }

  OutlineInputBorder _fieldBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
  }

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
}

/// Aviso informativo de la cabecera.
class _Hint extends StatelessWidget {
  const _Hint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TColors.primaryLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.info_outline_rounded,
              color: TColors.appMainColor, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Describe la falla con el mayor detalle posible y adjunta una '
              'foto clara. Esto agiliza la aprobación del mantenimiento.',
              style: TextStyle(
                color: TColors.appMainColor,
                fontSize: 12.5,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Hoja inferior para elegir el origen de la evidencia.
class _EvidenceSourceSheet extends StatelessWidget {
  const _EvidenceSourceSheet();

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
              'Agregar evidencia',
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
