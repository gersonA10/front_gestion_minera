import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';

@RoutePage()
class AssistanceDetailScreen extends StatefulWidget {
  const AssistanceDetailScreen({super.key});

  @override
  State<AssistanceDetailScreen> createState() => _AssistanceDetailScreenState();
}

class _AssistanceDetailScreenState extends State<AssistanceDetailScreen> {
  final _nameEmployee = 'Carlos Rodriguez';
  final _role = 'Operador de Maquinaria';
  final _nid = '12345678';
  final double _hourTotal = 9;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.appBackgroundColor,
      appBar: AppBar(
        backgroundColor: TColors.white,
        title: Text('Detalles de Asistencia'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.share_outlined,
              color: TColors.appBackgroundDarkColor,
            ),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 15),
        child: ListView(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.only(top: 15),
              decoration: BoxDecoration(
                color: TColors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            border: Border.all(color: TColors.uploadBlue),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Icon(Icons.person),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          _nameEmployee,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _role,
                          style: TextStyle(color: TColors.appDisabledDarkColor),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          margin: EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: TColors.uploadBlue.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            'ID: $_nid',
                            style: TextStyle(
                              fontSize: 12,
                              color: TColors.appNewDarkMainColor,
                            ),
                          ),
                        ),
                        Divider(color: TColors.disabled.withValues(alpha: 0.3)),
                        Row(
                          children: [
                            CardDateTurnWidget(
                              isDate: true,
                              date: '25 May, 2026',
                            ),
                            SizedBox(
                              height: 40,
                              child: VerticalDivider(
                                color: TColors.disabled.withValues(alpha: 0.3),
                              ),
                            ),
                            CardDateTurnWidget(isDate: false, turn: 'Mañana'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: TColors.green.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: TColors.green),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.circle, size: 8, color: TColors.green),
                          const SizedBox(width: 5),
                          Text(
                            'Finalizado',
                            style: TextStyle(
                              fontSize: 12,
                              color: TColors.appNewDarkMainColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 15),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: TColors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: TColors.uploadBlue,
                        size: 19,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Cronologia del Turno',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'HORAS EFECTIVAS',
                            style: TextStyle(
                              fontSize: 12,
                              color: TColors.disabled,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Excluyendo refrigerio',
                            style: TextStyle(
                              fontSize: 10,
                              color: TColors.disabled,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Text(
                            _hourTotal.toString(),
                            style: TextStyle(
                              fontSize: 30,
                              color: TColors.uploadBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'hrs',
                            style: TextStyle(
                              fontSize: 15,
                              color: TColors.disabled,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 15),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: TColors.white,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardDateTurnWidget extends StatelessWidget {
  final bool isDate;
  final String date;
  final String turn;
  const CardDateTurnWidget({
    super.key,
    required this.isDate,
    this.date = '',
    this.turn = '',
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        child: Column(
          children: [
            Text(
              isDate ? 'Fecha' : 'Turno',
              style: TextStyle(color: TColors.disabled, fontSize: 15),
            ),
            Text(
              isDate ? date : turn,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ],
        ),
      ),
    );
  }
}
