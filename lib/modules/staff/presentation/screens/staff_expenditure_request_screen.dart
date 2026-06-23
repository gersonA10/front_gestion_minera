import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/config/router/app_router.gr.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/staff/domain/entity/create_payroll_monthly_entity.dart';
import 'package:front_gestion_minera/modules/staff/presentation/bloc/staff_bloc.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/staff_ui.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/widgets/custom_alert_widget.dart';

const List<String> _kMonths = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
  'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
];

@RoutePage()
class StaffExpenditureRequestScreen extends StatefulWidget {
  const StaffExpenditureRequestScreen({super.key});

  @override
  State<StaffExpenditureRequestScreen> createState() =>
      _StaffExpenditureRequestScreenState();
}

class _StaffExpenditureRequestScreenState
    extends State<StaffExpenditureRequestScreen> {
  late final StaffBloc _blocPayroll;
  double _totalAmount = 0;
  int _totalEmployeed = 0;

  final List<XFile> _pickedImages = [];
  final int _maxFileSize = 10 * 1024 * 1024;
  final ImagePicker _picker = ImagePicker();
  final _justifyController = TextEditingController();
  final _keyform = GlobalKey<FormState>();

  String get _cycleLabel {
    final now = DateTime.now();
    return '${_kMonths[now.month - 1]} ${now.year}';
  }

  @override
  void initState() {
    super.initState();
    _blocPayroll = InjectorContainer.getIt<StaffBloc>()
      ..add(GetEmployeePayrollEvent());
  }

  @override
  void dispose() {
    _justifyController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_keyform.currentState!.validate()) return;
    if (_pickedImages.isEmpty) {
      CustomAlert.show(
        context,
        title: 'Falta la planilla',
        message: 'Adjunta una foto de la planilla de egreso para continuar.',
        type: AlertType.warning,
      );
      return;
    }
    final payrollEntity = CreatePayrollMonthlyEntity(
      month: DateTime.now().month,
      year: DateTime.now().year,
      justification: _justifyController.text,
      planillaUrl: _pickedImages.first.path,
    );
    _blocPayroll.add(CreatePayrollMonthlyEvent(payroll: payrollEntity));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _blocPayroll,
      child: BlocConsumer<StaffBloc, StaffState>(
        listener: (context, state) {
          if (state is GenerateEmployeePayrollSuccess) {
            setState(() {
              _totalAmount = state.totalAmount;
              _totalEmployeed = state.totalEmployee;
            });
          }
          if (state is CreatePayrollRequestSuccess) {
            CustomAlert.show(
              context,
              title: 'Solicitud enviada',
              message:
                  'Tu solicitud de egreso fue enviada a Hacienda. Espera la respuesta.',
              type: AlertType.success,
            );
            _justifyController.clear();
            setState(() => _pickedImages.clear());
          }
          if (state is CreatePayrollRequestError) {
            CustomAlert.show(
              context,
              title: 'Error',
              message: state.message,
              type: AlertType.error,
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is CreatePayrollRequestLoading;
          return ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            children: [
              _HistoryAccess(
                onTap: () =>
                    context.router.push(HistoricalRecordExpenditureRoute()),
              ),
              const SizedBox(height: 18),
              _AmountCard(
                cycleLabel: _cycleLabel,
                amount: _totalAmount,
                workers: _totalEmployeed,
              ),
              const SizedBox(height: 22),
              const StaffSectionTitle('Justificación de la solicitud'),
              const SizedBox(height: 10),
              Form(
                key: _keyform,
                child: TextFormField(
                  controller: _justifyController,
                  maxLines: 4,
                  style: const TextStyle(
                    fontSize: 14,
                    color: StaffUi.textPrimary,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    if (value.trim().length < 10) {
                      return 'Describe el motivo con al menos 10 caracteres';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Describe el motivo del egreso de nómina...',
                    hintStyle: const TextStyle(
                      color: StaffUi.muted,
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: StaffUi.surface,
                    contentPadding: const EdgeInsets.all(14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: StaffUi.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: StaffUi.primary, width: 1.4),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFEF4444)),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: Color(0xFFEF4444), width: 1.4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const StaffSectionTitle('Planilla de egreso'),
              const SizedBox(height: 10),
              _UploadZone(
                image: _pickedImages.isNotEmpty ? _pickedImages.first : null,
                onPick: _showPickerOptions,
                onRemove: () => setState(() => _pickedImages.clear()),
              ),
              const SizedBox(height: 16),
              _InfoBanner(),
              const SizedBox(height: 24),
              StaffPrimaryButton(
                label: 'Solicitar a Hacienda',
                icon: Icons.send_rounded,
                loading: isLoading,
                onPressed: _submit,
              ),
            ],
          );
        },
      ),
    );
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: StaffUi.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: StaffUi.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 6),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Adjuntar planilla',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: StaffUi.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded,
                    color: StaffUi.primary),
                title: const Text('Elegir de la galería'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_rounded,
                    color: StaffUi.primary),
                title: const Text('Tomar foto'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? photo =
          await _picker.pickImage(source: source, imageQuality: 80);
      if (photo == null) return;
      final int size = await photo.length();

      if (size > _maxFileSize) {
        if (!mounted) return;
        CustomAlert.show(
          context,
          title: 'Archivo muy grande',
          message: 'El archivo ${photo.path.split('/').last} supera los 10MB.',
          type: AlertType.error,
        );
        return;
      }
      setState(() {
        _pickedImages.clear();
        _pickedImages.add(photo);
      });
    } catch (e) {
      debugPrint('Error al procesar la imagen: $e');
    }
  }
}

/// Acceso al historial de solicitudes de egreso.
class _HistoryAccess extends StatelessWidget {
  final VoidCallback onTap;
  const _HistoryAccess({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return StaffCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: StaffUi.primarySoft,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.history_rounded,
                color: StaffUi.primary, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Historial de solicitudes',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: StaffUi.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Consulta tus egresos solicitados y su estado',
                  style: TextStyle(fontSize: 12, color: StaffUi.textSecondary),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded,
              size: 13, color: StaffUi.textSecondary),
        ],
      ),
    );
  }
}

/// Tarjeta destacada con el monto total a solicitar y el ciclo.
class _AmountCard extends StatelessWidget {
  final String cycleLabel;
  final double amount;
  final int workers;
  const _AmountCard({
    required this.cycleLabel,
    required this.amount,
    required this.workers,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StaffBloc, StaffState>(
      builder: (context, state) {
        final isLoading = state is GenerateEmployeePayrollLoading;
        // Los valores efectivos los mantiene el State del screen; aquí solo
        // reaccionamos al loading para el placeholder.
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: StaffUi.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: StaffUi.border),
            boxShadow: StaffUi.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'MONTO TOTAL A SOLICITAR',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: StaffUi.textSecondary,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: StaffUi.primarySoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      cycleLabel[0].toUpperCase() + cycleLabel.substring(1),
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: StaffUi.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              isLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.4, color: StaffUi.primary),
                      ),
                    )
                  : Text(
                      StaffUi.money2(amount),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: StaffUi.textPrimary,
                        letterSpacing: -0.6,
                      ),
                    ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: StaffUi.border),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.groups_rounded,
                      size: 18, color: StaffUi.textSecondary),
                  const SizedBox(width: 8),
                  const Text(
                    'Trabajadores activos',
                    style: TextStyle(
                      fontSize: 13,
                      color: StaffUi.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$workers',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: StaffUi.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Zona de carga de la planilla (con preview y opción de quitar).
class _UploadZone extends StatelessWidget {
  final XFile? image;
  final VoidCallback onPick;
  final VoidCallback onRemove;
  const _UploadZone({
    required this.image,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (image != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              File(image!.path),
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            right: 10,
            top: 10,
            child: InkWell(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      );
    }

    return DottedBorder(
      options: RoundedRectDottedBorderOptions(
        radius: const Radius.circular(16),
        color: StaffUi.primary.withValues(alpha: 0.45),
        dashPattern: const [6, 4],
        strokeWidth: 1.4,
        padding: EdgeInsets.zero,
      ),
      child: InkWell(
        onTap: onPick,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: StaffUi.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.cloud_upload_rounded,
                    color: StaffUi.primary, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sube una foto de la planilla',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        color: StaffUi.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Requerido · JPG o PNG (máx. 10MB)',
                      style:
                          TextStyle(fontSize: 11.5, color: StaffUi.textSecondary),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.add_photo_alternate_outlined,
                  color: StaffUi.primary),
            ],
          ),
        ),
      ),
    );
  }
}

/// Aviso informativo sobre el destino de la solicitud.
class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TColors.warningLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TColors.warning.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.info_outline_rounded, color: TColors.warning, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Esta solicitud se enviará al departamento de Hacienda para su '
              'revisión y aprobación presupuestaria.',
              style: TextStyle(
                color: TColors.warning,
                fontSize: 12.5,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
