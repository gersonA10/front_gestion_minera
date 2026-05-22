import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

@RoutePage()
class EmployeeCheckOutLogScreen extends StatefulWidget {
  final String attendanceId;
  const EmployeeCheckOutLogScreen({super.key, required this.attendanceId});

  @override
  State<EmployeeCheckOutLogScreen> createState() =>
      _EmployeeCheckOutLogScreenState();
}

class _EmployeeCheckOutLogScreenState extends State<EmployeeCheckOutLogScreen> {
  String? fotoTrabajador;

  int minutosRefrigerio = 60;
  late TimeOfDay horaSalida;
  TimeOfDay horaEntrada = const TimeOfDay(hour: 7, minute: 0);
  Duration horasTrabajadas = Duration.zero;
  Duration totalNeto = Duration.zero;

  final TextEditingController refrigerioController = TextEditingController();
  final TextEditingController observacionController = TextEditingController();

  int? presetSeleccionado;

  @override
  @override
  @override
  void initState() {
    super.initState();
    horaSalida = TimeOfDay.now();
    refrigerioController.text = minutosRefrigerio.toString();
    _calcularResumen();
  }

  @override
  void dispose() {
    refrigerioController.dispose();
    observacionController.dispose();
    super.dispose();
  }

  void _calcularResumen() {
    final entradaMinutos = (horaEntrada.hour * 60) + horaEntrada.minute;
    final salidaMinutos = (horaSalida.hour * 60) + horaSalida.minute;
    final trabajado = salidaMinutos - entradaMinutos;
    horasTrabajadas = Duration(minutes: trabajado < 0 ? 0 : trabajado);
    totalNeto = horasTrabajadas - Duration(minutes: minutosRefrigerio);
  }

  String _formatearDuracion(Duration duracion) {
    final horas = duracion.inHours;
    final minutos = duracion.inMinutes % 60;
    return '${horas}h ${minutos.toString().padLeft(2, '0')}m';
  }

  Future<void> _seleccionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: horaSalida,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (hora == null) return;

    setState(() {
      horaSalida = hora;
      _calcularResumen();
    });
  }

  String _formatearHora(TimeOfDay hora) {
    final periodo = hora.hour >= 12 ? 'PM' : 'AM';

    final hora12 = hora.hour > 12
        ? hora.hour - 12
        : hora.hour == 0
        ? 12
        : hora.hour;

    return '${hora12.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')} $periodo';
  }

  void _actualizarRefrigerio(int valor) {
    setState(() {
      minutosRefrigerio = valor < 0 ? 0 : valor;
      refrigerioController.text = minutosRefrigerio.toString();
      _calcularResumen();
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
                fotoTrabajador != null && fotoTrabajador!.isNotEmpty
                ? NetworkImage(fotoTrabajador!)
                : null,

            child: fotoTrabajador == null || fotoTrabajador!.isEmpty
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
                        text: _formatearHora(horaEntrada),
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
          onTap: _seleccionarHora,
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
                    _formatearHora(horaSalida),
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
                  _actualizarRefrigerio(minutosRefrigerio - 5);
                },
                icon: const Icon(Icons.remove, color: TColors.appMainDarkColor),
              ),

              Expanded(
                child: TextField(
                  controller: refrigerioController,
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
                  _actualizarRefrigerio(minutosRefrigerio + 5);
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
    final activo = minutosRefrigerio == valor;

    return GestureDetector(
      onTap: () {
        presetSeleccionado = valor;

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
          _row('Horas Trabajadas', _formatearDuracion(horasTrabajadas)),
          const SizedBox(height: 14),
          _row(
            'Descuento Refrigerio',
            '-${_formatearDuracion(Duration(minutes: minutosRefrigerio))}',
          ),
          const Divider(),
          const SizedBox(height: 8),
          _row('TOTAL NETO', _formatearDuracion(totalNeto), highlight: true),
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
            controller: observacionController,
            maxLines: 5,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText:
                  'Escriba aquí cualquier incidencia o comentario relevante...',
              hintStyle: TextStyle(color: TColors.disabled),
            ),
          ),
        ),
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
          onPressed: () {},
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
