import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_gestion_minera/injector_container.dart';
import 'package:front_gestion_minera/modules/staff/domain/entity/entity.dart';
import 'package:front_gestion_minera/modules/staff/presentation/bloc/staff_bloc.dart';
import 'package:front_gestion_minera/modules/staff/presentation/screens/attendance_ingreso_tab.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/staff_ui.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import '../../../../core/widgets/custom_alert_widget.dart';

/// Pantalla de detalle para registrar el ingreso (check-in) de un trabajador.
@RoutePage()
class EmployeeEntryRegisterScreen extends StatefulWidget {
  final IngresoWorker usuario;
  const EmployeeEntryRegisterScreen({super.key, required this.usuario});

  @override
  State<EmployeeEntryRegisterScreen> createState() =>
      _EmployeeEntryRegisterScreenState();
}

class _EmployeeEntryRegisterScreenState
    extends State<EmployeeEntryRegisterScreen> {
  TimeOfDay? _selectedTime;
  late final StaffBloc _checkinBloc;
  final _hourController = TextEditingController();
  final _observationController = TextEditingController();
  final _keyForm = GlobalKey<FormState>();

  /// Checklist de EPP. Es informativo / verificación visual: no hay endpoint
  /// para editarlo aún, así que se envía como verificado por defecto.
  static const List<_EppItem> _eppItems = [
    _EppItem('Casco', Icons.health_and_safety_rounded, 'casco'),
    _EppItem('Lentes', Icons.remove_red_eye_rounded, 'lentes'),
    _EppItem('Chaleco', Icons.checkroom_rounded, 'chaleco'),
    _EppItem('Orejeras', Icons.hearing_rounded, 'orejeras'),
  ];

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 7, minute: _selectedTime?.minute ?? 00),
      initialEntryMode: TimePickerEntryMode.inputOnly,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _hourController.text =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _hourController.text =
        '${TimeOfDay.now().hour.toString().padLeft(2, '0')}:${TimeOfDay.now().minute.toString().padLeft(2, '0')}';
    _checkinBloc = InjectorContainer.getIt<StaffBloc>();
  }

  @override
  void dispose() {
    _hourController.dispose();
    _observationController.dispose();
    super.dispose();
  }

  String get _initials {
    final parts = widget.usuario.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts[1].characters.first)
        .toUpperCase();
  }

  String _getTurn(int hour) {
    if (hour >= 6 && hour < 12) {
      return 'MAÑANA';
    } else if (hour >= 12 && hour < 18) {
      return 'TARDE';
    } else {
      return 'NOCHE';
    }
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_keyForm.currentState!.validate()) return;

    final eppData = {for (final e in _eppItems) e.key: true};
    final int hour = int.parse(_hourController.text.split(':')[0]);
    final checkIn = EmployeeCheckInEntity(
      employeeId: widget.usuario.employeeId,
      assignedShift: _getTurn(hour),
      checkInTime: _hourController.text,
      eppData: eppData,
      observation: _observationController.text,
    );
    _checkinBloc.add(RegisterCheckInEmployeeEvent(checkIn: checkIn));
    _observationController.clear();
    _hourController.text =
        '${TimeOfDay.now().hour.toString().padLeft(2, '0')}:${TimeOfDay.now().minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StaffUi.background,
      appBar: staffAppBar(context, title: 'Registrar ingreso'),
      body: BlocProvider.value(
        value: _checkinBloc,
        child: BlocConsumer<StaffBloc, StaffState>(
          listener: (context, state) {
            if (state is CheckInEmployeeSuccess) {
              CustomAlert.show(
                context,
                title: 'Registrado',
                message: 'Ingreso correctamente registrado',
                type: AlertType.success,
              );
              context.router.pop(true);
            }
            if (state is CheckInEmployeeError) {
              CustomAlert.show(
                context,
                title: 'Error',
                message: state.message,
                type: AlertType.error,
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is CheckInEmployeeLoading;
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                    children: [
                      _WorkerCard(
                        name: widget.usuario.name,
                        role: widget.usuario.role,
                        employeeId: widget.usuario.employeeId,
                        initials: _initials,
                        isLate: widget.usuario.isLate,
                      ),
                      const SizedBox(height: 16),
                      _CheckInTimeCard(
                        controller: _hourController,
                        scheduledTime: widget.usuario.scheduledTime,
                        onTapPicker: () => _selectTime(context),
                      ),
                      const SizedBox(height: 16),
                      const _EppCard(items: _eppItems),
                      const SizedBox(height: 16),
                      _ObservationCard(
                        formKey: _keyForm,
                        controller: _observationController,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
                  decoration: const BoxDecoration(
                    color: StaffUi.surface,
                    border: Border(top: BorderSide(color: StaffUi.border)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: StaffPrimaryButton(
                      label: 'Confirmar ingreso',
                      icon: Icons.check_circle_rounded,
                      loading: isLoading,
                      onPressed: _submit,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Tarjeta de identidad del trabajador: avatar con iniciales, nombre, cargo,
/// ID real (si existe) y estado de puntualidad.
class _WorkerCard extends StatelessWidget {
  final String name;
  final String role;
  final String employeeId;
  final String initials;
  final bool isLate;
  const _WorkerCard({
    required this.name,
    required this.role,
    required this.employeeId,
    required this.initials,
    required this.isLate,
  });

  /// ID corto (primeros dígitos) para que el pill no desborde con IDs largos.
  String get _shortId {
    final id = employeeId.trim();
    return id.length > 8 ? '${id.substring(0, 8)}…' : id;
  }

  @override
  Widget build(BuildContext context) {
    return StaffCard(
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: StaffUi.primarySoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: StaffUi.primary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: StaffUi.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  role,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: StaffUi.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (employeeId.trim().isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: StaffUi.primarySoft,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'ID: $_shortId',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: StaffUi.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    StaffPill(
                      label: isLate ? 'Con retraso' : 'A tiempo',
                      icon: isLate
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle_rounded,
                      color: isLate ? TColors.statusOrange : TColors.statusGreen,
                      bg: isLate
                          ? TColors.statusOrangeBg
                          : TColors.statusGreenBg,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de hora de entrada: selector de hora + hora programada real.
class _CheckInTimeCard extends StatelessWidget {
  final TextEditingController controller;
  final String scheduledTime;
  final VoidCallback onTapPicker;
  const _CheckInTimeCard({
    required this.controller,
    required this.scheduledTime,
    required this.onTapPicker,
  });

  @override
  Widget build(BuildContext context) {
    return StaffCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StaffSectionTitle(
            'Hora de entrada',
            icon: Icons.access_time_rounded,
          ),
          const SizedBox(height: 14),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onTapPicker,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: StaffUi.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: StaffUi.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.login_rounded,
                      size: 18,
                      color: StaffUi.primary,
                    ),
                    const SizedBox(width: 10),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: controller,
                      builder: (_, value, _) => Text(
                        value.text.isEmpty ? '--:--' : value.text,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: StaffUi.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.edit_rounded,
                      size: 16,
                      color: StaffUi.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (scheduledTime.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.event_available_rounded,
                  size: 14,
                  color: StaffUi.muted,
                ),
                const SizedBox(width: 6),
                Text(
                  'Programado: ${scheduledTime.trim()}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: StaffUi.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Checklist visual de equipo de protección personal (EPP).
class _EppCard extends StatelessWidget {
  final List<_EppItem> items;
  const _EppCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return StaffCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StaffSectionTitle(
            'Equipo de protección',
            icon: Icons.verified_user_rounded,
            helper: 'Verificación',
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final item in items)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: StaffUi.primarySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item.icon, size: 16, color: StaffUi.primary),
                      const SizedBox(width: 7),
                      Text(
                        item.label,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: StaffUi.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 15,
                        color: StaffUi.primary,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EppItem {
  final String label;
  final IconData icon;
  final String key;
  const _EppItem(this.label, this.icon, this.key);
}

/// Tarjeta de observaciones / condición de ingreso.
class _ObservationCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  const _ObservationCard({required this.formKey, required this.controller});

  @override
  Widget build(BuildContext context) {
    return StaffCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StaffSectionTitle(
            'Observaciones / Condición',
            icon: Icons.notes_rounded,
            helper: 'Opcional',
          ),
          const SizedBox(height: 14),
          Form(
            key: formKey,
            child: TextFormField(
              maxLines: 3,
              maxLength: 500,
              controller: controller,
              style: const TextStyle(
                fontSize: 14,
                color: StaffUi.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              // Campo opcional: sin validador.
              decoration: InputDecoration(
                hintText: 'Ej: Ingreso con equipamiento propio...',
                hintStyle: const TextStyle(
                  fontSize: 13.5,
                  color: StaffUi.muted,
                ),
                filled: true,
                fillColor: StaffUi.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: StaffUi.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: StaffUi.primary,
                    width: 1.4,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFEF4444)),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFFEF4444),
                    width: 1.4,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
