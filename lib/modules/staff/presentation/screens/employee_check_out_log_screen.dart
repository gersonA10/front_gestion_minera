import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:front_gestion_minera/core/widgets/custom_alert_widget.dart';

@RoutePage()
class EmployeeCheckOutLogScreen extends StatefulWidget {
  final String attendanceId;
  const EmployeeCheckOutLogScreen({super.key, required this.attendanceId});

  @override
  State<EmployeeCheckOutLogScreen> createState() =>
      _EmployeeCheckOutLogScreenState();
}

class _EmployeeCheckOutLogScreenState extends State<EmployeeCheckOutLogScreen> {
  String? workerPhoto;

  int breakMinutes = 60;
  late TimeOfDay endTime;
  TimeOfDay startTime = const TimeOfDay(hour: 7, minute: 0);
  Duration hoursWorked = Duration.zero;
  Duration netTotal = Duration.zero;
  bool requiresRemark = false;

  final TextEditingController breakController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();


  @override
  void initState() {
    super.initState();
    endTime = TimeOfDay.now();
    breakController.text = breakMinutes.toString();
    _calculateSummary();
  }

  @override
  void dispose() {
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
    return Scaffold(
      backgroundColor: TColors.appBackgroundColor,
      bottomNavigationBar: _buildBottomButton(),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildCurrentShiftCard(),

                    const SizedBox(height: 24),

                    _buildExitHour(),

                    const SizedBox(height: 24),

                    _buildBreakTime(),

                    const SizedBox(height: 24),

                    _buildSummaryCard(),

                    const SizedBox(height: 24),

                    _buildObservations(),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: TColors.white,
        border: Border(bottom: BorderSide(color: TColors.white)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
          ),

          Expanded(
            child: Column(
              children: [
                Text(
                  'Registro de Salida',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: TColors.appMainTextColor,
                  ),
                ),

                SizedBox(height: 2),

                Text(
                  widget.attendanceId,
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

  Widget _buildCurrentShiftCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(blurRadius: 10, color: Color.fromRGBO(0, 0, 0, .04)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey.shade200,

            backgroundImage:
                workerPhoto
             != null && workerPhoto
            !.isNotEmpty
                ? NetworkImage(workerPhoto
            !)
                : null,

            child: workerPhoto
         == null || workerPhoto
        !.isEmpty
                ? const Icon(Icons.person_outline, size: 30, color: Colors.grey)
                : null,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TURNO ACTUAL',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: TColors.disabled,
                  ),
                ),

                SizedBox(height: 8),

                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Entrada: ',
                        style: TextStyle(color: TColors.appMainTextColor),
                      ),
                      TextSpan(
                        text: _formatearHora(startTime),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 6),

                Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: Colors.green),

                    SizedBox(width: 4),

                    Text(
                      'En planta - Sector Norte',
                      style: TextStyle(color: Colors.green, fontSize: 13),
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

  Widget _buildExitHour() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hora de Salida',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 10),

        GestureDetector(
          onTap: _selectTime,
          child: Container(
            height: 58,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: TColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: TColors.disabled),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    _formatearHora(endTime),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const Icon(Icons.edit_outlined, color: TColors.disabled),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Se utilizará la hora actual del dispositivo por defecto.',
          style: TextStyle(color: TColors.disabled, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildBreakTime() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tiempo de Refrigerio',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: 60,
          decoration: BoxDecoration(
            color: TColors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  _actualizarRefrigerio(breakMinutes - 5);
                },
                icon: const Icon(Icons.remove, color: TColors.appMainDarkColor),
              ),

              Expanded(
                child: TextField(
                  controller: breakController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 30),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    suffixText: 'min',
                  ),
                  onChanged: (valor) {
                    final numero = int.tryParse(valor);
                    if (numero == null) return;
                    _actualizarRefrigerio(numero);
                  },
                ),
              ),

              IconButton(
                onPressed: () {
                  _actualizarRefrigerio(breakMinutes + 5);
                },
                icon: const Icon(Icons.add, color: TColors.appMainDarkColor),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [_presetButton(30), _presetButton(45), _presetButton(60)],
        ),
      ],
    );
  }

  Widget _presetButton(int valor) {
    final activo = breakMinutes == valor;

    return GestureDetector(
      onTap: () {
        _actualizarRefrigerio(valor);
      },

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),

          color: activo ? const Color(0xffE6F4FF) : Colors.transparent,
        ),

        child: Text(
          '$valor min',

          style: TextStyle(
            color: activo ? TColors.appMainDarkColor : TColors.disabled,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xffF3F8FD),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffD6E7F8)),
      ),
      child: Column(
        children: [
          _row('Horas Trabajadas', _formatDuration(hoursWorked)),
          const SizedBox(height: 14),
          _row(
            'Descuento Refrigerio',
            '-${_formatDuration(Duration(minutes: breakMinutes))}',
          ),
          const Divider(),
          const SizedBox(height: 8),
          _row('TOTAL NETO', _formatDuration(netTotal), highlight: true),
        ],
      ),
    );
  }

  Widget _row(String title, String value, {bool highlight = false}) {
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

  Widget _buildObservations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Observaciones de Turno',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.all(16),
          height: 110,
          decoration: BoxDecoration(
            color: TColors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: remarkController,
            maxLines: 5,
            maxLength: 500,
            inputFormatters: [LengthLimitingTextInputFormatter(500)],
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText:
                  'Escriba aquí cualquier incidencia o comentario relevante...',
              hintStyle: const TextStyle(color: TColors.disabled),

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

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: TColors.white,
      child: SizedBox(
        height: 54,
        child: ElevatedButton.icon(
          onPressed: () {
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

            CustomAlert.show(
              context,
              title: 'Registro completado',
              message: 'La salida del trabajador fue registrada correctamente.',
              type: AlertType.success,
            );
          },
          icon: const Icon(Icons.check_circle),
          label: const Text('Finalizar Registro'),
          style: ElevatedButton.styleFrom(
            backgroundColor: TColors.appMainDarkColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),
    );
  }
}
