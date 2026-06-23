import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/injector_container.dart';

import 'package:front_gestion_minera/modules/staff/domain/entity/employee_check_out_request_entity.dart';
import 'package:front_gestion_minera/modules/staff/presentation/bloc/staff_bloc.dart';
import 'package:front_gestion_minera/modules/staff/presentation/screens/attendance_en_planta_tab.dart';

import 'package:front_gestion_minera/modules/staff/presentation/widgets/current_shift_card.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/exit_hour_widget.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/staff_ui.dart';

import 'package:front_gestion_minera/utils/constants/color.constant.dart';

/// Umbral (en minutos) bajo el cual una jornada exige una observación.
const int _kMinShiftMinutes = 240; // 4 horas

/// Tope máximo razonable de refrigerio (10 h) para evitar valores absurdos.
const int _kMaxBreakMinutes = 600;

@RoutePage()
class EmployeeCheckOutLogScreen extends StatefulWidget {
  final PlantaWorker worker;

  const EmployeeCheckOutLogScreen({super.key, required this.worker});

  @override
  State<EmployeeCheckOutLogScreen> createState() =>
      _EmployeeCheckOutLogScreenState();
}

class _EmployeeCheckOutLogScreenState extends State<EmployeeCheckOutLogScreen> {
  int breakMinutes = 60;
  late TimeOfDay startTime;
  late TimeOfDay endTime;
  Duration hoursWorked = Duration.zero;
  Duration netTotal = Duration.zero;

  final TextEditingController breakController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();
  late final StaffBloc _bloc;

  /// Única fuente de verdad de la regla "jornada corta": una jornada neta menor
  /// a [_kMinShiftMinutes] minutos exige una observación. La reutilizan el aviso
  /// del formulario y la validación del botón.
  bool get requiresRemark => netTotal.inMinutes < _kMinShiftMinutes;

  @override
  void initState() {
    super.initState();
    _bloc = InjectorContainer.getIt<StaffBloc>();
    endTime = TimeOfDay.now();
    final parts = (widget.worker.entryTime).split(':');
    startTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
    breakController.text = breakMinutes.toString();
    _calculateSummary();
  }

  @override
  void dispose() {
    _bloc.close();
    breakController.dispose();
    remarkController.dispose();
    super.dispose();
  }

  void _calculateSummary() {
    final startMinutes = (startTime.hour * 60) + startTime.minute;
    final endMinutes = (endTime.hour * 60) + endTime.minute;
    final minutesWorked = endMinutes - startMinutes;
    hoursWorked = Duration(minutes: minutesWorked < 0 ? 0 : minutesWorked);
    netTotal = hoursWorked - Duration(minutes: breakMinutes);
    if (netTotal.isNegative) {
      netTotal = Duration.zero;
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
  }

  Future<void> _selectTime() async {
    final hour = await showTimePicker(
      context: context,
      initialTime: endTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (hour == null) return;

    setState(() {
      endTime = hour;
      _calculateSummary();
    });
  }

  String _formatTime24Hour(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Fija el refrigerio desde presets/stepper: actualiza el modelo y sincroniza
  /// el campo de texto (cursor al final).
  void _setBreak(int value) {
    setState(() {
      breakMinutes = value.clamp(0, _kMaxBreakMinutes);
      breakController.text = breakMinutes.toString();
      breakController.selection = TextSelection.collapsed(
        offset: breakController.text.length,
      );
      _calculateSummary();
    });
  }

  /// Mientras el usuario ESCRIBE: actualiza el modelo sin reescribir el
  /// controlador (si se reescribe, el cursor salta y no se puede teclear bien).
  void _onBreakTyped(String raw) {
    if (raw.isEmpty) return;
    final n = int.tryParse(raw);
    if (n == null) return;
    setState(() {
      breakMinutes = n.clamp(0, _kMaxBreakMinutes);
      _calculateSummary();
    });
  }

  /// Al terminar de editar / perder foco: normaliza el texto al valor real.
  void _normalizeBreakField() {
    breakController.text = breakMinutes.toString();
    breakController.selection = TextSelection.collapsed(
      offset: breakController.text.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final worker = widget.worker;
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: StaffUi.background,
        appBar: staffAppBar(context, title: 'Registrar salida'),
        bottomNavigationBar: _BottomButton(
          attendanceId: worker.attendanceId,
          startTime: startTime,
          endTime: endTime,
          breakMinutes: breakMinutes,
          requiresRemark: requiresRemark,
          remarkController: remarkController,
          onFormatTime: _formatTime24Hour,
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _WorkerIdentity(
                  name: worker.name,
                  department: worker.department,
                ),
                const SizedBox(height: 20),
                CurrentShiftCard(
                  workerPhoto: worker.avatarUrl,
                  startTime: startTime,
                  formatearHora: _formatTime24Hour,
                ),
                const SizedBox(height: 20),
                ExitHourWidget(
                  endTime: endTime,
                  formatearHora: _formatTime24Hour,
                  onSelectTime: _selectTime,
                ),
                const SizedBox(height: 20),
                _BreakTimeCard(
                  breakMinutes: breakMinutes,
                  controller: breakController,
                  onUpdate: _setBreak,
                  onTyped: _onBreakTyped,
                  onEditingComplete: _normalizeBreakField,
                  hoursWorked: hoursWorked,
                ),
                const SizedBox(height: 20),
                _SummaryCard(
                  hoursWorked: hoursWorked,
                  breakMinutes: breakMinutes,
                  netTotal: netTotal,
                  formatDuration: _formatDuration,
                ),
                const SizedBox(height: 20),
                _ObservationsCard(
                  controller: remarkController,
                  requiresRemark: requiresRemark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tarjeta de identidad del trabajador: iniciales + nombre real (con respaldo
/// neutro si llegara vacío) y su sector.
class _WorkerIdentity extends StatelessWidget {
  final String name;
  final String department;
  const _WorkerIdentity({required this.name, required this.department});

  String get _displayName {
    final n = name.trim();
    return n.isNotEmpty ? n : 'Trabajador';
  }

  String get _initials {
    final parts = _displayName
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'T';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return StaffCard(
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: StaffUi.primarySoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              _initials,
              style: const TextStyle(
                fontSize: 16,
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
                  _displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: StaffUi.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                if (department.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    department,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: StaffUi.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Selector de refrigerio: presets (30/45/60) + stepper de ±5 min.
class _BreakTimeCard extends StatelessWidget {
  final int breakMinutes;
  final TextEditingController controller;
  final Function(int) onUpdate;
  final ValueChanged<String> onTyped;
  final VoidCallback onEditingComplete;
  final Duration hoursWorked;
  const _BreakTimeCard({
    required this.breakMinutes,
    required this.controller,
    required this.onUpdate,
    required this.onTyped,
    required this.onEditingComplete,
    required this.hoursWorked,
  });

  Widget _stepperButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    final enabled = onTap != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: enabled ? StaffUi.primarySoft : StaffUi.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 22,
            color: enabled ? StaffUi.primary : StaffUi.muted,
          ),
        ),
      ),
    );
  }

  Widget _preset(int value) {
    final active = breakMinutes == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onUpdate(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? StaffUi.primary : StaffUi.surface,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: active ? StaffUi.primary : StaffUi.border,
            ),
          ),
          child: Text(
            '$value min',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: active ? Colors.white : StaffUi.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canIncrease = breakMinutes + 5 <= _kMaxBreakMinutes;
    final bool canDecrease = breakMinutes - 5 >= 0;
    final bool exceedsWorked =
        hoursWorked.inMinutes > 0 && breakMinutes > hoursWorked.inMinutes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StaffSectionTitle(
          'Tiempo de refrigerio',
          icon: Icons.restaurant_rounded,
          helper: 'Se descuenta del total',
        ),
        const SizedBox(height: 12),
        StaffCard(
          child: Column(
            children: [
              Row(
                children: [
                  _stepperButton(
                    icon: Icons.remove_rounded,
                    onTap: canDecrease ? () => onUpdate(breakMinutes - 5) : null,
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: StaffUi.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        suffixText: 'min',
                        suffixStyle: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: StaffUi.textSecondary,
                        ),
                      ),
                      onChanged: onTyped,
                      onEditingComplete: () {
                        onEditingComplete();
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      onTapOutside: (_) {
                        onEditingComplete();
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                    ),
                  ),
                  _stepperButton(
                    icon: Icons.add_rounded,
                    onTap: canIncrease ? () => onUpdate(breakMinutes + 5) : null,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _preset(30),
                  const SizedBox(width: 10),
                  _preset(45),
                  const SizedBox(width: 10),
                  _preset(60),
                ],
              ),
              if (exceedsWorked) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 16, color: TColors.statusOrange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'El refrigerio supera el tiempo trabajado; el neto será 0.',
                        style: TextStyle(
                          fontSize: 11.5,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                          color: TColors.statusOrange,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Resumen de horas: trabajadas, descuento por refrigerio y total neto.
class _SummaryCard extends StatelessWidget {
  final Duration hoursWorked;
  final int breakMinutes;
  final Duration netTotal;
  final String Function(Duration) formatDuration;
  const _SummaryCard({
    required this.hoursWorked,
    required this.breakMinutes,
    required this.netTotal,
    required this.formatDuration,
  });

  Widget _row(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: StaffUi.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: StaffUi.textPrimary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return StaffCard(
      borderColor: StaffUi.primary.withValues(alpha: 0.18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StaffSectionTitle(
            'Resumen de jornada',
            icon: Icons.summarize_rounded,
          ),
          const SizedBox(height: 14),
          _row('Horas trabajadas', formatDuration(hoursWorked)),
          const SizedBox(height: 12),
          _row(
            'Descuento refrigerio',
            '-${formatDuration(Duration(minutes: breakMinutes))}',
          ),
          const SizedBox(height: 12),
          const Divider(color: StaffUi.border, height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Total neto',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: StaffUi.textPrimary,
                ),
              ),
              Text(
                formatDuration(netTotal),
                style: const TextStyle(
                  fontSize: 28,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  color: StaffUi.primary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Observaciones del turno + aviso cuando la jornada exige observación.
class _ObservationsCard extends StatelessWidget {
  final TextEditingController controller;
  final bool requiresRemark;

  const _ObservationsCard({
    required this.controller,
    required this.requiresRemark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StaffSectionTitle(
          'Observaciones de turno',
          icon: Icons.edit_note_rounded,
          helper: requiresRemark ? 'Obligatorio' : 'Opcional',
        ),
        const SizedBox(height: 12),
        StaffCard(
          borderColor:
              requiresRemark ? TColors.statusOrange.withValues(alpha: 0.5) : null,
          child: TextField(
            controller: controller,
            maxLines: 5,
            minLines: 4,
            maxLength: 500,
            inputFormatters: [LengthLimitingTextInputFormatter(500)],
            style: const TextStyle(
              fontSize: 14,
              color: StaffUi.textPrimary,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isCollapsed: true,
              hintText:
                  'Escriba aquí cualquier incidencia o comentario relevante...',
              hintStyle: TextStyle(color: StaffUi.muted),
              counterText: '',
            ),
          ),
        ),
        if (requiresRemark) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: TColors.statusOrangeBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: TColors.statusOrange.withValues(alpha: 0.35),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: TColors.statusOrange, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Las jornadas menores a 4 horas requieren observación.',
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                      color: TColors.statusOrange,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Botón principal anclado: valida y dispara el check-out.
class _BottomButton extends StatelessWidget {
  final String attendanceId;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final int breakMinutes;
  final bool requiresRemark;
  final TextEditingController remarkController;
  final String Function(TimeOfDay) onFormatTime;
  const _BottomButton({
    required this.attendanceId,
    required this.startTime,
    required this.endTime,
    required this.breakMinutes,
    required this.requiresRemark,
    required this.remarkController,
    required this.onFormatTime,
  });

  void _submit(BuildContext context) {
    final startMinutes = (startTime.hour * 60) + startTime.minute;
    final endMinutes = (endTime.hour * 60) + endTime.minute;

    if (endMinutes <= startMinutes) {
      CustomAlert.show(
        context,
        title: 'Hora inválida',
        message: 'La hora de salida debe ser mayor a la hora de entrada.',
        type: AlertType.warning,
      );
      return;
    }

    if (requiresRemark && remarkController.text.trim().isEmpty) {
      CustomAlert.show(
        context,
        title: 'Observación requerida',
        message:
            'Debe registrar una observación si el turno es menor a 4 horas.',
        type: AlertType.warning,
      );
      return;
    }

    context.read<StaffBloc>().add(
          CheckOutEmployeeEvent(
            attendanceId: attendanceId,
            request: EmployeeCheckOutRequestEntity(
              checkOutTime: onFormatTime(endTime),
              breakMinutes: breakMinutes,
              observations: remarkController.text.trim(),
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: StaffUi.surface,
        border: Border(top: BorderSide(color: StaffUi.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: BlocConsumer<StaffBloc, StaffState>(
            listener: (context, state) {
              if (state is CheckOutEmployeeSuccess) {
                CustomAlert.show(
                  context,
                  title: 'Registro completado',
                  message:
                      'La salida del trabajador fue registrada correctamente.',
                  type: AlertType.success,
                );
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (!context.mounted) return;
                  context.router.pop(true);
                });
              }
              if (state is CheckOutEmployeeError) {
                CustomAlert.show(
                  context,
                  title: 'Error',
                  message: state.message,
                  type: AlertType.error,
                );
              }
            },
            builder: (context, state) {
              final loading = state is CheckOutEmployeeLoading;
              return StaffPrimaryButton(
                label: loading ? 'Registrando...' : 'Registrar salida',
                icon: Icons.check_circle_rounded,
                loading: loading,
                onPressed: () => _submit(context),
              );
            },
          ),
        ),
      ),
    );
  }
}
