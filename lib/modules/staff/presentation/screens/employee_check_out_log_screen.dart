import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

@RoutePage()
class EmployeeCheckOutLogScreen extends StatefulWidget {
  final String attendanceId;
  const EmployeeCheckOutLogScreen({super.key, required this.attendanceId,});
  

  @override
  State<EmployeeCheckOutLogScreen> createState() =>
      _EmployeeCheckOutLogScreenState();
}

class _EmployeeCheckOutLogScreenState extends State<EmployeeCheckOutLogScreen> {
  static const String _fallbackImage =
      'https://siu.edu.bd/storage/uploaded/authority/male_1723030204.jpeg';
  int minutosRefrigerio = 60;

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

                    const SizedBox(height: 100),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Image.network(
              _fallbackImage,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  width: 56,
                  height: 56,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.person),
                );
              },
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
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
                        text: '07:00 AM',
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

        Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: TColors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: const [
              Icon(Icons.access_time, color: TColors.disabled),

              SizedBox(width: 10),

              Text(
                '04:00 PM',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
              ),
            ],
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
                onPressed: () {},
                icon: const Icon(Icons.remove, color: TColors.appMainDarkColor),
              ),

              Expanded(
                child: Center(
                  child: Text(
                    '$minutosRefrigerio',
                    style: const TextStyle(fontSize: 30),
                  ),
                ),
              ),

              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.add, color: TColors.appMainDarkColor),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _presetButton('30 min'),
            _presetButton('45 min'),
            _presetButton('60 min', active: true),
          ],
        ),
      ],
    );
  }

  Widget _presetButton(String text, {bool active = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: active ? const Color(0xffE6F4FF) : Colors.transparent,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: active ? TColors.appMainDarkColor : TColors.disabled,
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
          _row('Horas Trabajadas', '9h 00m'),

          const SizedBox(height: 14),

          _row('Descuento Refrigerio', '-1h 00m'),

          const Divider(),

          const SizedBox(height: 8),

          _row('TOTAL NETO', '8h 00m', highlight: true),
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
          child: const TextField(
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
