import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';
import 'package:front_gestion_minera/injector_container.dart';

import 'package:front_gestion_minera/modules/staff/domain/entity/employee_check_out_request_entity.dart';
import 'package:front_gestion_minera/modules/staff/presentation/bloc/staff_bloc.dart';

import 'package:front_gestion_minera/modules/staff/presentation/widgets/current_shift_card.dart';
import 'package:front_gestion_minera/modules/staff/presentation/widgets/exit_hour_widget.dart';

import 'package:front_gestion_minera/utils/constants/color.constant.dart';

@RoutePage()
class EmployeeCheckOutLogScreen extends StatefulWidget {
  final String attendanceId;
  final String? workerPhoto;
  final String? checkInTime;

  const EmployeeCheckOutLogScreen({
    super.key,
    required this.attendanceId,
    this.workerPhoto,
    this.checkInTime,
  });

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
  bool requiresRemark = false;

  final TextEditingController breakController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();
  late final StaffBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = InjectorContainer.getIt<StaffBloc>();
    endTime = TimeOfDay.now();
    final parts = (widget.checkInTime ?? '07:05').split(':');
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
    hoursWorked = Duration(
      minutes: minutesWorked < 0 ? 0 : minutesWorked,
    );
    netTotal = hoursWorked - Duration(minutes: breakMinutes);
    if (netTotal.isNegative) {
      netTotal = Duration.zero;
    }
    requiresRemark = netTotal.inHours < 4;
  }

  String _formatDuration(Duration duracion) {
    final hours = duracion.inHours;
    final minutes = duracion.inMinutes % 60;
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

  String _formatearHora(TimeOfDay hour) {
    final periodo = hour.hour >= 12 ? 'PM' : 'AM';

    final hora12 = hour.hour > 12
        ? hour.hour - 12
        : hour.hour == 0
        ? 12
        : hour.hour;

    return '${hora12.toString().padLeft(2, '0')}:${hour.minute.toString().padLeft(2, '0')} $periodo';
  }

  void _actualizarRefrigerio(int valor) {
    setState(() {
      breakMinutes = valor < 0 ? 0 : valor;
      breakController.text = breakMinutes.toString();
      _calculateSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: TColors.appBackgroundColor,

        bottomNavigationBar: BottomButtonWidget(
          attendanceId: widget.attendanceId,
          netTotal: netTotal,
          startTime: startTime,
          endTime: endTime,
          breakMinutes: breakMinutes,
          remarkController: remarkController,
        ),
        body: SafeArea(
          child: Column(
            children: [
              HeaderWidget(attendanceId: widget.attendanceId),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CurrentShiftCard(
                        workerPhoto: widget.workerPhoto,
                        startTime: startTime,
                        formatearHora: _formatearHora,
                      ),
                      const SizedBox(height: 24),
                      ExitHourWidget(
                        endTime: endTime,
                        formatearHora: _formatearHora,
                        onSelectTime: _selectTime,
                      ),
                      const SizedBox(height: 24),
                      BreakTimeWidget(
                        breakMinutes: breakMinutes,
                        controller: breakController,
                        onUpdate: _actualizarRefrigerio,
                      ),
                      const SizedBox(height: 24),
                      SummaryCardWidget(
                        hoursWorked: hoursWorked,
                        breakMinutes: breakMinutes,
                        netTotal: netTotal,
                        formatDuration: _formatDuration,
                      ),
                      const SizedBox(height: 24),
                      ObservationsWidget(
                        controller: remarkController,
                        requiresRemark: requiresRemark,
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HeaderWidget extends StatelessWidget {
  final String attendanceId;
  const HeaderWidget({super.key, required this.attendanceId});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: TColors.white,
        border: Border(bottom: BorderSide(color: TColors.white)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
          Expanded(
            child: Column(
              children: [
                const Text(
                  'Registro de Salida',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: TColors.appMainTextColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  attendanceId,
                  style: const TextStyle(fontSize: 13, color: TColors.disabled),
                ),
              ],
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.help_outline)),
        ],
      ),
    );
  }
}

class BreakTimeWidget extends StatelessWidget {
  final int breakMinutes;
  final TextEditingController controller;
  final Function(int) onUpdate;
  const BreakTimeWidget({
    super.key,
    required this.breakMinutes,
    required this.controller,
    required this.onUpdate,
  });

  Widget preset(int value) {
    final activo = breakMinutes == value;
    return GestureDetector(
      onTap: () {
        onUpdate(value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: activo ? const Color(0xffE6F4FF) : Colors.transparent,
        ),
        child: Text(
          '$value min',
          style: TextStyle(
            color: activo ? TColors.appMainDarkColor : TColors.disabled,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tiempo de Refrigerio',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: TColors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () => onUpdate(breakMinutes - 5),
                icon: const Icon(Icons.remove),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(fontSize: 30),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    suffixText: 'min',
                  ),
                  onChanged: (value) {
                    final number = int.tryParse(value);
                    if (number != null) {
                      onUpdate(number);
                    }
                  },
                ),
              ),

              IconButton(
                onPressed: () => onUpdate(breakMinutes + 5),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [preset(30), preset(45), preset(60)],
        ),
      ],
    );
  }
}

class SummaryCardWidget extends StatelessWidget {
  final Duration hoursWorked;
  final int breakMinutes;
  final Duration netTotal;
  final String Function(Duration) formatDuration;
  const SummaryCardWidget({
    super.key,
    required this.hoursWorked,
    required this.breakMinutes,
    required this.netTotal,
    required this.formatDuration,
  });

  Widget rowItem(String title, String value, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: highlight ? 17 : 15,
            fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
            color: highlight
                ? TColors.appMainDarkColor
                : TColors.appMainTextColor,
          ),
        ),

        Text(
          value,
          style: TextStyle(
            fontSize: highlight ? 32 : 16,
            fontWeight: FontWeight.bold,
            color: highlight
                ? TColors.appMainDarkColor
                : TColors.appMainTextColor,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xffF3F8FD),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffD6E7F8)),
      ),
      child: Column(
        children: [
          rowItem('Horas Trabajadas', formatDuration(hoursWorked)),
          const SizedBox(height: 14),
          rowItem(
            'Descuento Refrigerio',
            '-${formatDuration(Duration(minutes: breakMinutes))}',
          ),
          const Divider(),
          const SizedBox(height: 8),
          rowItem('TOTAL NETO', formatDuration(netTotal), highlight: true),
        ],
      ),
    );
  }
}

class ObservationsWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool requiresRemark;

  const ObservationsWidget({
    super.key,
    required this.controller,
    required this.requiresRemark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Observaciones de Turno',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Container(
          height: 110,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TColors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: controller,
            maxLines: 5,
            maxLength: 500,

            inputFormatters: [LengthLimitingTextInputFormatter(500)],

            decoration: const InputDecoration(
              border: InputBorder.none,

              hintText:
                  'Escriba aquí cualquier incidencia o comentario relevante...',

              hintStyle: TextStyle(color: TColors.disabled),

              counterText: '',
            ),
          ),
        ),

        if (requiresRemark) ...[
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Las jornadas menores a 4 horas requieren observación.',
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

class BottomButtonWidget extends StatelessWidget {
  final String attendanceId;
  final Duration netTotal;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final int breakMinutes;
  final TextEditingController remarkController;
  const BottomButtonWidget({
    super.key,
    required this.attendanceId,
    required this.netTotal,
    required this.startTime,
    required this.endTime,
    required this.breakMinutes,
    required this.remarkController,
  });

  String _formatTime24(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: TColors.white,
      child: SizedBox(
        height: 54,
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
              context.router.pop();
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

            return ElevatedButton.icon(
              onPressed: loading
                  ? null
                  : () {
                      final startMinutes =
                          (startTime.hour * 60) + startTime.minute;

                      final endMinutes = (endTime.hour * 60) + endTime.minute;

                      if (endMinutes <= startMinutes) {
                        CustomAlert.show(
                          context,
                          title: 'Hora inválida',
                          message:
                              'La hora de salida debe ser mayor a la hora de entrada.',
                          type: AlertType.warning,
                        );
                        return;
                      }
                      final requiresRemark = netTotal.inMinutes < 240;

                      if (requiresRemark &&
                          remarkController.text.trim().isEmpty) {
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
                            checkOutTime: _formatTime24(endTime),
                            breakMinutes: breakMinutes,
                            observations: remarkController.text.trim(),
                          ),
                        ),
                      );
                    },
              icon: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(),
                    )
                  : const Icon(Icons.check_circle),
              label: Text(loading ? 'Registrando...' : 'Finalizar Registro'),
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.appMainDarkColor,
                foregroundColor: TColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
