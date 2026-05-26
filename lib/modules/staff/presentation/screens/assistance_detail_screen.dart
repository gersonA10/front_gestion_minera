import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:front_gestion_minera/utils/constants/color.constant.dart';
import 'package:timeline_tile/timeline_tile.dart';

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
                  TimelineCustomWidget(
                    isFirst: true,
                    pointColor: TColors.uploadBlue,
                    child: Container(
                      margin: const EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                        left: 5,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        color: TColors.uploadBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: TColors.uploadBlue.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Entrada Registrada',
                                style: TextStyle(
                                  color: TColors.uploadBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('Lugar'),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                '06:55',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                ),
                              ),
                              SizedBox(width: 4),
                              Text('AM'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  TimelineCustomWidget(
                    pointColor: TColors.grayText,
                    size: 10,
                    child: Container(
                      padding: EdgeInsets.only(left: 18, right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Refrigerio'),
                          Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: TColors.appBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.restaurant, size: 15),
                                SizedBox(width: 4),
                                Text(
                                  '45 min',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  TimelineCustomWidget(
                    isLast: true,
                    pointColor: TColors.bgColor,
                    child: Container(
                      margin: const EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                        left: 5,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        color: TColors.appBackgroundColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Salida Registrada',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('Lugar'),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                '16:40',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                ),
                              ),
                              SizedBox(width: 4),
                              Text('AM'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(color: TColors.appBackgroundColor,),
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

class TimelineCustomWidget extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final Color pointColor;
  final Widget child;
  final double size;
  const TimelineCustomWidget({
    super.key,
    this.isFirst = false,
    this.isLast = false,
    required this.pointColor,
    required this.child,
    this.size = 14,
  });

  @override
  Widget build(BuildContext context) {
    return TimelineTile(
      isFirst: isFirst,
      isLast: isLast,
      alignment: TimelineAlign.manual,
      lineXY: 0.1,
      indicatorStyle: IndicatorStyle(width: size, color: pointColor),
      beforeLineStyle: const LineStyle(color: TColors.grayText, thickness: 2),
      afterLineStyle: const LineStyle(color: TColors.grayText, thickness: 2),
      endChild: child,
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
